// SYNTHDEF DECLARATIONS
(
// fm
SynthDef(\fm, {
	| carr = 440, mod = 100, dp = 10, pan = 0, amp = 1, out = 0 |
	m = SinOsc.ar(mod.lag(g)) * dp.lag(g);
	c = SinOsc.ar(carr.lag(g) + m, mul:amp.lag(g));
	x = Pan2.ar(c, pan);
	Out.ar(out, x);
}).add;

// grains
SynthDef(\grains, {
	| buf, dens = 1, rate = 1, pos = 0, rfreq = 0.1, rdp = 0, dur = 0.05, pan = 0, amp = 1, out = 0 |
	var imp, rnd;
	imp = Dust.kr(dens.lag(g));
	rnd = LFNoise0.kr(rfreq.lag(g), rdp.lag(g));
	p = (BufDur.kr(buf) * pos.lag(g)) + rnd;
	x = TGrains.ar(2, imp, buf, rate.lag(g), p, dur, pan, amp);
	Out.ar(out, x);
}).add;

// comb
SynthDef(\comb, {
	| in, time = 0.1, dec = 1, amp = 1, out = 0 |
	var sig;
	sig = In.ar(in, 2);
	x = CombC.ar(sig, 1, time.lag(g), dec.lag(g), amp.lag(g));
	x = Limiter.ar(x, 0.8);
	Out.ar(out, x);
}).add;

// bpf
SynthDef(\bpf, {
	| in, freq = 440, rq = 1, mfreq = 0.1, mdp = 0.0001, out = 0 |
	var sig;
	sig = In.ar(in, 2);
	x = BPF.ar(sig, SinOsc.kr(mfreq.lag(g)).range((freq - mdp).lag(g), (freq + mdp).lag(g)), rq.lag(g), (1/rq.sqrt).lag(g) );
	x = Limiter.ar(x, 0.8);
	Out.ar(out, x);
}).add;
)

