// GLOBAL DECLARATIONS

(
// Synths
~num_synths = 4;

~synth = Array.newClear(~num_synths);

// Groups
~sig_group = Group.new;
~fx_group = Group.after(~sig_group);

// Busses and buffers
~comb_bus = Bus.audio(s, 2);
~bpf_bus = Bus.audio(s, 2);

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// universal lag
g = 0.2;

// ranges
~pan_r = ControlSpec(-1, 1, \lin, 0, 0);

~fm_carr_r = ControlSpec(100, 4000, \exp, 0, 440);
~fm_mod_r = ControlSpec(10, 1000, \exp, 0, 100);
~fm_dp_r = ControlSpec(10, 100, \lin, 0, 50);

~grains_dens_r = ControlSpec(0.1, 100, \lin, 0, 3);
~grains_rate_r = ControlSpec(-2, 2, \lin, 0, 1);
~grains_dur_r = ControlSpec(0.05, 2, \lin, 0, 0.05);
~grains_rfreq_r = ControlSpec(0.1, 20, \exp, 0, 0.1);
~grains_rdp_r = ControlSpec(0, 5, \lin, 0, 0);

~comb_time_r = ControlSpec(0.001, 1, \exp, 0, 0.2);
~comb_dec_r = ControlSpec(0.5, 60, \exp, 0, 5);

~bpf_freq_r = ControlSpec(100, 1000, \exp, 0, 330);
~bpf_rq_r = ControlSpec(1, 100, \lin, 0, 10);
~bpf_mfreq_r = ControlSpec(0.1, 100, \exp, 0, 0.1);
~bpf_mdp_r = ControlSpec(0, 100, \lin, 0, 0);

)