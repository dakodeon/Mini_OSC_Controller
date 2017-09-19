// GUI creation

(
// ===== FM =====
~fm_w = Window("Frequency Modulation", Rect(807, 600, 550, 140))
.front.alwaysOnTop_(true);

~fm_onoff = Button(~fm_w, Rect(500, 5, 40, 40)).states_([
	["OFF", Color.gray(0.8), Color.gray(0.8)],
	["ON", Color.red, Color.red]
]).action_({
	| obj |
	if(obj.value == 1, {
		~synth[0] = Synth(\fm, [
			\carr, ~fm_carr_r.map(~fm_carr.value),
			\mod, ~fm_mod_r.map(~fm_mod.value),
			\dp, ~fm_dp_r.map(~fm_dp.value),
			\amp, ~fm_amp.value,
			\pan, ~pan_r.map(~fm_pan.value)
		], ~sig_group).register;
	}, { ~synth[0].free; });
});

~fm_carr = Slider(~fm_w, Rect(5, 10, 250, 30))
.value_(~fm_carr_r.unmap(~fm_carr_r.default))
.action_({
	| obj |
	var freq;
	freq = ~fm_carr_r.map(obj.value);
	freq.postln;
	~fm_carr_num.value_(freq);
	if(~synth[0].isPlaying, {
		~synth[0].set(\carr, freq);
	})
});
~fm_carr_num = NumberBox(~fm_w, Rect(260, 10, 50, 30))
.value_(~fm_carr_r.default)
.clipLo_(~fm_carr_r.minval).clipHi_(~fm_carr_r.maxval).decimals_(2)
	.action_({
		| obj |
		~fm_carr.valueAction_(~fm_carr_r.unmap(obj.value))
	});	
StaticText(~fm_w, Rect(5, 45, 250, 15)).string_("carrier frequency").align_(\center);

~fm_mod = Slider(~fm_w, Rect(5, 80, 250, 30))
.value_(~fm_mod_r.unmap(~fm_mod_r.default))
.action_({
	| obj |
	var freq;
	freq = ~fm_mod_r.map(obj.value);
	freq.postln;
	~fm_mod_num.value_(freq);
	if(~synth[0].isPlaying, {
		~synth[0].set(\mod, freq);
	})
});
~fm_mod_num = NumberBox(~fm_w, Rect(260, 80, 50, 30))
.value_(~fm_mod_r.default)
.clipLo_(~fm_mod_r.minval).clipHi_(~fm_mod_r.maxval).decimals_(2)
.action_({
	| obj |
	~fm_mod.valueAction_(~fm_mod_r.unmap(obj.value));
});
StaticText(~fm_w, Rect(5, 115, 250, 15)).string_("modulator frequency").align_(\center);

~fm_dp = Knob(~fm_w, Rect(330, 75, 40, 40))
.value_(~fm_dp_r.unmap(~fm_dp_r.default))
.action_({
	| obj |
	var dp;
	dp = ~fm_dp_r.map(obj.value);
	dp.postln;
	~fm_dp_num.value_(dp);
	if(~synth[0].isPlaying, {
		~synth[0].set(\dp, dp);
	})
});
~fm_dp_num = NumberBox(~fm_w, Rect(375, 80, 50, 30))
.value_(~fm_dp_r.default)
.clipLo_(~fm_dp_r.minval).clipHi_(~fm_dp_r.maxval).decimals_(2)
.action_({
	| obj |
	~fm_dp.valueAction_(~fm_dp_r.unmap(obj.value));
})
;
StaticText(~fm_w, Rect(330, 115, 95, 15)).string_("mod depth").align_(\center);

~fm_amp = Knob(~fm_w, Rect(330, 5, 40, 40)).value_(0.3).action_({
	| obj |
	var amp;
	amp = obj.value;
	amp.postln;
	if(~synth[0].isPlaying, {
		~synth[0].set(\amp, amp);
	})
});
StaticText(~fm_w, Rect(330, 45, 40, 15)).string_("amp").align_(\center);

~fm_pan = Knob(~fm_w, Rect(380, 5, 40, 40)).centered_(true).value_(0.5)
.action_({
	| obj |
	var pan;
	pan = ~pan_r.map(obj.value);
	pan.postln;
	if(~synth[0].isPlaying, {
		~synth[0].set(\pan, pan);
	})
});
StaticText(~fm_w, Rect(380, 45, 40, 15)).string_("pan").align_(\center);

~fm_route = PopUpMenu(~fm_w, Rect(480, 80, 60, 30))
.items_(["main", "comb", "bpf"]).value_(0).action_({
	| obj |
	if(~synth[0].isPlaying, {
		switch(obj.value,
			0, { ~synth[0].set(\out, 0) },
			1, { ~synth[0].set(\out, ~comb_bus) },
			2, { ~synth[0].set(\out, ~bpf_bus) }
		)
	})
});
StaticText(~fm_w, Rect(430, 90, 45, 15)).string_("out:").align_(\right);

// ===== GRAINS ======
~grains_w = Window("Granular", Rect(857, 313, 500, 260)).front.alwaysOnTop_(true);

~grains_file = SoundFileView(~grains_w, Rect(10, 10, 480, 70))
.soundfile_(b).read(0, b.numFrames).gridOn_(false).timeCursorOn_(true)
.setSelectionColor(0, Color.green(0.2)).setSelectionColor(1, Color.red(0.5))
.waveColors_(Color.green)
.action_({
	| obj |
	p = obj.timeCursorPosition;
	~grains_pos.valueAction_(p/b.numFrames);
	obj.setSelection(1, [
		p - ((~grains_dur_r.map(~grains_dur.value)/2) * b.sampleRate),
		~grains_dur_r.map(~grains_dur.value) * b.sampleRate
	]).setSelection(0, [
		p - ((~grains_rdp_r.map(~grains_rdp.value)/2) * b.sampleRate),
		~grains_rdp_r.map(~grains_rdp.value) * b.sampleRate
	])
});

~grains_onoff = Button(~grains_w, Rect(450, 90, 40, 40)).states_([
	["OFF", Color.gray(0.8), Color.gray(0.8)],
	["ON", Color.red, Color.red]
]).action_({
	| obj |
	if(obj.value == 1, {
		~synth[1] = Synth(\grains, [
			\buf, b,
			\dens, ~grains_dens_r.map(~grains_dens.value),
			\rate, ~grains_rate_r.map(~grains_rate.value),
			\pos, ~grains_pos.value,
			\rfreq, ~grains_rfreq_r.map(~grains_rfreq.value),
			\rdp, ~grains_rdp_r.map(~grains_rdp.value),
			\dur, ~grains_dur_r.map(~grains_dur.value),
			\pan, ~pan_r.map(~grains_pan.value),
			\amp, ~grains_amp.value,
			\out, 0
		], ~sig_group).register;
	}, { ~synth[1].free; })
});

~grains_pos = Slider(~grains_w, Rect(10, 90, 250, 30)).action_({
	| obj |
	var pos;
	pos = obj.value * b.numFrames;
	if(~synth[1].isPlaying, {
		~synth[1].set(\pos, obj.value)
	});
	~grains_file.timeCursorPosition_(pos).setSelection(1, [
		~grains_file.timeCursorPosition - ((~grains_dur_r.map(~grains_dur.value)/2) * b.sampleRate),
		~grains_dur_r.map(~grains_dur.value) * b.sampleRate
	]).setSelection(0, [
		~grains_file.timeCursorPosition - ((~grains_rdp_r.map(~grains_rdp.value)/2) * b.sampleRate),
		~grains_rdp_r.map(~grains_rdp.value) * b.sampleRate
	]);
});
StaticText(~grains_w, Rect(10, 120, 250, 15)).string_("grain position").align_(\center);

~grains_dur = Knob(~grains_w, Rect(280, 90, 30, 30))
.value_(~grains_dur_r.unmap(~grains_dur_r.default))
.action_({
	| obj |
	d = ~grains_dur_r.map(obj.value);
	d.postln;
	if(~synth[1].isPlaying, {
		~synth[1].set(\dur, d)
	});
	~grains_file.setSelection(1, [
		~grains_file.timeCursorPosition - ((d/2) * b.sampleRate),
		d * b.sampleRate
	])
});
StaticText(~grains_w, Rect(280, 120, 30, 15)).string_("dur").align_(\center);

~grains_rate = Knob(~grains_w, Rect(330, 90, 30, 30))
.value_(~grains_rate_r.unmap(~grains_rate_r.default)).centered_(true)
.action_({
	| obj |
	r = ~grains_rate_r.map(obj.value);
	r.postln;
	if(~synth[1].isPlaying, {
		~synth[1].set(\rate, r)
	});
	~grains_rate_num.value_(r)
});
~grains_rate_num = NumberBox(~grains_w, Rect(370, 90, 40, 30))
.value_(~grains_rate_r.default)
.clipLo_(~grains_rate_r.minval).clipHi_(~grains_rate_r.maxval).decimals_(2)
.action_({
	| obj |
	~grains_rate.valueAction_(~grains_rate_r.unmap(obj.value));
});
StaticText(~grains_w, Rect(330, 120, 80, 15)).string_("pb rate").align_(\center);

~grains_dens = Slider(~grains_w, Rect(10, 140, 250, 30))
.value_(~grains_dens_r.unmap(~grains_dens_r.default)).action_({
	| obj |
	d = ~grains_dens_r.map(obj.value);
	d.postln;
	if(~synth[1].isPlaying, {
		~synth[1].set(\dens, d)
	});
});
StaticText(~grains_w, Rect(10, 170, 250, 15)).string_("grains density").align_(\center);

StaticText(~grains_w, Rect(10, 207, 140, 15)).string_("randomize position:");

~grains_rfreq = Knob(~grains_w, Rect(150, 200, 30, 30))
.value_(~grains_rfreq_r.unmap(~grains_rfreq_r.default)).action_({
	| obj |
	f = ~grains_rfreq_r.map(obj.value);
	f.postln;
	if(~synth[1].isPlaying, {
		~synth[1].set(\rfreq, f)
	});
});
StaticText(~grains_w, Rect(150, 230, 30 ,15)).string_("dens").align_(\center);

~grains_rdp = Knob(~grains_w, Rect(200, 200, 30, 30))
.value_(~grains_rdp_r.unmap(~grains_rdp_r.default)).action_({
	| obj |
	d = ~grains_rdp_r.map(obj.value);
	if(~synth[1].isPlaying, {
		~synth[1].set(\rdp, d)
	});
	~grains_file.setSelection(0, [
		~grains_file.timeCursorPosition - ((d/2) * b.sampleRate),
		d * b.sampleRate
	])
});
StaticText(~grains_w, Rect(200, 230, 30, 15)).string_("dp").align_(\center);

~grains_amp = Knob(~grains_w, Rect(390, 160, 40, 40)).value_(0.5).action_({
	| obj |
	if(~synth[1].isPlaying, {
		~synth[1].set(\amp, obj.value)
	});
});
StaticText(~grains_w, Rect(390, 200, 40, 15)).string_("amp").align_(\center);

~grains_pan = Knob(~grains_w, Rect(450, 160, 40, 40))
.value_(~pan_r.unmap(~pan_r.default)).centered_(true).action_({
	| obj |
	p = ~pan_r.map(obj.value);
	p.postln;
	if(~synth[1].isPlaying, {
		~synth[1].set(\pan, p);
	})
});
StaticText(~grains_w, Rect(450, 200, 40, 15)).string_("pan").align_(\center);

~grains_route = PopUpMenu(~grains_w, Rect(420, 230, 70, 20))
.items_(["main", "comb", "bpf"]).value_(0).action_({
	| obj |
	if(~synth[1].isPlaying, {
		switch(obj.value,
			0, { ~synth[1].set(\out, 0) },
			1, { ~synth[1].set(\out, ~comb_bus) },
			2, { ~synth[1].set(\out, ~bpf_bus) }
		)
	})
});
StaticText(~grains_w, Rect(350, 235, 65, 15)).string_("out:").align_(\right);

// ==== COMB ====
~comb_w = Window("Comb filter", Rect(957, 155, 400, 130))
.front.alwaysOnTop_(true);

~comb_onoff = Button(~comb_w, Rect(350, 10, 40, 40)).states_([
	["OFF", Color.gray(0.8), Color.gray(0.8)],
	["ON", Color.red, Color.red]
]).action_({
	| obj |
	if(obj.value == 1, {
		~synth[2] = Synth(\comb, [
			\in, ~comb_bus,
			\time, ~comb_time_r.map(~comb_time.value),
			\dec, ~comb_dec_r.map(~comb_dec.value),
			\amp, ~comb_amp.value,
			\out, 0
		], ~fx_group).register;
	}, {
		[~fm_route, ~grains_route].do({ | i |
			if(i.item == "comb", { i.valueAction_(0) })
		});
		~synth[2].free;
	})
});

~comb_time = Slider(~comb_w, Rect(5, 10, 200, 30))
.value_(~comb_time_r.unmap(~comb_time_r.default))
.action_({
	| obj |
	t = ~comb_time_r.map(obj.value);
	t.postln;
	if(~synth[2].isPlaying, {
		~synth[2].set(\time, t);
	});
	~comb_time_num.value_(t);
});
~comb_time_num = NumberBox(~comb_w, Rect(210, 10, 50, 30))
.value_(~comb_time_r.default)
.clipLo_(~comb_time_r.minval).clipHi_(~comb_time_r.maxval).decimals_(3)
.action_({
	| obj |
	~comb_time.valueAction_(~comb_time_r.unmap(obj.value));
});
StaticText(~comb_w, Rect(5, 40, 200, 15)).string_("delay time").align_(\center);

~comb_dec = Slider(~comb_w, Rect(5, 70, 200, 30)).action_({
	| obj |
	c = ~comb_dec_r.map(obj.value);
	c.postln;
	if(~synth[2].isPlaying, {
		~synth[2].set(\dec, c);
	});
	~comb_dec_num.value_(c);
});
~comb_dec_num = NumberBox(~comb_w, Rect(210, 70, 50, 30))
.value_(~comb_dec_r.default)
.clipLo_(~comb_dec_r.minval).clipHi_(~comb_dec_r.maxval).decimals_(3)
.action_({
	| obj |
	~comb_dec.valueAction_(~comb_dec_r.unmap(obj.value));
})
;
StaticText(~comb_w, Rect(5, 100, 200, 15)).string_("decay time").align_(\center);

~comb_amp = Knob(~comb_w, Rect(280, 5, 40, 40)).value_(1).action_({
	| obj |
	obj.value.postln;
	if(~synth[2].isPlaying, {
		~synth[2].set(\amp, obj.value);
	});
});
StaticText(~comb_w, Rect(280, 45, 40, 15)).string_("amp").align_(\center);

~comb_route = PopUpMenu(~comb_w, Rect(330, 70, 60, 30))
.items_(["main", "bpf"]).value_(0).action_({
	| obj |
	if(~synth[2].isPlaying, {
		switch(obj.value,
			0, { ~synth[2].set(\out, 0) },
			1, { ~synth[2].set(\out, ~bpf_bus) }
		)
	})
});
StaticText(~comb_w, Rect(280, 80, 45, 15)).string_("out:").align_(\right);

// ===== BPF =====
~bpf_w = Window("Band Pass Filter", Rect(547, 125, 400, 160)).front.alwaysOnTop_(true);

~bpf_onoff = Button(~bpf_w, Rect(350, 5, 40, 40)).states_([
	["OFF", Color.gray(0.8), Color.gray(0.8)],
	["ON", Color.red, Color.red]
]).action_({
	| obj |
	if(obj.value == 1, {
		~synth[3] = Synth(\bpf, [
			\in, ~bpf_bus,
			\freq, ~bpf_freq_r.map(~bpf_freq.value),
			\rq, ~bpf_rq_r.map(~bpf_rq.value),
			\mfreq, ~bpf_mfreq_r.map(~bpf_mfreq.value),
			\mdp, ~bpf_mdp_r.map(~bpf_mdp.value),
			\out, 0
		], ~fx_group, \addToTail).register;
	}, {
		[~fm_route, ~grains_route, ~comb_route].do({ | i |
			if(i.item == "bpf", { i.valueAction_(0) })
		});
		~synth[3].free;
	})
});

~bpf_freq = Slider(~bpf_w, Rect(5, 5, 250, 30))
.value_(~bpf_freq_r.unmap(~bpf_freq_r.default))
.action_({
	| obj |
	var freq;
	freq = ~bpf_freq_r.map(obj.value);
	freq.postln;
	if(~synth[3].isPlaying, {
		~synth[3].set(\freq, freq);
	});
	~bpf_freq_num.value_(freq);
});
~bpf_freq_num = NumberBox(~bpf_w, Rect(260, 5, 50, 30))
.value_(~bpf_freq_r.default)
.clipLo_(~bpf_freq_r.minval).clipHi_(~bpf_freq_r.maxval).decimals_(2)
.action_({
	| obj |
	~bpf_freq.valueAction_(~bpf_freq_r.unmap(obj.value));
});
StaticText(~bpf_w, Rect(5, 35, 250, 15)).string_("frequency").align_(\center);

~bpf_rq = Knob(~bpf_w, Rect(5, 70, 40, 40)).action_({
	| obj |
	var rq;
	rq = ~bpf_rq_r.map(obj.value);
	rq.postln;
	if(~synth[3].isPlaying, {
		~synth[3].set(\rq, rq);
	});
	~bpf_rq_num.value_(rq);
});
~bpf_rq_num = NumberBox(~bpf_w, Rect(50, 75, 50, 30))
.value_(~bpf_rq_r.default)
.clipLo_(~bpf_rq_r.minval).clipHi_(~bpf_rq_r.maxval)
.action_({
	| obj |
	~bpf_rq.valueAction_(~bpf_rq_r.unmap(obj.value));
});
StaticText(~bpf_w, Rect(5, 110, 100, 15)).string_("rq value").align_(\center);

~bpf_mfreq = Slider(~bpf_w, Rect(130, 70, 150, 20)).action_({
	| obj |
	var m_freq;
	m_freq = ~bpf_mfreq_r.map(obj.value);
	m_freq.postln;
	~synth[3].set(\mfreq, m_freq);
	~bpf_mfreq_num.value_(m_freq);
});
~bpf_mfreq_num = NumberBox(~bpf_w, Rect(285, 70, 50, 20))
.value_(~bpf_mfreq_r.default)
.clipLo_(~bpf_mfreq_r.minval).clipHi_(~bpf_mfreq_r.maxval).decimals_(2)
.action_({
	| obj |
	~bpf_mfreq.valueAction_(~bpf_mfreq_r.unmap(obj.value));
});
StaticText(~bpf_w, Rect(130, 90, 150, 15)).string_("mod frequency").align_(\center);

~bpf_mdp = Slider(~bpf_w, Rect(130, 115, 150, 20))
.action_({
	| obj |
	var mdp = ~bpf_mdp_r.map(obj.value);
	mdp.postln;
	if(~synth[3].isPlaying, {
		~synth[3].set(\mdp, mdp);
	});
	~bpf_mdp_num.value_(mdp);
});
~bpf_mdp_num = NumberBox(~bpf_w, Rect(285, 115, 50, 20))
.value_(~bpf_mdp_r.default)
.clipLo_(~bpf_mdp_r.minval).clipHi_(~bpf_mdp_r.maxval).decimals_(2)
.action_({
	| obj |
	~bpf_mdp.valueAction_(~bpf_mdp_r.unmap(obj.value));
});
StaticText(~bpf_w, Rect(130, 135, 150, 15)).string_("mod depth").align_(\center);

// monitor
~monitor_w = Window("Monitor", Rect(597, 314, 250, 70))
.front.alwaysOnTop_(true);

StaticText(~monitor_w, Rect(5, 5, 150, 15)).string_("synth and parameter:");
~monitor = StaticText(~monitor_w, Rect(5, 30, 150, 30))
.string_("fm=>carr").align_(\center).background_(Color.white);

~monitor_osc = StaticText(~monitor_w, Rect(160, 30, 100, 30)).string_("OSC OFF").align_(\center)
)
