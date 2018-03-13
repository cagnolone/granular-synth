
(
var sedit1, sedit2, sedit3, sedit4;

QtGUI.palette = QPalette.dark;

//------------------------------------------------------------FIRST SYNTH--------------------------------------------
(
SynthDef(\granularDry,
	{   arg sndbuf,trig=10,dur=0.05, startRate=0.5, endRate=2,startPos=0.0,endPos=1.0,freqPos=0.1,interp=1, freqPan=3,gate=1, envbufnum= -1, amp=1, master = 1;
		var sig, env;

		sig = GrainBuf.ar(2, //stereo signal
			trigger: Impulse.kr(trig),
			dur: dur,
			sndbuf: sndbuf,
			rate: startRate,
			pos:  startPos,
			interp: interp,
			envbufnum: envbufnum,
			pan: LFNoise1.kr(freqPan));

		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		sig = sig*env;
		Out.ar(0,sig*amp*master
	);
		Out.ar(10,sig)
}).add;
);

//---------------------------------------------------------SECOND SYNTH---------------------------------------------
(
SynthDef(\granularSandy,
	{   arg sndbuf,trig=10,dur=0.05, startRate=0.5, endRate=2,startPos=0.0,endPos=1.0,freqPos=0.1,interp=1, freqPan=3,gate=1, envbufnum= -1, amp=1, master = 1;
		var sig, env;

		sig = GrainBuf.ar(2, //stereo signal
			trigger: Blip.kr(trig),
			dur: dur,
			sndbuf: sndbuf,
			rate: startRate,
			pos:  startPos,
			interp: interp,
			envbufnum: envbufnum,
			pan: LFNoise1.kr(freqPan));

		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		sig = sig*env;
		Out.ar(0,sig*amp*master
	);
		Out.ar(12,sig)
}).add;
);

//------------------------------------------------------------THIRD SYNTH--------------------------------------------
(
SynthDef(\granularDryLFO,
	{   arg sndbuf,trig=10,dur=0.05, startRate=0.5, endRate=2,startPos=0.0,endPos=1.0,freqPos=0.1,interp=1, freqPan=3,gate=1, envbufnum= -1, amp=1, master=1;
		var sig, env;

		sig = GrainBuf.ar(2, //stereo signal
			trigger: Impulse.kr(trig),
			dur: dur,
			sndbuf: sndbuf,
			rate: LFNoise1.kr.range(startRate,endRate),
			pos:  LFNoise2.kr(freqPos).range(startPos,endPos),
			interp: interp,
			envbufnum: envbufnum,
			pan: LFNoise1.kr(freqPan));

		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		sig = sig*env;
		Out.ar(0,sig*amp*master
	);
		Out.ar(14,sig)
}).add;
);

//------------------------------------------------------------FOURTH SYNTH--------------------------------------------

(
SynthDef(\granularSandyLFO,
	{   arg sndbuf,trig=10,dur=0.05, startRate=0.5, endRate=2,startPos=0.0,endPos=1.0,freqPos=0.1,interp=1, freqPan=3,gate=1, envbufnum= -1, amp = 1, master=1;
		var sig, env;

		sig = GrainBuf.ar(2, //stereo signal
			trigger: Blip.kr(trig),
			dur: dur,
			sndbuf: sndbuf,
			rate: LFNoise1.kr.range(startRate,endRate),
			pos:  LFNoise2.kr(freqPos).range(startPos,endPos),
			interp: interp,
			envbufnum: envbufnum,
			pan: LFNoise1.kr(freqPan));

		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		sig = sig*env;
		Out.ar(0,sig*amp*master
	);
		Out.ar(16,sig)
}).add;
);
//----------------------------------------------GUI INIZIALIZATION------------------------------------------------------



Window.closeAll;
w = Window.new.visible_(false);

(
~windsig = [-1,
	{ Buffer.loadCollection(s, Env([0, 1, 1, 0], [0.01, 0.98, 0.01], [5, -5]).discretize(1024)).bufnum }, //square wave
	{ Buffer.loadCollection(s, Env([0, 1, 0], [0.5, 0.05], [5, -5]).discretize(1024)).bufnum } //triangular
	]
);

//-----------------------------------------------GUI FOR THE FIRST---------------------------------------------------------
~title1 = StaticText().stringColor_(Color.yellow)
.string_("DRY STATIC GRANULAR SYNTH")
.align_(\center)
.font_(Font.new("Helvetica", 20));

sedit1 = SoundFileView();
~loadButton1 = Button.new()
            .states_([["Sample Load",Color.black,Color.new255(95, 300, 200)]])
            .action_({
                      File.openDialog("",{|path| ~buffer1 = Buffer.read(s,path);
                                                 ~sfile1 = SoundFile.openRead(path);
                                              sedit1.soundfile = ~sfile1;
                                              sedit1.read(0,~sfile1.numFrames);
                                              sedit1.refresh; });
	                     });

~buttonOnOff1 = Button.new()
.states_([
	["off", Color.gray(0.2), Color.gray(0.8)],
	["on", Color.black, Color.new(0,1,0.5)]
])
.font_(Font.new("Helvetica", 32))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			~synth1 = Synth(\granularDry,[
				\trig,
				~knobDensity1.value.linlin(0,1,1,20),
				\sndbuf,
				~buffer1.bufnum,
				\startPos,
				~sliderStartPos1.value,
				\dur,
				~sliderDur1.value.linlin(0,1,0.005,0.1),
				\startRate,
				1,
				\interp,
				~interp1.value+1,
				\envbufnum,
				~windsig[~envbufnum1.value].value,
				\amp,
				((1-~mixer.x) + (~mixer.y)).linexp(0,2,0.01,0.9),
				\master,
				~master.value.linexp(0,1,0.001,0.8)
			]).register;
		},
		{~synth1.set(\gate, 0)}
	);
});

(
~sliderDur1 = Slider.new()
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth1.isPlaying,
		{

			~synth1.set(\dur, obj.value.linlin(0,1,0.005,0.1));
			obj.value.linlin(0,1,0.005,0.1).postln;
	})
    });
    );

~titleLength1 = StaticText().stringColor_(Color.yellow)
.string_("lenght of the grain")
.align_(\center);

~knobDensity1 = Knob()
.action_({
	arg obj;
	if(
		~synth1.isPlaying,
		{
			~synth1.set(\trig, obj.value.linlin(0,1,1,20));
		}
	);
});

~titleDensity1 = StaticText().stringColor_(Color.yellow)
.string_("density")
.align_(\center);

(
~sliderStartPos1 = Slider()
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth1.isPlaying,
		{
			~synth1.set(\startPos, obj.value);
			obj.value.postln;
	})
    });
    );

~titleStart1 = StaticText().stringColor_(Color.yellow)
.string_("starting point of the grain")
.align_(\center);

~knobStartRate1 = Knob(w, Rect(400,250,80,80))
.action_({
	arg obj;
	if(
		~synth1.isPlaying,
		{
			~synth1.set(\startRate, obj.value.linexp(0,1,0.5,5).postln);
		},
	);
});

~titleRate1 = StaticText().stringColor_(Color.yellow)
.string_("pitch")
.align_(\center);

~interp1 = PopUpMenu()
.items = [
	"no interpolation", "linear interpolation", "quadratic", "cubic"
];

~interp1.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth1.isPlaying,
		{
			~synth1.set(\interp, menu.value + 1);
			(menu.value+1).postln;
		}
	);
};

~envbufnum1 = PopUpMenu()
.items = [
 "hanning", "square", "tri"];


~envbufnum1.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth1.isPlaying,
		{
			~synth1.set(\envbufnum,~windsig[~envbufnum1.value].value);
			~envbufnum1.value.postln;
		}
	);
};

~w1 = Window.new().layout_(
	GridLayout.rows( [nil, ~title1, nil],
		[~interp1, StackLayout(~sliderStartPos1.orientation_(\horizontal), sedit1 ).mode_(\stackAll), ~loadButton1],
		[~sliderDur1.orientation_(\horizontal),nil,~buttonOnOff1],
		[~titleLength1, ~titleStart1, ~envbufnum1],
		[~knobDensity1,~knobStartRate1,nil],
		[~titleDensity1,~titleRate1,nil]
).setMinRowHeight(0,8).setMinRowHeight(4,8)).front;

//-----------------------------------------------GUI FOR THE SECOND---------------------------------------------------------

~title2 = StaticText(w, Rect(950,20,900,100)).stringColor_(Color.new255(0,255,255))
.string_("SANDY STATIC GRANULAR SYNTH")
.align_(\center)
.font_(Font.new("Helvetica", 20));

sedit2 = SoundFileView(w,Rect(1020,120,700,80));
~loadButton2 = Button.new(w,Rect(1740,120,150,100))
            .states_([["Sample Load",Color.black,Color.new255(95, 300, 200)]])
            .action_({
                      File.openDialog("",{|path| ~buffer2 = Buffer.read(s,path);
                                                 ~sfile2 = SoundFile.openRead(path);
                                              sedit2.soundfile = ~sfile2;
                                              sedit2.read(0,~sfile2.numFrames);
                                              sedit2.refresh; });
	                     });

~buttonOnOff2 = Button.new(w, Rect(1930,150,40,40))
.states_([
	["off", Color.gray(0.2), Color.gray(0.8)],
	["on", Color.black, Color.new(0,1,0.5)]
])
.font_(Font.new("Helvetica", 32))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			~synth2 = Synth(\granularSandy,[
				\trig,
				~knobDensity2.value.linlin(0,1,1,20),
				\sndbuf,
				~buffer2.bufnum,
				\startPos,
				~sliderStartPos2.value,
				\dur,
				~sliderDur2.value.linlin(0,1,0.005,0.1),
				\startRate,
				1,
				\interp,
				~interp2.value+1,
				\envbufnum,
				~windsig[~envbufnum2.value].value,
				\amp,
				(~mixer.x + ~mixer.y).linexp(0,2,0.01,0.9),
				\master,
				~master.value.linexp(0,1,0.001,0.8)
			]).register;
		},
		{~synth2.set(\gate, 0)}
	);
});

(
~sliderDur2 = Slider.new(w,Rect(1020,300,200,20))
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth2.isPlaying,
		{
				~synth2.set(\dur, obj.value.linlin(0,1,0.005,0.1));
				obj.value.linlin(0,1,0.005,0.1).postln;
	})
    });
    );

~titleLength2 = StaticText(w, Rect(1010,320,200,50)).stringColor_(Color.new255(0,255,255))
.string_("lenght of the grain")
.align_(\center);

~knobDensity2 = Knob(w, Rect(1300,250,80,80))
.action_({
	arg obj;
	if(
		~synth2.isPlaying,
		{
			~synth2.set(\trig, obj.value.linlin(0,1,1,20));
		}
	);
});

~titleDensity2 = StaticText(w, Rect(1300,330,80,50)).stringColor_(Color.new255(0,255,255))
.string_("density")
.align_(\center);

(
~sliderStartPos2 = Slider(w, Rect(1020, 120, 700, 80))
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth2.isPlaying,
		{
			~synth2.set(\startPos, obj.value);
			obj.value.postln;
	})
    });
    );

~titleStart2 = StaticText(w, Rect(1100,200,500,50)).stringColor_(Color.new255(0,255,255))
.string_("starting point of the grain")
.align_(\center);

~knobStartRate2 = Knob(w, Rect(1400,250,80,80))
.action_({
	arg obj;
	if(
		~synth2.isPlaying,
		{
			~synth2.set(\startRate, obj.value.linexp(0,1,0.5,5));
		}
	);
});

~titleRate2 = StaticText(w, Rect(1400,330,80,50)).stringColor_(Color.new255(0,255,255))
.string_("pitch")
.align_(\center);

~interp2 = PopUpMenu(w, Rect(1550, 280, 180, 50))
.items = [
	"no interpolation", "linear interpolation", "quadratic", "cubic"
];

~interp2.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth2.isPlaying,
		{
			~synth2.set(\interp, menu.value + 1);
			(menu.value+1).postln;
		}
	);
};

~envbufnum2 = PopUpMenu(w, Rect(1750, 280, 180, 50))
.items = [
 "hanning", "square", "tri"];

~envbufnum2.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth2.isPlaying,
		{
			~synth2.set(\envbufnum,~windsig[~envbufnum2.value].value);
			~envbufnum2.value.postln;
		}
	);
};

~w2 = Window.new().layout_(
	GridLayout.rows( [nil, ~title2, nil],
		[~interp2, StackLayout(~sliderStartPos2.orientation_(\horizontal), sedit2 ).mode_(\stackAll), ~loadButton2],
		[~sliderDur2.orientation_(\horizontal), nil, ~buttonOnOff2],
		[~titleLength2, ~titleStart2, ~envbufnum2],
		[~knobDensity2,~knobStartRate2,nil],
		[~titleDensity2,~titleRate2,nil]
).setMinRowHeight(0,8).setMinRowHeight(4,8)).front;

//-----------------------------------------------GUI FOR THE THIRD---------------------------------------------------------

~title3 = StaticText(w, Rect(50,430,700,100)).stringColor_(Color.new255(0,255,0))
.string_("DRY GENERATIVE GRANULAR SYNTH")
.align_(\center)
.font_(Font.new("Helvetica", 20));

sedit3 = SoundFileView(w,Rect(20,520,700,80));
~loadButton3 = Button.new(w,Rect(740,520,150,100))
            .states_([["Sample Load",Color.black,Color.new255(95, 300, 200)]])
            .action_({
                      File.openDialog("",{|path| ~buffer3 = Buffer.read(s,path);
                                                 ~sfile3 = SoundFile.openRead(path);
                                              sedit3.soundfile = ~sfile3;
                                              sedit3.read(0,~sfile3.numFrames);
                                              sedit3.refresh; });
	                     });

~buttonOnOff3 = Button.new(w, Rect(930,550,40,40))
.states_([
	["off", Color.gray(0.2), Color.gray(0.8)],
	["on", Color.black, Color.new(0,1,0.5)]
])
.font_(Font.new("Helvetica", 32))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			~synth3 = Synth(\granularDryLFO,[
				\trig,
				~knobDensity3.value.linlin(0,1,1,20),
				\sndbuf,
				~buffer3.bufnum,
				\startPos,
				~sliderStartPos3.lo,
				\endPos,
				~sliderStartPos3.hi,
				\dur,
				~sliderDur3.value.linlin(0,1,0.005,0.1),
				\startRate,
				1,
				\endRate,
				1,
				\interp,
				~interp3.value+1,
				\envbufnum,
				~windsig[~envbufnum3.value].value,
				\amp,
				(1-~mixer.x + 1-~mixer.y).linexp(0,2,0.01,0.9),
				\master,
				~master.value.linexp(0,1,0.001,0.8)
			]).register;
		},
		{~synth3.set(\gate, 0)}
	);
});

(
~sliderDur3 = Slider.new(w,Rect(20,700,200,20))
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth3.isPlaying,
		{
				~synth3.set(\dur, obj.value.linlin(0,1,0.005,0.1));
				obj.value.linlin(0,1,0.005,0.1).postln;
	})
    });
    );

~titleLength3 = StaticText(w, Rect(10,720,200,50)).stringColor_(Color.new255(0,255,0))
.string_("lenght of the grain")
.align_(\center);

~knobDensity3 = Knob(w, Rect(300,650,80,80))
.action_({
	arg obj;
	if(
		~synth3.isPlaying,
		{
			~synth3.set(\trig, obj.value.linlin(0,1,1,20));
		}
	);
});

~titleDensity3 = StaticText(w, Rect(300,730,80,50)).stringColor_(Color.new255(0,255,0))
.string_("density")
.align_(\center);

(
~sliderStartPos3 = RangeSlider(w, Rect(20, 520, 700, 80))
    .lo_(0.0)
    .hi_(1.0)
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth3.isPlaying,
		{
			~synth3.set(\startPos, obj.lo, \endPos, obj.hi);
	})
    });
);

~titleStart3 = StaticText(w, Rect(100,600,500,50)).stringColor_(Color.new255(0,255,0))
.string_(" range of starting point of the grain")
.align_(\center);

~knobStartRate3 = Knob(w, Rect(400,650,80,80))
.action_({
	arg obj;
	if(
		~synth3.isPlaying,
		{
			~synth3.set(\startRate, obj.value.linexp(0,1,0.5,2));
		}
	);
});

~titleLowLimit3 = StaticText(w, Rect(400,730,80,50)).stringColor_(Color.new255(0,255,0))
.string_("low limit pitch")
.align_(\center);

~knobEndRate3 = Knob(w, Rect(400,780,80,80))
.action_({
	arg obj;
	if(
		~synth3.isPlaying,
		{
			~synth3.set(\endRate, obj.value.linexp(0,1,2,5));
		}
	);
});

~titleHighLimit3 = StaticText(w, Rect(390,860,100,50)).stringColor_(Color.new255(0,255,0))
.string_("high limit pitch")
.align_(\center);

~interp3 = PopUpMenu(w, Rect(550, 680, 180, 50))
.items = [
	"no interpolation", "linear interpolation", "quadratic", "cubic"
];

~interp3.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth3.isPlaying,
		{
			~synth3.set(\interp, menu.value + 1);
			(menu.value+1).postln;
		}
	);
};

~envbufnum3 = PopUpMenu(w, Rect(750, 680, 180, 50))
.items = [
 "hanning", "square", "tri"];

~envbufnum3.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth3.isPlaying,
		{
			~synth3.set(\envbufnum,~windsig[~envbufnum3.value].value);
			~envbufnum3.value.postln;
		}
	);
};

~w3 = Window.new().layout_(
	GridLayout.rows( [nil, ~title3, nil],
		[~interp3, StackLayout(~sliderStartPos3.orientation_(\horizontal), sedit3 ).mode_(\stackAll), ~loadButton3],
		[~sliderDur3.orientation_(\horizontal), nil ,~buttonOnOff3],
		[~titleLength3, ~titleStart3, ~envbufnum3],
		[~knobDensity3,~knobStartRate3,~knobEndRate3],
		[~titleDensity3,~titleLowLimit3,~titleHighLimit3]
).setMinRowHeight(0,8).setMinRowHeight(4,8)).front;

//-----------------------------------------------GUI FOR THE FOURTH---------------------------------------------------------

~title4 = StaticText().stringColor_(Color.red)
.string_("SANDY GENERATIVE GRANULAR SYNTH")
.align_(\center)
.font_(Font.new("Helvetica", 20));

sedit4 = SoundFileView(w,Rect(1020,520,700,80));
~loadButton4 = Button.new()
            .states_([["Sample Load",Color.black,Color.new255(95, 300, 200)]])
            .action_({
                      File.openDialog("",{|path| ~buffer4 = Buffer.read(s,path);
                                                 ~sfile4 = SoundFile.openRead(path);
                                              sedit4.soundfile = ~sfile4;
                                              sedit4.read(0,~sfile4.numFrames);
                                              sedit4.refresh; });
	                     });

~buttonOnOff4 = Button.new()
.states_([
	["off", Color.gray(0.2), Color.gray(0.8)],
	["on", Color.black, Color.new(0,1,0.5)]
])
.font_(Font.new("Helvetica", 32))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
				~synth4 = Synth(\granularSandyLFO,[
				\trig,
				~knobDensity4.value.linlin(0,1,1,20),
				\sndbuf,
				~buffer4.bufnum,
				\startPos,
				~sliderStartPos4.lo,
				\endPos,
				~sliderStartPos4.hi,
				\dur,
				~sliderDur4.value.linlin(0,1,0.005,0.1),
				\startRate,
				1,
				\endRate,
				1,
				\interp,
				~interp4.value+1,
				\envbufnum,
				~windsig[~envbufnum4.value].value,
				\amp,
				(~mixer.x + (1-~mixer.y)).linexp(0,2,0.01,0.9),
				\master,
				~master.value.linexp(0,1,0.001,0.8)
			]).register;
		},
		{~synth4.set(\gate, 0)}
	);
});

(
~sliderDur4 = Slider.new()
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth4.isPlaying,
		{
				~synth4.set(\dur, obj.value.linlin(0,1,0.005,0.1));
				obj.value.linlin(0,1,0.005,0.1).postln;
	})
    });
    );

~titleLength4 = StaticText().stringColor_(Color.red)
.string_("lenght of the grain")
.align_(\center);

~knobDensity4 = Knob()
.action_({
	arg obj;
	if(
		~synth4.isPlaying,
		{
			~synth4.set(\trig, obj.value.linlin(0,1,1,20));
		}
	);
});

~titleDensity4 = StaticText().stringColor_(Color.red)
.string_("density")
.align_(\center);

(
~sliderStartPos4 = RangeSlider()
    .lo_(0.0)
    .hi_(1.0)
    .background_(Color.clear)
    .knobColor_(Color.clear)
    .action_({
	arg obj;
		if(
		~synth4.isPlaying,
		{
			~synth4.set(\startPos, obj.lo, \endPos, obj.hi);
	})
    });
);

~titleStart4 = StaticText().stringColor_(Color.red)
.string_(" range of starting point of the grain")
.align_(\center);

~knobStartRate4 = Knob()
.action_({
	arg obj;
	if(
		~synth4.isPlaying,
		{
			~synth4.set(\startRate, obj.value.linexp(0,1,0.5,2));
		}
	);
});

~titleLowLimit4 = StaticText().stringColor_(Color.red)
.string_("low limit pitch")
.align_(\center);

~knobEndRate4 = Knob()
.action_({
	arg obj;
	if(
		~synth4.isPlaying,
		{
			~synth4.set(\endRate, obj.value.linexp(0,1,2,5));
		}
	);
});

~titleHighLimit4 = StaticText().stringColor_(Color.red)
.string_("high limit pitch")
.align_(\center);

~interp4 = PopUpMenu()
.items = [
	"no interpolation", "linear interpolation", "quadratic", "cubic"
];

~interp4.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth4.isPlaying,
		{
			~synth4.set(\interp, menu.value + 1);
			(menu.value+1).postln;
		}
	);
};

~envbufnum4 = PopUpMenu()
.items = [
 "hanning", "square", "tri"];

~envbufnum4.background_(Color.green(0.7))  // only changes the look of displayed item
.stringColor_(Color.white)   // only changes the look of displayed item
.action = { arg menu;
	if(
		~synth4.isPlaying,
		{
			~synth4.set(\envbufnum,~windsig[~envbufnum4.value].value);
			~envbufnum4.value.postln;
		}
	);
};

~w4 = Window.new().layout_(
	GridLayout.rows( [nil, ~title4, nil],
		[~interp4, StackLayout(~sliderStartPos4.orientation_(\horizontal), sedit4 ).mode_(\stackAll),~loadButton4],
		[~sliderDur4.orientation_(\horizontal), nil ,~buttonOnOff4],
		[~titleLength4, ~titleStart4, ~envbufnum4],
		[~knobDensity4,~knobStartRate4,~knobEndRate4],
		[~titleDensity4,~titleLowLimit4,~titleHighLimit4]
).setMinRowHeight(0,8).setMinRowHeight(4,8)).front;

//------------------------------------------------------MIXER---------------------------------------------

~mixer = Slider2D()
.x_(0.5)
.y_(0.5)
.background_(Color.new255(0,255,0).blend(Color.yellow, blend:0.5).blend(Color.red.blend(Color.new255(0,255,255), blend:0.5), blend:0.5))
.action = { arg mixer;
	if(
		~synth1.isPlaying,
		{
			~synth1.set(\amp,((1-mixer.x) + (mixer.y)).linexp(0,2,0.01,0.9));

		}
	);
	if(
		~synth2.isPlaying,
		{
			~synth2.set(\amp,(mixer.x + mixer.y).linexp(0,2,0.01,0.9));

		}
	);
	if(
		~synth3.isPlaying,
		{
			~synth3.set(\amp,(1-mixer.x + 1-mixer.y).linexp(0,2,0.01,0.9));

		}
	);
	if(
		~synth4.isPlaying,
		{
			~synth4.set(\amp,(mixer.x + (1-mixer.y)).linexp(0,2,0.01,0.9));

		}
	);
	mixer.background_(Color.new255(0,255,0).blend(Color.yellow, blend:mixer.y).blend(Color.red.blend(Color.new255(0,255,255), blend:mixer.y), blend: mixer.x))

}
;

~titleMaster = StaticText().string_("master volume").alpha_(0.1).align_(\center);

~master = Knob()
.action = { arg master;
	if(
		~synth1.isPlaying,
		{
			~synth1.set(\master,master.value.linexp(0,1,0.001,0.8));

		}
	);
	if(
		~synth2.isPlaying,
		{
			~synth2.set(\master,master.value.linexp(0,1,0.001,0.8));

		}
	);
	if(
		~synth3.isPlaying,
		{
			~synth3.set(\master,master.value.linexp(0,1,0.001,0.8));

		}
	);
	if(
		~synth4.isPlaying,
		{
			~synth4.set(\master,master.value.linexp(0,1,0.001,0.8));

		}
	);
};

~leg1 = StaticText()
.string_("Synth 1")
.align_(\center)
.stringColor_(Color.yellow);

~leg2 = StaticText()
.string_("Synth 2")
.align_(\center)
.stringColor_(Color.new255(0,255,255));

~leg3 = StaticText()
.string_("Synth 3")
.align_(\center)
.stringColor_(Color.new255(0,255,0));

~leg4 = StaticText()
.string_("Synth 4")
.align_(\center)
.stringColor_(Color.red);

//-------------------------------------------------------SPECTROGRAM--------------------------------------

~spectro = GranularSpectrogram4c.new(w);

~spectroOnOff = Button.new()
.states_([
	["spectrogram off", Color.gray(0.2), Color.gray(0.8)],
	["spectrogram on", Color.black, Color.new(0,1,0.5)]
])
.font_(Font.new("Helvetica", 32))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			~spectro.start;
		},
		{~spectro.stop;}
	);
});

(
~wfinal=Window.new("GRAAAAAAAAAAAAAAAAAAAAINS").front.layout_(
	GridLayout.rows (
		[~w1,
			~w2,],
		[~w3,
			~w4],
		[~spectro.asView.minSize = 80@50, VLayout(
			HLayout
			(HLayout
				(GridLayout.rows (
					[~leg1, ~leg2,],
					[~leg3,	~leg4]), ~spectroOnOff),
			VLayout( ~master, ~titleMaster )), ~mixer.minSize_(45@45)),w]

	)
).front
.alwaysOnTop_(true)
);


//-----------------------------------------------------------GUI CLEANING-----------------------------------

~wfinal.onClose_{ // clean up when window is closed
	~synth1.free;
	~synth2.free;
	~synth3.free;
	~synth4.free;
	if(
		(~spectro.isRunning1 || ~spectro.isRunning2 || ~spectro.isRunning3 || ~spectro.isRunning4),
		{
			~spectro.stop;
		}
	);
	Buffer.freeAll };

)
