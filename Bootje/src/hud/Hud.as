package hud 
{
	import map.World;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class Hud extends Sprite 
	{
		private var compass:Compass;
		private var score:int = 0;
		public var scoreDisplay:ScoreDisplay;
		
		public function Hud(world:World) 
		{
			compass = new Compass(world);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			compass.x = stage.stageWidth - 168;
			compass.y = stage.stageHeight - 168;
			addChild(compass);
			
			scoreDisplay = new ScoreDisplay();
			scoreDisplay.x = stage.stageWidth - 180;
			scoreDisplay.y = 64;
			scoreDisplay.touchable = false;
			addChild(scoreDisplay);
		}
		
		
		public function changeScore(amount:int):void 
		{
			score+=amount;
			scoreDisplay.update(score);
		}
		
	}

}