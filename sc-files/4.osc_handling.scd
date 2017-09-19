// 

(
OSCdef(\monitor, {
	| msg |
	var str;
	msg.postln;
	str = msg[1] ++ "=>" ++ msg[2];
	{~monitor.string_(str)}.defer;
}, '/monitor');

OSCdef(\onoff, {
	| msg |
	var cmd;
	msg.postln;
	{
		v = ("~" ++ msg[1] ++ "_onoff.value").interpret;
		v = v.asBoolean.not.asInteger;
		cmd = "~" ++ msg[1] ++ "_onoff.valueAction_(" ++ v ++ ")";
		cmd.interpret;
	}.defer;
}, '/onoff');

OSCdef(\route, {
	| msg |
	var cmd;
	msg.postln;
	if (msg[1] !== "bpf", {
		{
			v = ("~" ++ msg[1] ++ "_route.item").interpret;
			if (v == "bpf",
				{ n = "0" },
				{ n = "~" ++ msg[1] ++ "_route.value + 1" }
			);
			cmd = "~" ++ msg[1] ++ "_route.valueAction_(" ++ n ++ ")";
			cmd.interpret
		}.defer;
	});
}, '\route');

OSCdef(\change_params, {
	| msg |
	var val, cmd, v_name;
	msg.postln;
	v_name = "~" ++ msg[1] ++ "_" ++ msg[2];
	val = msg[3].explin(400, 726, 0, 1);
	cmd =  v_name ++ ".valueAction_(" ++ val ++ ")";
	{cmd.interpret}.defer;
}, '/sensor');
)