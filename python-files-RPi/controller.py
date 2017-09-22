# Controller for the Algorithmic Composition project
# Only one sensor is assumed to exist. See sensors2sound.py for handling multiple sensors.

# !!!!! READ THIS
# Be careful to test the sensor before each use, and change the mapping  params to SC code! I dont know why, but each time the safe values are different (maybe due to the cheap sensor?).
# Last test shows that safe values for the sensor are between 285 and 726. If no obstacle the sensor defaults at 297 (for some reason)
#changes for testing purposes here!

####### SETUP ##########

import sys, time, spidev, OSC
from collections import Counter
import RPi.GPIO as GPIO

# SPI and OSC setup
spi = spidev.SpiDev()
spi.open(0,0)
## User input for osc address and port
osc_addr = raw_input("Enter IP address of the client (default 10.42.0.1): ") or "10.42.0.1"
osc_port = int(raw_input("Enter OSC port of the client (default 57120): ") or 57120)

osc_client = OSC.OSCClient()
osc_client.connect((osc_addr, osc_port))

# GPIO setup
GPIO.setmode(GPIO.BCM)
## 
sensor_btn = 16
param_btn = 20
synth_btn = 21
route_btn = 26
onoff_btn = 19

GPIO.setup(sensor_btn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(param_btn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(synth_btn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(onoff_btn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(route_btn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

# General setup
## Synth parameters
param = {
    "a_fm": ["carr", "mod", "dp", "amp", "pan"],
    "b_grains": ["pos", "dens", "rate", "dur", "rfreq", "rdp", "amp", "pan"],
    "c_comb": ["time", "dec", "amp"],
    "d_bpf": ["freq", "rq", "mfreq", "mdp"]
}
synth_num = param_num = 0
sensor_on = 0

## Sensor output stability
t0 = t1 = time.time()
interval = 0.075
sensor_values = []
min_val = prev_val = 70

# Functions
def read_sensor(channel):
    if((channel > 7) or (channel < 0)):
        return -1
    r = spi.xfer2([1, (8 + channel) << 4, 0])
    output = ((r[1]&3) << 8) + r[2]
    return output

def send_osc(address, msg_content):
    msg = OSC.OSCMessage()
    msg.setAddress(address)
    msg.extend(msg_content)
    osc_client.send(msg)

def change_synth(channel):
    global synth_num
    global param_num
    param_num = 0 # always start from first parameter
    synth_num += 1
    if synth_num == len(param.keys()):
        synth_num = 0

    synth = sorted(param.keys())[synth_num]
    prm = param[synth][param_num]
    synth = synth[2:]
    msg_addr = "/monitor"
    msg = [synth, prm]
    send_osc(msg_addr, msg)

def change_param(channel):
    global synth_num
    global param_num
    param_num += 1
    synth = sorted(param.keys())[synth_num] # current synth
    if param_num == len(param[synth]):
        param_num = 0

    prm = param[synth][param_num]
    synth = synth[2:]
    msg_addr = "/monitor"
    msg = [synth, prm]
    send_osc(msg_addr, msg)

def change_route(channel):
    global synth_num
    synth = sorted(param.keys())[synth_num]
    synth = synth[2:]
    msg_addr = "/route"
    msg = [synth]
    print "Change route: ", msg
    send_osc(msg_addr, msg)

def synth_onoff(channel):
    global synth_num
    synth = sorted(param.keys())[synth_num] # current synth
    synth = synth[2:]

    msg_addr = "/onoff"
    msg = [synth]
    print msg
    send_osc(msg_addr, msg)

def sensor_switch(channel):
    global sensor_on
    sensor_on = not(sensor_on)

    msg_addr = "/monitor"
    msg = ["sensor", sensor_on]
    print msg
    send_osc(msg_addr, msg)
    
# Assign callback functions to respective pins
GPIO.add_event_detect(synth_btn, GPIO.RISING, callback=change_synth, bouncetime=200)
GPIO.add_event_detect(param_btn, GPIO.RISING, callback=change_param, bouncetime=200)
GPIO.add_event_detect(sensor_btn, GPIO.RISING, callback=sensor_switch, bouncetime=200)
GPIO.add_event_detect(onoff_btn, GPIO.RISING, callback=synth_onoff, bouncetime=200)
GPIO.add_event_detect(route_btn, GPIO.RISING, callback=change_route, bouncetime=200)

###### MAIN PROGRAM #######

try:
    while True:
        this_synth = sorted(param.keys())[synth_num]
        this_param = param[this_synth][param_num]
        this_synth = this_synth[2:] # get rid of index letters
        if sensor_on:
            while (t1 - t0) < interval:
                sig = read_sensor(0)
                if sig < min_val:
                    sig = min_val
                sensor_values.append(sig)
                t1 = time.time()
            a = Counter(sensor_values)
            sig_stable = a.most_common(1)[0][0]
            print "{0}, {1}, {2}".format(this_synth, this_param, sig_stable)

            msg_addr = "/sensor"
            msg = [this_synth, this_param, sig_stable]
            send_osc(msg_addr, msg)
            
            sensor_values = []
            t0 = t1
        else: # dont overdo it...
            time.sleep(interval)

####### EXITING PROCEDURES ##########

except KeyboardInterrupt:
    print "\nQuitting..."
finally:
    print "Cleanup the system (GPIO and SPI)"
    GPIO.cleanup()
    spi.close()
    print "Done!"
    sys.exit(0)
