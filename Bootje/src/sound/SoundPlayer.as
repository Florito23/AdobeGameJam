package sound 
{
	import com.greensock.TweenMax;
	import com.reintroducing.sound.SoundManager;
	import map.Map;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class SoundPlayer extends EventDispatcher
	{	
		private const FADE_EASING:Number = 0.1;
		
		[Embed(source = "../media/sound/city.mp3")]
		private static const SndCity:Class;
		
		[Embed(source = "../media/sound/harbour.mp3")]
		private static const SndHarbour:Class;
		
		[Embed(source = "../media/sound/harbour2.mp3")]
		private static const SndHarbour2:Class;
		
		[Embed(source = "../media/sound/wind.mp3")]
		private static const SndWind:Class;
		
		[Embed(source = "../media/sound/seagulls.mp3")]
		private static const SndSeagulls:Class;
		private var playSeagulls:Boolean;
		
		[Embed(source = "../media/sound/seagulls2.mp3")]
		private static const SndSeagulls2:Class;
		
		[Embed(source = "../media/sound/TootDouble.mp3")]
		private static const SndTootDouble:Class;
		
		[Embed(source = "../media/sound/motorLoop1.mp3")]
		private static const SndMotorLoop1:Class;
		
		[Embed(source = "../media/sound/motorLoop2.mp3")]
		private static const SndMotorLoop2:Class;
		private var motorRunnig:Boolean;
		private var motorLoop1Playing:Boolean;
		
		[Embed(source = "../media/sound/scape1.mp3")]
		private static const SndScape1:Class;
		
		[Embed(source = "../media/sound/scape2.mp3")]
		private static const SndScape2:Class;
		private var scapeOn:Boolean;
		private var scape1Playing:Boolean;
		
		[Embed(source = "../media/sound/shanti.mp3")]
		private static const SndShanti:Class;
		
		[Embed(source = "../media/sound/tropicana.mp3")]
		private static const SndTropicana:Class;
		
		
		[Embed(source = "../media/sound/boink.mp3")]
		private static const SndBoink:Class;
		[Embed(source = "../media/sound/ScrapingLong.mp3")]
		private static const Scraping:Class;
		
		[Embed(source = "../media/sound/scoreTick.mp3")]
		private static const SndScoreTick:Class;
		
		[Embed(source = "../media/sound/scoreTick2.mp3")]
		private static const SndScoreTick2:Class;
		
		[Embed(source = "../media/sound/scoreTick3.mp3")]
		private static const SndScoreTick3:Class;
		
		[Embed(source = "../media/sound/scoreTick4.mp3")]
		private static const SndScoreTick4:Class;
		
		private var flasche:uint = 1;
		[Embed(source = "../media/sound/flaschenPost.mp3")]
		private static const SndFlaschenPost:Class;
		[Embed(source = "../media/sound/flaschenPost2.mp3")]
		private static const SndFlaschenPost2:Class;
		[Embed(source = "../media/sound/flaschenPost3.mp3")]
		private static const SndFlaschenPost3:Class;
		[Embed(source = "../media/sound/flaschenPost4.mp3")]
		private static const SndFlaschenPost4:Class;
		
		[Embed(source = "../media/sound/explosion.mp3")]
		private static const SndExplosion:Class;
		
		
		
		
		private var waterVol:Number = 0;
		private var targetWaterVol:Number = 0;
		
		private var landVol:Number = 0;
		private var targetLandVol:Number = 0;
		
		private var shantiVol:Number = 0;
		private var targetShantiVol:Number = 0;
		
		private var seagullsVol:Number = 0;
		private var targetSeagullsVol:Number = 0;
		
		private var tropicanaVol:Number = 0;
		private var targetTropicanaVol:Number = 0;
		
		
		public function SoundPlayer() 
		{
			SoundManager.getInstance().addLibrarySound(SndCity, "city");
			
			SoundManager.getInstance().addLibrarySound(SndHarbour, "harbour");
			SoundManager.getInstance().addLibrarySound(SndHarbour2, "harbour2");
			SoundManager.getInstance().addLibrarySound(SndWind, "wind");
			SoundManager.getInstance().addLibrarySound(SndSeagulls, "seagulls");
			SoundManager.getInstance().addLibrarySound(SndSeagulls2, "seagulls2");
			
			SoundManager.getInstance().addLibrarySound(SndShanti, "shanti");
			SoundManager.getInstance().addLibrarySound(SndTropicana, "tropicana");
			
			SoundManager.getInstance().addLibrarySound(SndTootDouble, "tootDouble");
			SoundManager.getInstance().addLibrarySound(SndMotorLoop1, "motor1");
			SoundManager.getInstance().addLibrarySound(SndMotorLoop2, "motor2");
			
			SoundManager.getInstance().addLibrarySound(SndScape1, "scape1");
			SoundManager.getInstance().addLibrarySound(SndScape2, "scape2");
			
			SoundManager.getInstance().addLibrarySound(SndBoink, "boink");
			SoundManager.getInstance().addLibrarySound(Scraping, "scraping");
			
			SoundManager.getInstance().addLibrarySound(SndScoreTick, "scoreTick1");
			SoundManager.getInstance().addLibrarySound(SndScoreTick2, "scoreTick2");
			SoundManager.getInstance().addLibrarySound(SndScoreTick3, "scoreTick3");
			SoundManager.getInstance().addLibrarySound(SndScoreTick4, "scoreTick4");
			
			SoundManager.getInstance().addLibrarySound(SndFlaschenPost, "flaschenPost");
			SoundManager.getInstance().addLibrarySound(SndFlaschenPost2, "flaschenPost2");
			SoundManager.getInstance().addLibrarySound(SndFlaschenPost3, "flaschenPost3");
			SoundManager.getInstance().addLibrarySound(SndFlaschenPost4, "flaschenPost4");
			
			SoundManager.getInstance().addLibrarySound(SndExplosion, "explosion");
			
			start();
			
			//addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function start():void 
		{
			play("city", 0, 999);
			
			play("harbour2", 0, 999);
			TweenMax.delayedCall(10, play, ["harbour", 0, 999]);
			
			play("wind", 0, 999);
			
			play("shanti", 0, 999);
			
			randomSeagulls();
			startScape();
			
			startMotor();
			
			play("seagulls2", 0, 999);
			play("tropicana", 0, 999);
		}
		
		
		// main play
		public function play(name:String, vol:Number = 1, loops:uint = 0):void 
		{
			SoundManager.getInstance().playSound(name, vol, 0, loops);
		}
		
		
		// main stop
		public function stop(name:String):void 
		{
			SoundManager.getInstance().stopSound(name);
		}
		
		// FRAME
		public function update():void 
		{
			waterVol += (targetWaterVol - waterVol) * FADE_EASING;
			SoundManager.getInstance().setSoundVolume("harbour", waterVol);
			SoundManager.getInstance().setSoundVolume("harbour2", waterVol * 0.75);
			SoundManager.getInstance().setSoundVolume("seagulls", waterVol * 0.1);
			SoundManager.getInstance().setSoundVolume("scape1", waterVol * 0.25);
			SoundManager.getInstance().setSoundVolume("scape2", waterVol * 0.25);
			
			landVol += (targetLandVol - landVol) * FADE_EASING;
			SoundManager.getInstance().setSoundVolume("city", landVol * 1.5);
			SoundManager.getInstance().setSoundVolume("wind", landVol * 1.5);
			
			shantiVol += (targetShantiVol - shantiVol) * FADE_EASING;
			SoundManager.getInstance().setSoundVolume("shanti", shantiVol);
			
			seagullsVol += (targetSeagullsVol - seagullsVol) * FADE_EASING;
			SoundManager.getInstance().setSoundVolume("seagulls2", seagullsVol);
			
			tropicanaVol += (targetTropicanaVol - tropicanaVol) * FADE_EASING;
			SoundManager.getInstance().setSoundVolume("tropicana", tropicanaVol);
			
			//trace("tropicanaVol" + tropicanaVol);
		}
		
		
		// main MIX
		public function mix(percentages:Vector.<Number>):void 
		{
			targetWaterVol = Number(percentages[Map.SOUND_TYPE_WATER]);
			targetLandVol = Number(percentages[Map.SOUND_TYPE_LAND]);
			targetShantiVol = Number(percentages[Map.SOUND_TYPE_SHANTI]);
			targetSeagullsVol = Number(percentages[Map.SOUND_TYPE_SEAGULLS]);
			targetTropicanaVol = Number(percentages[Map.SOUND_TYPE_TROPICANA]);
		}
		
		
		private function fadeWaterVol(volo:Number):void 
		{
			
		}
		
		
		public function randomSeagulls():void 
		{
			playSeagulls = true;
			TweenMax.delayedCall(Math.random() * 30, playSeagullSound);
		}
		
		private function playSeagullSound():void 
		{
			if (playSeagulls)
			{
				play("seagulls", 0.1);
				TweenMax.delayedCall(Math.random() * 30, playSeagullSound);
			}
			
		}
		
		private function stopSeagullSound():void 
		{
			playSeagulls = false;
		}
		
		// SCAPE
		public function startScape():void 
		{
			scapeOn = true;
			play("scape1", 0);
			scape1Playing = true;
			TweenMax.delayedCall(6, loopScape);
		}
		
		
		public function loopScape():void 
		{
			if (scapeOn)
			{
				if (scape1Playing)
				{
					stop("scape2");
					play("scape2", 0);
					scape1Playing = false;
					TweenMax.delayedCall(12 + Math.random() * 6, loopScape);
				}
				else
				{
					stop("scape1");
					play("scape1", 0);
					scape1Playing = true;
					TweenMax.delayedCall(5 + Math.random() * 2, loopScape);
				}
			}
			
		}
		
		public function stopScape():void 
		{
			scapeOn = false;
			stop("scape1");
			stop("scape2");
		}
		
		// MOTOR
		public function startMotor():void 
		{
			trace("MOTOR");
			motorRunnig = true;
			play("motor1", 0);
			motorLoop1Playing = true;
			TweenMax.delayedCall(6, runMotor);
		}
		
		
		public function runMotor():void 
		{
			if (motorRunnig)
			{
				if (motorLoop1Playing)
				{
					play("motor2", 0);
					motorLoop1Playing = false;
				}
				else
				{
					play("motor1", 0.5);
					motorLoop1Playing = true;
				}
			}
			TweenMax.delayedCall(6, runMotor);
		}
		
		
		public function setMotorVol(v:Number):void
		{
			SoundManager.getInstance().setSoundVolume("motor1", v * 0.5);
			SoundManager.getInstance().setSoundVolume("motor2", v * 0.5);
		}
		
		public function stopMotor():void 
		{
			motorRunnig = false;
			stop("motor1");
			stop("motor2");
		}
		
		
		// Toot!
		public function playToot(v:Number = 1):void 
		{
			stop("tootDouble");
			play("tootDouble", v);
		}
		
		
		// BOINK!
		public function playBoink(v:Number = 1):void 
		{
			stop("boink");
			play("boink", v);
		}
		
		public function playScratch(v:Number = 1):void {
			stop("scraping");
			play("scraping", v, 1000);
		}
		
		public function stopScratch():void {
			stop("scraping");
		}
		
		// SCORE!
		public function playScoreTick(v:Number = 1):void 
		{
			var t:uint = Math.ceil(Math.random() * 4);
			switch(t)
			{
				case 1:
					stop("scoreTick1");
					play("scoreTick1", v);
					break;
				
				case 2:
					stop("scoreTick2");
					play("scoreTick2", v);
					break;
					
				case 3:
					stop("scoreTick3");
					play("scoreTick3", v);
					break;
					
				case 4:
					stop("scoreTick4");
					play("scoreTick4", v);
					break;
				
			}
		}
		
		
		public function playCoin():void 
		{
			switch(flasche)
			{
				case 1:
					stop("flaschenPost");
					play("flaschenPost", 1);
					break;
				case 2:
					stop("flaschenPost2");
					play("flaschenPost2", 1);
					break;	
				case 3:
					stop("flaschenPost3");
					play("flaschenPost3", 1);
					break;
				case 4:
					stop("flaschenPost4");
					play("flaschenPost4", 1);
					break;
			}
			
			flasche ++;
			if (flasche == 5) flasche = 1;
		}
		
		
		// BOINK!
		public function playExplosion(v:Number = 1):void 
		{
			stop("explosion");
			play("explosion", v);
		}
	}

}