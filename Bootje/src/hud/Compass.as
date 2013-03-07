package hud 
{
	import boat.Bootje;
	import com.greensock.easing.Sine;
	import com.greensock.TweenMax;
	import flash.geom.Point;
	import map.World;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class Compass extends Sprite 
	{
		[Embed(source = "../media/textures/compassDrop.png")] 
		private const CompassBitmap:Class;
		private var compassImage:Image;
		
		[Embed(source = "../media/textures/compassNeedle.png")] 
		private const NeedleBitmap:Class;
		private var neeldeImage:Image;
		
		private var _world:World;
		
		public function Compass(world:World) 
		{
			this._world = world;
			
			//super(Texture.fromBitmap(new CompassBitmap()));
			//pivotX = 110; // this.width * 0.5;
			//pivotY = 110; // this.height * 0.5;
			
			compassImage = new Image(Texture.fromBitmap(new CompassBitmap()));
			compassImage.pivotX = 110; // compassImage.width * 0.5;
			compassImage.pivotY = 110; // compassImage.height * 0.5;
			addChild(compassImage);
			
			neeldeImage = new Image(Texture.fromBitmap(new NeedleBitmap()));
			neeldeImage.pivotX = neeldeImage.width * 0.48;
			neeldeImage.pivotY = neeldeImage.height * 0.5;
			addChild(neeldeImage);
			
			addEventListener(TouchEvent.TOUCH, touchIt);
			
		}
		
		private var touchId:int = -1;
		private function touchIt(e:TouchEvent):void 
		{
			
			// no registered touch:
			if (touchId==-1) {
				var touchDown:Touch = e.getTouch(this, TouchPhase.BEGAN);
				if (touchDown) {
					touchId = touchDown.id;
					bootjeStart();
					bootjeMove(touchDown);
				}
			}
			
			// registered touch:
			if (touchId != -1) {
				
				// move
				var touchMoves:Vector.<Touch> = e.getTouches(this, TouchPhase.MOVED);
				var touchMoveCount:int = touchMoves.length;
				var touchMove:Touch;
				for (var i:int = 0; i < touchMoveCount; i++) {
					touchMove = touchMoves[i];
					if (touchMove.id == touchId) {
						bootjeMove(touchMove);
						
						neeldeImage.rotation = touchToDirection(touchMove);
			
						break;
					}
				}
				
				// up
				var touchEnds:Vector.<Touch> = e.getTouches(this, TouchPhase.ENDED);
				var touchEndCount:int = touchEnds.length;
				var touchEnd:Touch;
				for (i = 0; i < touchEndCount; i++) {
					touchEnd = touchEnds[i];
					if (touchEnd.id == touchId) {
						touchId = -1;
						bootjeStop();
						break;
					}
				}
			}
			
		}
		
		private function touchToDirection(t:Touch):Number 
		{
			var compassPoint:Point = t.getLocation(this);
			var relativeX:Number = compassPoint.x - pivotX;
			var relativeY:Number = compassPoint.y - pivotY;
			var direction:Number = Math.atan2(relativeY, relativeX);
			
			return direction;
		}
		
		private function bootjeStart():void {
			_world.bootje.targetSpeed = Bootje.MAX_BOAT_SPEED;
			if (Math.random() < 0.25) BootjeTest.soundPlayer.playToot();
		}
		
		private function bootjeMove(touch:Touch):void {
			var compassPoint:Point = touch.getLocation(this);
			var relativeX:Number = compassPoint.x - pivotX;
			var relativeY:Number = compassPoint.y - pivotY;
			var direction:Number = Math.atan2(relativeY, relativeX);
			_world.bootje.targetDirection = direction;
		}
		
		private function bootjeStop():void {
			_world.bootje.targetSpeed = 0;
		}
		
	}

}