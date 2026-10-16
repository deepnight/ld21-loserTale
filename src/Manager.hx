import mt.deepnight.Types;
import mt.deepnight.Buffer;
import mt.deepnight.SpriteLib;
import mt.deepnight.Tweenie;
import mt.deepnight.Color;
import flash.ui.Keyboard;
import flash.display.Sprite;

class GfxScenes extends flash.display.BitmapData {}

using mt.deepnight.SuperMovie;

typedef Saying = {
	var s	: String;
	var x	: Int;
	var y	: Int;
}

class Manager {//}
	public static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	public static var ME : Manager;
	public static var UPSCALE = 4;
	public static var USE_SCALE2X = false;
	public static var TW : Tweenie;
	
	var root		: MC;
	var buffer		: mt.deepnight.Buffer;
	var fl_lock		: Bool;
	var lib			: SpriteLib;
	var scenes		: List<Sprite>;
	var bg			: Sprite;
	var blurAnim	: Float;
	var history		: List<String>;
	var question	: Null<interf.Text>;
	var curDialog	: List<Saying>;
	var lastSay		: Null<interf.Text>;
	var dialogCpt	: Int;
		
	public function new(r) {
		ME = this;
		root = r;
		root.addEventListener( flash.events.Event.ENTER_FRAME, main );
		haxe.Log.setColor(0xffff00); 
		TW = new Tweenie();
		scenes = new List();
		history = new List();
		curDialog = new List();
		
		buffer = new Buffer(240,180, UPSCALE, false, 0x0, USE_SCALE2X);
		buffer.setTexture(Buffer.makeMosaic(UPSCALE), 0.2, flash.display.BlendMode.OVERLAY, true);
		root.addChild(buffer.render);
		
		bg = new flash.display.Sprite();
		buffer.addChild(bg);
		
		root.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
		
		lib = new SpriteLib( new GfxScenes(0,0) );
		lib.defaultCenterX = 0;
		lib.defaultCenterY = 0;
		var keys = [
			"foetus1",
			"foetus2",
			"death",
			"school",
			"university",
			"boss",
			"office",
			"disco",
			"coffee",
			"sexyoung",
			"sexold",
			"hospital_old",
			"hospital_young",
			"suicide_young",
			"tv",
			"suicide_old",
			"",
			"",
		];
		lib.sliceWithMultipleKeys(
			keys,
			0,0,128,80, 
			6, 3
		);
		//root.addChild(new flash.display.Bitmap(lib.bmp));
		#if debug
		trace("WARNING : debug mode !");
		#end
		startGame(true);
	}
	
	function startGame(fl_firstStart:Bool) {
		#if debug
		startScene("birth");
		#else
		var d = fl_firstStart ? 3000 : 0;
		haxe.Timer.delay(callback(startScene,"birth"), d);
		#end
		
		if(fl_firstStart) {
			var tf = new interf.Text();
			tf.field.text = "This game was created in 9 hours for the Ludum Dare 21 competition (thema : ESCAPE)\nAUTHOR : Sébastien Bénard (http://blog.deepnight.net)\nThanks to my beloved Marine for her precious help.";
			tf.filters = [ new flash.filters.GlowFilter(0x0,1,2,2,10) ];
			tf.x = Std.int(WID*0.5);
			tf.y = HEI-50;
			tf.alpha = 0;
			TW.create(tf, "alpha", 1, TEaseIn, 500);
			root.addChild(tf);
			haxe.Timer.delay( function() {
				TW.create(tf, "alpha", 0, TEaseIn).onEnd = function() {
					tf.parent.removeChild(tf);
				}
			}, 5500);
		}
	}
	
	function endGame() {
		fl_lock = true;
		var d = 2500;
		for (s in scenes) 
			TW.create(s, "alpha", 0, TEaseIn, d);
			
		var tf = new interf.Text();
		tf.field.text = "LIFE OVER";
		tf.filters = [ new flash.filters.GlowFilter(0x0,1,2,2,10) ];
		tf.x = Std.int(WID*0.5);
		tf.y = Std.int(HEI*0.5);
		tf.alpha = 0;
		TW.create(tf, "alpha", 1, TEaseIn, d);
		root.addChild(tf);
		haxe.Timer.delay( function() {
			TW.create(tf, "alpha", 0, TEaseIn).onEnd = function() {
				tf.parent.removeChild(tf);
				resetGame();
			}
		}, 4500);
	}
	
	function resetGame() {
		for (s in scenes) 
			s.parent.removeChild(s);
		scenes = new List();
		history = new List();
		clearDialog();
		startGame(false);	
	}
	
	
	function getCurrent() {
		return history.last();
	}
	
	
	function startScene(k:String) {
		fl_lock = true;
		if (k==null) {
			endGame();
			return;
		}
		history.add(k);
		switch(k) {
			case "birth" :
				addScene("foetus1", 50,50, 0x2D0B0B);
				haxe.Timer.delay( function() {
					addScene("foetus2", 50,50, 0x621717, 500);
					dialog([
						{s:"All right madam!",x:20,y:20 },
						{s:"I see him!",x:30,y:27 },
						{s:"Huh?",x:90,y:30 },
						{s:"One last effort!",x:30,y:27 },
						{s:"PUSH!",x:25,y:30 },
						{s:"Wait... WHAT?",x:78,y:29 },
					]);
				}, #if debug 500 #else 3500 #end);
				
			case "school" :
				addScene("school", 30,80, 0x326474);
				dialog([
					{s:"Driiiing!",x:100,y:40},
					{s:"Come on kids!_",x:115,y:42},
					{s:"*sigh*_",x:70,y:54},
				]);
				
			case "death_birth" :
				addScene("death", 20,30, 0x1D1F23);
				dialog([
					{s:"Damn..._",x:60,y:20},
					{s:"Maybe I should have followed the light.",x:70,y:24},
				]);
				
			case "university" :
				addScene("university",60,30, 0x7C4229);
				dialog([
					{s:"Oh come on...",x:30,y:20},
					{s:"*sigh*",x:40,y:28},
				]);	
				
			case "newjob" :
				addScene("boss",40,60, 0x212E2C);
				dialog([
					{s:"..and you should get +17.5% easily.",x:70,y:12},
					{s:"Yes sir...",x:25,y:8},
					{s:"...your job is crucial...",x:72,y:12},
					{s:"...responsibilities...",x:65,y:14 },
					{s:"Yes sir.",x:25,y:8},
					{s:"...results...",x:70,y:13 },
					{s:"...objectives...",x:67,y:16},
					{s:"Yes sir...",x:25,y:8 },
					{s:"...money...",x:76,y:12 },
					{s:"I will do my best sir...",x:25,y:8 },
					{s:"...lots of money...",x:65,y:14 },
					{s:"...money, money, money...",x:70,y:12 },
				]);	
				
			case "job" :
				addScene("office",60,73, 0x282933);
				dialog([
					{s:"...",x:37,y:18 },
					{s:"Well.",x:38,y:15 },
					{s:"Actually, my job is very interesting.",x:40,y:17 },
					{s:"...",x:37,y:18 },
					{s:"Responsibilities..._",x:42,y:16 },
					{s:"Money..._",x:38,y:14 },
					{s:"...__",x:38,y:17 },
					{s:"____",x:38,y:17 },
					{s:"*cough*",x:42,y:18 },
					{s:"*echo*",x:15,y:10 },
					{s:"*echo*",x:65,y:7 },
					{s:"__",x:38,y:17 },
					{s:"Well. That was a nice break.",x:40,y:15 },
					{s:"Let's get back to my exciting work.",x:42,y:18 },
				]);
				
			case "club" :
				addScene("disco",47,65, 0x11184A);
				dialog([
					{s:"So...",x:20,y:25 },
					{s:"_",x:20,y:25 },
					{s:"You do that often?",x:18,y:27 },
					{s:"_",x:18,y:27 },
					{s:"I mean...",x:16,y:28 },
					{s:"...partying...",x:20,y:30 },
					{s:"_",x:20,y:30 },
					{s:"...stuff like that...",x:20,y:30 },
					{s:"___",x:20,y:33 },
					{s:".....___",x:42,y:33 },
					{s:"*smiles*",x:23,y:33 },
				]);
			
			case "coffee" :
				addScene("coffee",50,65, 0x4D354A);
				dialog([
					{s:"So...",x:20,y:25 },
					{s:"_",x:20,y:25 },
					{s:"You do that often?",x:18,y:27 },
					{s:"_",x:18,y:27 },
					{s:"I mean...",x:16,y:28 },
					{s:"...drinking coffee...",x:20,y:30 },
					{s:"_____",x:20,y:30 },
					{s:".....___",x:42,y:30 },
					{s:"*cough*",x:23,y:30 },
					{s:"_",x:23,y:30 },
				]);
				
			case "old" :
				addScene("hospital_old",87,71, 0x334F4B);
				dialog([
					{s:"Well well..._",x:80,y:17 },
					{s:"_",x:80,y:17 },
					{s:"What we found is pretty unusual...",x:75,y:15 },
					{s:"__",x:80,y:17 },
					{s:"You have a rare sort of leukemia...",x:75,y:19 },
					{s:"_",x:80,y:18 },
					{s:"Dysteria...__",x:74,y:17 },
					{s:"Few ulcers...__",x:84,y:15 },
					{s:"Diabetes...__",x:72,y:19 },
					{s:"____",x:72,y:19 },
					{s:"And 3 cancers.___",x:80,y:18 },
					{s:"(2 in concluding phase)",x:85,y:20 },
					{s:"__",x:80,y:18 },
					{s:"Oh, and bubonic plague.",x:75,y:18 },
					{s:"__",x:80,y:18 },
					{s:"Hopefully we may have a treatment.",x:81,y:15 },
					{s:"I need a signature here... and here.",x:80,y:20 },
				]);
							
			case "death_disease" :
				addScene("death", 20,27, 0x1D1F23);
				dialog([
					{s:"...",x:70,y:20},
					{s:"I SHOULD have expected some kind of trap",x:60,y:24},
					{s:"when they told me about a $15 treatment.",x:60,y:24},
					{s:"_",x:60,y:24},
				]);		
				
			case "death_girlfriend" :
				addScene("death", 20,27, 0x1D1F23);
				dialog([
					{s:"I guessed she didn't want me to continue.",x:60,y:24 },
					{s:"____",x:60,y:24},
					{s:"But hey...__",x:75,y:30},
					{s:"Where the hell did she got this shotgun from?!",x:65,y:25},
				]);
				
			case "sexyoung" :
				addScene("sexyoung", 63,20, 0x1D1F23);
				dialog([
					{s:"So...",x:20,y:10},
					{s:"__",x:20,y:10},
					{s:"You are really blond?",x:35,y:8},
					{s:"__",x:35,y:10},
					{s:"I mean... That's cool...",x:35,y:12},
					{s:"____",x:35,y:13},
					{s:"...____",x:7,y:17},
					{s:"____",x:7,y:17},
					{s:"First time, eh?",x:5,y:18},
				]);	
				
			case "sexold" :
				addScene("sexold", 63,20, 0x1D1F23);
				dialog([
					{s:"So...",x:20,y:10},
					{s:"__",x:20,y:10},
					{s:"What do you think of the new photocopier?",x:35,y:8},
					{s:"__",x:35,y:10},
					{s:"I mean... It's cool...",x:35,y:12},
					{s:"Nice colors",x:30,y:8},
					{s:"Pretty fast",x:32,y:14},
					{s:"Quiet",x:30,y:12},
					{s:"____",x:35,y:13},
					{s:"...____",x:7,y:17},
					{s:"____",x:7,y:17},
					{s:"First time, eh?",x:5,y:18},
				]);
				
			case "kids" :
				addScene("hospital_young",68,38, 0x334F4B);
				dialog([
					{s:"So, congrutalations sir.",x:90,y:17 },
					{s:"______",x:80,y:17 },
					{s:"4 girls and 6 boys.__",x:92,y:18 },
					{s:"10 nice babies.",x:85,y:15 },
					{s:"This is a record!",x:90,y:16 },
					{s:"______",x:80,y:18 },
					{s:"... Sir?",x:80,y:19 },
				]);
					
			case "jobhard" :
				addScene("office",60,73, 0x282933);
				dialog([
					{s:"Ok, if I finish my job at 8pm",x:37,y:15 },
					{s:"I can get to the market and buy diapers_",x:45,y:18 },
					{s:"Then I take kids to the cinema",x:50,y:16 },
					{s:"I get quickly back at home to prepare meal",x:45,y:18 },
					{s:"__",x:45,y:18 },
					{s:"I may even have time to take 2-3 caffeine pills.",x:45,y:15 },
				]);
			
			case "suicide_young" :
				addScene("suicide_young",80,53, 0x610E0E);
				dialog([
					{s:"Oh well...",x:27,y:25 },
					{s:"____",x:27,y:25 },
					{s:"Everything looks so small from here...",x:33,y:28 },
					{s:"____",x:33,y:28 },
					{s:"Oh everything seems bigger now!",x:33,y:22 },
					{s:"____",x:33,y:22 },
					{s:"Damn, this is taking forever...",x:30,y:30 },
				]);
				
			case "suicide_old" :
				addScene("suicide_old",80,53, 0x610E0E);
				dialog([
					{s:"Oh my...",x:27,y:25 },
					{s:"Is that my pant I see floating over there?",x:33,y:28 },
					{s:"____",x:33,y:28 },
					{s:"This is very embarassing...",x:33,y:32 },
					{s:"____",x:33,y:28 },
					{s:"I hoped for a better death\nthan with my butt exposed...",x:33,y:22 },
				]);
				
			case "tv" :
				addScene("tv",72,46, 0x622F0D);
				dialog([
					{s:"*noise noise*",x:27,y:5 },
					{s:"*noise noise*",x:28,y:2 },
					{s:"*noise noise*",x:30,y:4 },
					{s:"*noise noise*",x:25,y:6 },
					{s:"Yeah man.",x:95,y:8 },
					{s:"That's life!",x:90,y:5 },
					{s:"*noise noise*",x:27,y:5 },
					{s:"*noise noise*",x:28,y:2 },
					{s:"_",x:28,y:2 },
				]);
				
			case "tv2" :
				addScene("tv",72,46, 0x622F0D);
				dialog([
					{s:"*noise noise*",x:27,y:5 },
					{s:"*noise noise*",x:28,y:2 },
					{s:"*noise noise*",x:30,y:4 },
					{s:"*noise noise*",x:25,y:6 },
					{s:"Hmm. ",x:95,y:8 },
					{s:"_",x:95,y:8 },
					{s:"This is NOT as exciting as I expected...",x:90,y:5 },
					{s:"*noise noise*",x:27,y:5 },
					{s:"*noise noise*",x:28,y:2 },
					{s:"_",x:28,y:2 },
				]);
				

			case "fired" :
				addScene("boss",40,60, 0x212E2C);
				dialog([
					{s:"..and that's what led us to this decision.",x:70,y:12},
					{s:"Yes sir...",x:25,y:8},
					{s:"Well.",x:72,y:12 },
					{s:"____",x:25,y:8 },
					{s:"I mean... You're fired.__",x:65,y:14 },
					{s:"Of course sir.",x:25,y:8},
					{s:"_",x:25,y:8},
					{s:"We need more efficient coworkers.",x:70,y:13 },
					{s:"Yes sir...",x:25,y:8 },
					{s:"Too slow, not enough initiatives.",x:76,y:12 },
					{s:"Oh, that's right sir...",x:25,y:8 },
					{s:"____",x:25,y:8 },
					{s:"And you have red hair.",x:65,y:14 },
					{s:"Hell... Who have red hair nowadays?",x:70,y:12 },
				]);	
				
			case "fired_alone" :
				addScene("boss",40,60, 0x212E2C);
				dialog([
					{s:"..and that's what led us to this decision.",x:70,y:12},
					{s:"Yes sir...",x:25,y:8},
					{s:"Well.",x:72,y:12 },
					{s:"____",x:25,y:8 },
					{s:"I mean... You're fired.__",x:65,y:14 },
					{s:"Of course sir.",x:25,y:8},
					{s:"_",x:25,y:8},
					{s:"We need more efficient coworkers.",x:70,y:13 },
					{s:"Yes sir...",x:25,y:8 },
					{s:"Too slow, not enough initiatives.",x:76,y:12 },
					{s:"Oh, that's right sir...",x:25,y:8 },
					{s:"____",x:25,y:8 },
					{s:"And you have red hair.",x:65,y:14 },
					{s:"Hell... Who have red hair nowadays?",x:70,y:12 },
				]);	
			
			case "divorce" :
				addScene("sexold", 63,20, 0x5C2721);
				dialog([
					{s:"So...",x:20,y:8},
					{s:"What do you mean by...",x:20,y:10},
					{s:"\"Red hair sucks\"?",x:22,y:12},
					{s:"____",x:7,y:17},
					{s:"It means I break off.",x:5,y:16},
					{s:"And I keep the car.",x:5,y:18},
					{s:"And the house.",x:7,y:19 },
					{s:"Oh.",x:20,y:12 },
					{s:"__",x:9,y:17},
					{s:"And you really suck in bed.",x:7,y:17},
				]);	
			default : throw "unknown scene "+k;
		}
	}
	
	function getNextScene(fl_enter:Bool) {
		return 
		switch(getCurrent()) {
			case "birth" : fl_enter ? "school":"death_birth";
			case "school" : fl_enter ? "university":"tv2";
			case "university" : fl_enter ? "newjob":"club";
			case "club" : fl_enter ? "sexyoung":"tv";
			case "sexyoung" : fl_enter ? "kids":"newjob";
			case "sexold" : fl_enter ? "kids":"fired";
			case "kids" : fl_enter ? "jobhard":"suicide_young";
			case "jobhard" : fl_enter ? "divorce":"suicide_young";
			case "tv" : fl_enter ? "old":"suicide_young";
			case "tv2" : fl_enter ? "tv":"club";
			case "newjob" : fl_enter ? "job":"tv";
			case "job" : fl_enter ? "coffee":"tv";
			case "coffee" : fl_enter ? "sexold":"fired_alone";
			case "old" : fl_enter ? "death_disease":"suicide_old";
			case "fired" : fl_enter ? "divorce":"suicide_young";
			case "fired_alone" : fl_enter ? "old":"suicide_young";
			case "divorce" : fl_enter ? "death_girlfriend":"tv";
			default : 
				null;
		}
	}
	
	
	function addScene(k:String, x,y, col:Int, ?fade=2500) {
		var spr = lib.getSprite(k);
		
		for (s in scenes) {
			s.filters = [new flash.filters.BlurFilter(2,2)];
			//TW.create(s, "alpha", 0.5, TEase, fade);
		}
			
		var last = scenes.last();
		if(last!=null) {
			blurAnim = 0;
			TW.create(this, "blurAnim", 1, TEase, 2500).onUpdateT = function(t) {
				last.filters = [new flash.filters.BlurFilter(t*2,t*2)];
			}
		}
		
		var scene = new flash.display.Sprite();
		scene.addChild(spr);
		scene.x = x;
		scene.y = y;
		spr.filters = [
			new flash.filters.GlowFilter(0xffffff,1,2,2,10),
			new flash.filters.DropShadowFilter(4,70, 0x0,0.3, 0,0),
			//new flash.filters.GlowFilter(0x0,0.1,2,2,10),
		];
		
		#if debug fade = Std.int(fade/2); #end
		buffer.addChild(scene);
		scenes.add(scene);
		
		scene.alpha = 0;
		TW.create(scene,"alpha",1,TEaseOut,fade);
		
		setBg(col);
	}

	function setBg(col:Int) {
		var nbg = new flash.display.Sprite();
		//nbg.graphics.beginFill(col,1);
		var m = new flash.geom.Matrix();
		m.rotate(3.14 / 2);
		nbg.graphics.beginGradientFill(flash.display.GradientType.LINEAR, [col,Color.darken(col,1)], [1,1], [128,180], m);
		nbg.graphics.drawRect(0,0,buffer.width,buffer.height);
		nbg.alpha = 0;
		TW.create(nbg,"alpha",1,TEase,2500);
		bg.addChild(nbg);
	}
	
	function ask(?str:String) {
		if (str==null)
			str = "Continue (press [C]) or try to [ESCAPE] ?";
		var tf = new interf.Text();
		tf.field.text = str;
		root.addChild(tf);
		var last = scenes.last();
		tf.x = last.x*UPSCALE + Std.int(tf.field.textWidth*0.5) + 4;
		tf.y = last.y*UPSCALE - tf.field.textHeight+12;
		tf.filters = [new flash.filters.GlowFilter(0x0,1,2,2,10),
			new flash.filters.DropShadowFilter(1,90,0x0,0.5,0,0),
		];
		
		tf.alpha = 0;
		haxe.Timer.delay(function() {
			TW.create(tf, "alpha", 1, TEaseOut, 1500);
			tf.y += 20;
			TW.create(tf, "y", tf.y-20, TEaseOut, 1000);
			fl_lock = false;
		}, 1500); 
		
		question = tf;
	}
	
	function dialog(arr:Array<Saying>) {
		curDialog = Lambda.list(arr);
		dialogCpt = #if debug 0 #else 96 #end;
	}
	
	function clearDialog() {
		if (lastSay != null) {
			lastSay.parent.removeChild(lastSay);
			lastSay = null;
		}
		curDialog = new List();
	}
	
	function say(s:Saying) {
		if (lastSay != null) {
			lastSay.parent.removeChild(lastSay);
			lastSay = null;
		}
		var str = s.s;
		
		var delay = str.split("_").length;
		str = StringTools.replace(str, "_", "");
		dialogCpt = 16+str.length + delay*16;
		
		#if debug
		dialogCpt = Std.int(dialogCpt / 2);
		#end
		
		var tf = new interf.Text();
		tf.field.text = str;
		tf.filters = [ new flash.filters.GlowFilter(0x0,1,2,2,10) ];
		var last = scenes.last();
		
		
		tf.x = (last.x+s.x)*UPSCALE;
		tf.y = (last.y+s.y)*UPSCALE;
		root.addChild(tf);
		lastSay = tf;
	}
	
	function onKeyDown(e:flash.events.KeyboardEvent) {
		var k = e.keyCode;
		if (curDialog.length>0 || lastSay!=null) 
			dialogCpt=0;
		if (fl_lock)
			return;
			
			
		if(k==Keyboard.ESCAPE || k==Keyboard.ENTER || k==67) {
			var tf = question;
			TW.create(tf, "alpha", 0, TEaseIn,500).onEnd = function() {
				tf.parent.removeChild(tf);
			}
			question = null;
			fl_lock = true;
			clearDialog();
		}

		switch(k) {
			case Keyboard.ESCAPE :
				startScene( getNextScene(false) );
				
			case 67 :
				startScene( getNextScene(true) );
			case Keyboard.ENTER :
				startScene( getNextScene(true) );
		}
	}
	
	function nextSay() {
		say(curDialog.pop());
			
		if (curDialog.length==0) {
			var s = getCurrent();
			if(s.indexOf("suicide")>=0)
				ask("[ESCAPE] = crash");
			else if(s.indexOf("death")>=0)
				ask("[ESCAPE] = die");
			else 
				ask();
		}
	}
	
	
	function main(_) {
		if (curDialog.length>0) 
			if ( --dialogCpt<=0 ) {
				nextSay();
			}
		DSprite.updateAll();
		TW.update(1);
		buffer.update();
	}
}
