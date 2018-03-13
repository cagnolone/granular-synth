# granular-synth

![synth](https://github.com/cagnolone/granular-synth/blob/master/synth.PNG)


## I already am a supercollider user!

Ok, so quick rundown for you: put `GranularSpectrogram4channels.sc` in the `Extensions` folder, recompile the class library, boot the server and run `GranularSynth.scd`. You should run this on on **3.8.0** or greater otherwise you are gonna have problems with the GUI. Use **MONO** samples only!! Go at the bottom of this page if you need some.

## I NEVER used supercollider! How do I try this?

So, first of all download supercollider from [here](https://supercollider.github.io).
If you already have supercollider installed on your machine, make sure you are on **3.8.0** or greater otherwise you are gonna have problems with the GUI.

You'll notice you have 2 files in this repo:
+ `GranularSynth.scd`
+ `GranularSpectrogram4channels.sc`

The `.scd` file is the one you are going to run in the SC enviroment, while the `.sc` one is a new class for our language, so we must add it to the class library of supercollider.

How so? Open up supercollider, and type
```supercollider
Platform.userExtensionDir
```
Now, **evaluate**: put your cursor on the line of code and press `Cmd+Enter` (macOS) or `Ctrl+Enter` (win).

You will get in the post window a Path to the `Extensions` folder of supercollider.
Try to reach that path. This can be difficult since some folders might be hidden, so the best thing is to copy the path in the file explorer.
Moreover, the folder might not exist, so you may need to create it yourself. You can do this in your operating system's file explorer or from within supercollider by **evaluating**:

```supercollider
File.mkdir(Platform.userExtensionDir)
```
_Quick stupid tip: if you want to manually create it and you can't reach the parent folder, just delete \Extensions from the path and go there from the file explorer._

Just be sure that the folder is named `Extensions`, that the folder is in the right parent folder as suggested from the path supercollider provides you, and paste right there `GranularSpectrogram4channels.sc`. Nothing too difficult.

Okay now, go into the supercollider enviroment, and go for `Language > Recompile Class Library`.
Now we have our custom class!
Next thing we need is to boot the supercollider server. Press `Server > Boot Server`, and when the numbers in % at the bottom right go **green**, we are ready to go.
Open the `GranularSynth.scd` file, press `Cmd+A` (macOS) or `Ctrl+A` (win), then press `Cmd+Enter` (macOS) or `Ctrl+Enter` (win).
This shall start everything and you should be able to load samples, play them and have fun with everything in the pack.
If you want more info on the synth, check the `.pdf`.
Oh, and be sure to use **MONO** samples! What, you do not have any? Grab some [here](https://www.adventurekid.se/akrt/waveforms/), they are free and you can even donate them something!
