package  
{

	import boat.Bootje;
	import animations.Sparkle;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	//import clouds.CloudController;
	import collectables.FloatingPenguin;
	import com.greensock.TweenMax;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import hud.Hud;
	import map.Map;
	import map.World;
	import sound.SoundPlayer;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import textures.AllTextures;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class BootjeTest extends Sprite 
	{
		
		
		
		
		private var _map:Map;
		private var _world:World;
		
		
		private var gameMapSprite:Sprite;
		
		private var allTextures:AllTextures;
		
		//private var shadowLayer:Sprite = new Sprite();
		//private var cloudLayer:Sprite = new Sprite();
		//private var cloudController:CloudController;
		
		private var _hud:Hud;
		
		public static var soundPlayer:SoundPlayer = new SoundPlayer();
		
		private var displayFrame:Frame;
		
		private var soundMixUpdate:Timer;
		
		
		
		public function BootjeTest() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			allTextures = new AllTextures();
			
			
			// create map
			_map = new Map(allTextures.gameBitmap, allTextures.soundBitmap);// 80, 80, allTextures.gameBitmap);
			
			// create world
			_world = new World(_map, allTextures);
			_world.addEventListener(World.COLLIDE_EVENT_START, function(e:Event):void {
				soundPlayer.playBoink(0.2);
			});
			_world.addEventListener(World.COLLIDE_EVENT_SCRATCH_BEGIN, function(e:Event):void {
				soundPlayer.playScratch(0.75);
			});
			_world.addEventListener(World.COLLIDE_EVENT_SCRATCH_END, function(e:Event):void {
				soundPlayer.stopScratch();
			});
			addChild(_world);
			
			// create display frame
			displayFrame = new Frame();
			addChild(displayFrame);
			displayFrame.resize(stage.stageWidth, stage.stageHeight)
			
			// create hud
			_hud = new Hud(_world);
			addChild(_hud);
			addEventListener("scoreTick", onScoreTick);
			addEventListener("SCORE", changeScore);
			
			// create sound mixer
			var soundMixUpdate:Timer = new Timer(100);
			soundMixUpdate.addEventListener(TimerEvent.TIMER, onSoundMixUpdate);
			soundMixUpdate.start();
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
			//stage.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		private function onSoundMixUpdate(e:TimerEvent):void 
		{
			//SOUND MAP:
			var boatPos:Point = new Point(_world.bootje.x, _world.bootje.y);
			//TODO: add half size?
			var boatOnMapPos:Point = _world.spritePosToMapPos(boatPos);
			//= new Vector.<Number>(Map.SOUND_TYPES.length);
			var soundTypePercentagesAroundBoat:Vector.<Number> = new Vector.<Number>(Map.SOUND_TYPES.length);
			_map.getSoundTypePercentages(boatOnMapPos, 3, 3, soundTypePercentagesAroundBoat);
			
			//var s1:String = (soundTypePercentagesAroundBoat[Map.SOUND_TYPE_LAND] * 100).toFixed(1);
			//var s2:String = (soundTypePercentagesAroundBoat[Map.SOUND_TYPE_WATER] * 100).toFixed(1);
			//var s3:String = (soundTypePercentagesAroundBoat[Map.SOUND_TYPE_3] * 100).toFixed(1);
			//trace(	"SOUND_TYPE_1 is in", s1, "%\n", "SOUND_TYPE_2 is in", s2, "%\n", "SOUND_TYPE_3 is in", s3, "% of requested area");
			//trace("-----------------------------");
			
			soundPlayer.mix(soundTypePercentagesAroundBoat);
		}
		
		private function onScoreTick(e:Event):void 
		{
			soundPlayer.playScoreTick(0.333);
		}
		
		
		public function changeScore(e:Event, data:int):void 
		{
			_hud.changeScore(data);
		}
		
		
		
		private var lt:int = getTimer();
		
		private function frame(e:EnterFrameEvent):void 
		{
			soundPlayer.update();
			
			
			
			/*
			var ti:int = getTimer();
			if (int(lt / 1000) < int(ti / 1000)) {
				_hud.changeScore(1);
			}
			lt = ti;
			*/
			//if (Math.random()<1/60.0) 
		}
		
		
		
	}

}