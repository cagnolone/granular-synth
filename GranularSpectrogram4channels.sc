// Put this file in the Extensions folder and recompile class library

GranularSpectrogram4c {
	classvar <server;
	var window;
	var inbus1, inbus2, inbus3, inbus4;
	var <fftbuf1, fftDataArray1, fftSynth1, <fftbuf2, fftDataArray2, fftSynth2;
	var <fftbuf3, fftDataArray3, fftSynth3, <fftbuf4, fftDataArray4, fftSynth4;
	var <>rate;
	var <bufSize, binfreqs;	// bufSize is the size for the fft window
	var <frombin, <tobin;
	var image, imgWidth, imgHeight, index, <>intensity, runtask1, runtask2,  runtask3, runtask4;
	var color1, color2, color3, color4, background, colints1, colints2, colints3, colints4; // colints is an array of integers each representing a color
	var userview, mouseX, mouseY, freq, drawCrossHair = false;
	var crosshaircolor, running1, running2, running3, running4;

	*new { arg parent, bounds, bufSize, color, background, lowfreq=0, highfreq=inf;
		^super.new.initSpectrogram(parent, bounds, bufSize, color, background, lowfreq, highfreq);
	}

	initSpectrogram { arg parent, boundsarg, bufSizearg, col, bg, lowfreqarg, highfreqarg;
		server = Server.default; // get the server
		inbus1 = 10; // inbus for audio analysis
		inbus2 = 12;
		inbus3 = 14;
		inbus4 = 16;
		rate = 25; // updates per second
		bufSize = bufSizearg ? 1024; // fft window, take either argument or 1024
		fftbuf1 = Buffer.alloc(server, bufSize); // allocation of memory for the fft computation, in the server and of bufSize frames
		fftbuf2 = Buffer.alloc(server, bufSize);
		fftbuf3 = Buffer.alloc(server, bufSize);
		fftbuf4 = Buffer.alloc(server, bufSize);
		binfreqs = bufSize.collect({|i| ((44100/2)/bufSize)*(i+1)}); // choose how many bins for each freq
		index = 0;
		intensity = 1; // intensity of the drawing
		background = bg ? Color.black; // color of background
		color1 = Color.yellow; // white, color of the drawing
		color2 = Color.new255(0,255,255);
		color3 = Color.new255(0,255,0);
		color4 = Color.red;
		crosshaircolor = Color.white;
		tobin = min(binfreqs.indexOf((highfreqarg/2).nearestInList(binfreqs)), bufSize.div(2) - 1); // maximum frequency bin of analysis
		frombin = max(binfreqs.indexOf((lowfreqarg/2).nearestInList(binfreqs)), 0); // minimum frequncy bin of analysis
		fftDataArray1 = Int32Array.fill((tobin - frombin + 1), 0); // create the integer array for the fft data
		fftDataArray2 = Int32Array.fill((tobin - frombin + 1), 0);
		fftDataArray3 = Int32Array.fill((tobin - frombin + 1), 0);
		fftDataArray4 = Int32Array.fill((tobin - frombin + 1), 0);
		running1 = false; // set starting state to NotRunning
		running2 = false;
		running3 = false;
		running4 = false;
		this.sendSynthDef;
		this.createWin(parent, boundsarg); // create the view
	}

	createWin {arg parent, boundsarg;
		var bounds;
		window = parent ? Window("Spectrogram",  Rect(200, 450, 600, 300)); // create the view either on the parent or a new window
		bounds = boundsarg ? window.view.bounds; // take the bounds argument or resize through proper window
		this.setWindowImage( bounds.width ); // set the width
		this.setUserView(window, bounds); //create the userview
		window.onClose_({ // stop the task when parent is closed
			image.free;
			this.stopruntask1;
			this.stopruntask2;
			this.stopruntask3;
			this.stopruntask4;
			fftbuf1.free;
			fftbuf2.free;
			fftbuf3.free;
			fftbuf4.free;
		}).front;
	}

	setUserView {arg window, bounds;
		userview = UserView(window, bounds)
			.focusColor_(Color.white.alpha_(0))
			.resize_(5)
			.drawFunc_({arg view;
				var b = view.bounds;
				Pen.use {
					Pen.scale( b.width / imgWidth, b.height / imgHeight );
					image.drawAtPoint(0@0);
				};
				if( drawCrossHair, {
					Pen.color = crosshaircolor;
					Pen.addRect( b.moveTo( 0, 0 ));
					Pen.clip;
					Pen.line( 0@mouseY, b.width@mouseY);
					Pen.line(mouseX @ 0, mouseX @ b.height);
					Pen.font = Font( "Helvetica", 10 );
					Pen.stringAtPoint( "freq: "+freq.asString, mouseX + 20 @ mouseY - 15);
					Pen.stroke;
				});
			})
			.mouseDownAction_({|view, mx, my|
				this.crosshairCalcFunc(view, mx, my);
				drawCrossHair = true;
				view.refresh;
			})
			.mouseMoveAction_({|view, mx, my|
				this.crosshairCalcFunc(view, mx, my);
				view.refresh;
			})
			.mouseUpAction_({|view, mx, my|
				drawCrossHair = false;
				view.refresh;
			});
	}

	sendSynthDef { // the synth spectroscope provides the actual computation of the fft
		SynthDef(\spectroscope, {|inbus=0, buffer=0|
			FFT(buffer, InFeedback.ar(inbus));
		}).add;
	}

	startruntask1 {
		running1 = true; // set task as Running
		this.recalcGradient;
		{
			runtask1 = Task({
				fftSynth1 = Synth(\spectroscope, [\inbus, inbus1, \buffer, fftbuf1]); // use the inbus as stream to analyze and the fftbuf as buffer for data
				{
					fftbuf1.getn(0, bufSize, // the FFTchain is in fftbuf
					{ arg buf;
						var magarray, complexarray;
							// flop invert rows and columns in a two dimensional Array (turn inside out)
							// arrange the value in 2 arrays, because we have real1 imag1, real2, imag2 values
						magarray = buf.clump(2)[(frombin .. tobin)].flop;
						complexarray = ((((Complex(
								Signal.newFrom( magarray[0] ), // we reunite the real and imaginary values in a complex signal.
								Signal.newFrom( magarray[1] )
						).magnitude.reverse)).log10)*80).clip(0, 255); // then we get the magnitude off the complex and fix the values

						complexarray.do({|val, i|  // complexarray now contains the fft to plot!
							val = val * intensity;
							fftDataArray1[i] = colints1.clipAt((val/16).round); // get the right colint value for the assigned value val, ordered wrt freq
						});
						{
							image.setPixels(fftDataArray1, Rect(index%imgWidth, 0, 1, (tobin - frombin + 1))); // draw an entire frequency line
							index = index + 1; // this permits to loop on the userview, using module operator to set the lag in the width of the view
							if( userview.notClosed, { userview.refresh });
						}.defer;
					});
					rate.reciprocal.wait; // framerate, normally set as 25fps
				}.loop; // loop of the Task
			}).start;
		}.defer(0.1); // delay the evaluation and allow the creation of an fftbuf before starting
	}

	startruntask2 {
		running2 = true; // set task as Running
		this.recalcGradient;
		{
			runtask2 = Task({
				fftSynth2 = Synth(\spectroscope, [\inbus, inbus2, \buffer, fftbuf2]); // use the inbus as stream to analyze and the fftbuf as buffer for data
				{
					fftbuf2.getn(0, bufSize, // the FFTchain is in fftbuf
					{ arg buf;
						var magarray, complexarray;
							// flop invert rows and columns in a two dimensional Array (turn inside out)
							// arrange the value in 2 arrays, because we have real1 imag1, real2, imag2 values
						magarray = buf.clump(2)[(frombin .. tobin)].flop;
						complexarray = ((((Complex(
								Signal.newFrom( magarray[0] ), // we reunite the real and imaginary values in a complex signal.
								Signal.newFrom( magarray[1] )
						).magnitude.reverse)).log10)*80).clip(0, 255);

						complexarray.do({|val, i|  // complexarray now contains the fft to plot!
							val = val * intensity;
							fftDataArray2[i] = colints2.clipAt((val/16).round);
						});
						{
							image.setPixels(fftDataArray2, Rect(index%imgWidth, 0, 1, (tobin - frombin + 1)));
							index = index + 1;
							if( userview.notClosed, { userview.refresh });
						}.defer;
					});
					rate.reciprocal.wait; // framerate, normally set as 25fps
				}.loop; // loop of the Task
			}).start;
		}.defer(0.1); // delay the evaluation and allow the creation of an fftbuf before starting
	}

		startruntask3 {
		running3 = true; // set task as Running
		this.recalcGradient;
		{
			runtask3 = Task({
				fftSynth3 = Synth(\spectroscope, [\inbus, inbus3, \buffer, fftbuf3]); // use the inbus as stream to analyze and the fftbuf as buffer for data
				{
					fftbuf3.getn(0, bufSize, // the FFTchain is in fftbuf
					{ arg buf;
						var magarray, complexarray;
							// flop invert rows and columns in a two dimensional Array (turn inside out)
							// arrange the value in 2 arrays, because we have real1 imag1, real2, imag2 values
						magarray = buf.clump(2)[(frombin .. tobin)].flop;
						complexarray = ((((Complex(
								Signal.newFrom( magarray[0] ), // we reunite the real and imaginary values in a complex signal.
								Signal.newFrom( magarray[1] )
						).magnitude.reverse)).log10)*80).clip(0, 255);

						complexarray.do({|val, i|  // complexarray now contains the fft to plot!
							val = val * intensity;
							fftDataArray3[i] = colints3.clipAt((val/16).round);
						});
						{
							image.setPixels(fftDataArray3, Rect(index%imgWidth, 0, 1, (tobin - frombin + 1)));
							index = index + 1;
							if( userview.notClosed, { userview.refresh });
						}.defer;
					});
					rate.reciprocal.wait; // framerate, normally set as 25fps
				}.loop; // loop of the Task
			}).start;
		}.defer(0.1); // delay the evaluation and allow the creation of an fftbuf before starting
	}

		startruntask4 {
		running4 = true; // set task as Running
		this.recalcGradient;
		{
			runtask4 = Task({
				fftSynth4 = Synth(\spectroscope, [\inbus, inbus4, \buffer, fftbuf4]); // use the inbus as stream to analyze and the fftbuf as buffer for data
				{
					fftbuf4.getn(0, bufSize, // the FFTchain is in fftbuf
					{ arg buf;
						var magarray, complexarray;
							// flop invert rows and columns in a two dimensional Array (turn inside out)
							// arrange the value in 2 arrays, because we have real1 imag1, real2, imag2 values
						magarray = buf.clump(2)[(frombin .. tobin)].flop;
						complexarray = ((((Complex(
								Signal.newFrom( magarray[0] ), // we reunite the real and imaginary values in a complex signal.
								Signal.newFrom( magarray[1] )
						).magnitude.reverse)).log10)*80).clip(0, 255);

						complexarray.do({|val, i|  // complexarray now contains the fft to plot!
							val = val * intensity;
							fftDataArray4[i] = colints4.clipAt((val/16).round);
						});
						{
							image.setPixels(fftDataArray4, Rect(index%imgWidth, 0, 1, (tobin - frombin + 1)));
							index = index + 1;
							if( userview.notClosed, { userview.refresh });
						}.defer;
					});
					rate.reciprocal.wait; // framerate, normally set as 25fps
				}.loop; // loop of the Task
			}).start;
		}.defer(0.1); // delay the evaluation and allow the creation of an fftbuf before starting
	}

	stopruntask1 { // stop the task and frees the synth
		running1 = false;
		runtask1.stop;
		try{fftSynth1.free };
	}

		stopruntask2 { // stop the task and frees the synth
		running2 = false;
		runtask2.stop;
		try{fftSynth2.free };
	}

		stopruntask3 { // stop the task and frees the synth
		running3 = false;
		runtask3.stop;
		try{fftSynth3.free };
	}

		stopruntask4 { // stop the task and frees the synth
		running4 = false;
		runtask4.stop;
		try{fftSynth4.free };
	}


	background_ {arg backgroundarg;
		background = backgroundarg;
		"in Here!!!".postln;
		this.prCreateImage( userview.bounds.width );
		this.recalcGradient;
		userview.refresh;
	}

	prCreateImage { arg width;
		if( image.notNil, { image.free });
		imgWidth = width;
		imgHeight = (tobin - frombin + 1);
		image = Image.color(imgWidth.asInt, imgHeight.asInt, background);
	}

	recalcGradient {
		var colors1, colors2, colors3, colors4;
		colors1 = (0..16).collect({|val| blend(background, color1, val/16)}); // gradient of shades btwn white and black, so to draw pixels for the fft
		colints1 = colors1.collect({|col| Image.colorToPixel( col )}); // translate color value to integer
		colors2 = (0..16).collect({|val| blend(background, color2, val/16)});
		colints2 = colors2.collect({|col| Image.colorToPixel( col )}); // translate color value to integer
		colors3 = (0..16).collect({|val| blend(background, color3, val/16)});
		colints3 = colors3.collect({|col| Image.colorToPixel( col )}); // translate color value to integer
		colors4 = (0..16).collect({|val| blend(background, color4, val/16)});
		colints4 = colors4.collect({|col| Image.colorToPixel( col )}); // translate color value to integer
	}

	crosshairColor_{arg argcolor;
		crosshaircolor = argcolor;
	}

	crosshairCalcFunc {|view, mx, my|
		mouseX = (mx-1.5).clip(0, view.bounds.width);
		mouseY = (my-1.5).clip(0, view.bounds.height);
		freq = binfreqs[((view.bounds.height)-mouseY).round(1).linlin(0, view.bounds.height, frombin*2, tobin*2).floor(1)].round(0.01);
	}

	setWindowImage { arg width;
		this.prCreateImage( width );
		index = 0;
	}

	start { this.startruntask1;
		    this.startruntask2;
		    this.startruntask3;
		    this.startruntask4;
	}

	stop { this.stopruntask1;
		   this.stopruntask2;
		   this.stopruntask3;
		   this.stopruntask4;
	}

	isRunning1 { ^running1 }


	isRunning2 { ^running2 }


	isRunning3 { ^running3 }


	isRunning4 { ^running4 }


	asView { ^userview }

}