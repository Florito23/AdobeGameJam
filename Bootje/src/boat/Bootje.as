package boat 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import map.Worldable;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.SubTexture;
	import starling.textures.Texture;

	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Bootje extends Sprite //implements Worldable
	{
		
		public static const MAX_BOAT_SPEED:Number = 4;
		
		
		
		private var image:Image;
		private var dirSprite:Sprite;
		
		private static const TWO_PI:Number = Math.PI * 2;
		
		private var bootjeTextures:Vector.<SubTexture> = new Vector.<SubTexture>();
		private var bootjeTextureAmount:int;
		private var texIndex:Number = 0;

		private var _currentDirection:Number = 0;
		private var _targetDirection:Number = 0;
		
		private var _targetSpeed:Number = 0;
		private var _speed:Number = 0;// BootjeTest.BOAT_SPEED;
		
		private var _movX:Number = 0;
		private var _movY:Number = 0;
		
		//private var stageCenterX:Number, stageCenterY:Number;
		//		private var maxDistanceFromCenter:Number;
		
		//private var _boatAlphas:Vector.<Boolean>;
		
		public function Bootje(bootjeTextures:Vector.<SubTexture>) 
		{
			this.bootjeTextures = bootjeTextures;
			bootjeTextureAmount = bootjeTextures.length;
			
			image = new Image(bootjeTextures[0]);
			image.x = - image.width * 0.5;// -bootjeTextures[0].width * 2;
			image.y = - image.height * 0.75;// -bootjeTextures[0].height * 0.75;
			addChild(image);
			
			
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			x = stage.stageWidth / 2;
			y = stage.stageHeight / 2;
			
			/*stageCenterX = stage.stageWidth / 2;
			stageCenterY = stage.stageHeight / 2;
			x = stageCenterX;
			y = stageCenterY;
			maxDistanceFromCenter = Math.min(stage.stageWidth, stage.stageHeight) * 0.10;
*/
		}
		
		/*public function getZ():Number {
			return 0;
		}*/
		
		public function get speed():Number 
		{
			return _speed;
		}
		
		public function frame(e:EnterFrameEvent = null):void 
		{
			// move
			x += _movX;
			y += _movY;
			
			// smooth speed
			if (_targetSpeed > _speed) {
				_speed = 0.95 * _speed + 0.05 * _targetSpeed;
			} else {
				_speed = 0.99 * _speed + 0.01 * _targetSpeed;
			}
			
			// smooth direction
			_currentDirection = 0.87 * _currentDirection + 0.13 * _targetDirection;
			/*var temp:Number = (currentDirection * 180 / Math.PI % 360.0);
			if (temp < 0) temp += 360;
			trace("Bootje smoothed Direction", temp.toFixed(1));
			temp = (targetDirection * 180 / Math.PI % 360.0);
			if (temp < 0) temp += 360;
			trace("Bootje target Direction", temp.toFixed(1));
			*/
			directionToRotationsAndImages(_currentDirection);
			
			// update movX/ movY
			_movX = _speed * Math.cos(_currentDirection);
			_movY = _speed * Math.sin(_currentDirection);
			
			// smooth screen pos
			/*var targetX:Number = stageCenterX + _speed / BootjeTest.BOAT_SPEED * maxDistanceFromCenter * Math.cos(currentDirection);
			var targetY:Number = stageCenterY + _speed / BootjeTest.BOAT_SPEED * maxDistanceFromCenter * Math.sin(currentDirection);
			x = 0.99 * x + 0.01 * targetX;
			y = 0.99 * y + 0.01 * targetY;*/
			
			// MOTOR SOUND VOLUME
			BootjeTest.soundPlayer.setMotorVol(_speed / MAX_BOAT_SPEED);
		}
		
		
		public function set targetDirection(radians:Number):void {
			
			_targetSpeed = MAX_BOAT_SPEED;
			// make sure radians is in 0..TWO_PI;
			radians = radRange(radians);
			
			var radTurnLeft:Number = _currentDirection - radians;
			radTurnLeft = radRange(radTurnLeft);
			var radTurnRight:Number = radians - _currentDirection;
			radTurnRight = radRange(radTurnRight);
			
			if (Math.abs(radTurnLeft) < Math.abs(radTurnRight)) {
				// turn left;
				_targetDirection = _currentDirection - radTurnLeft;
			} else {
				// turn right;
				_targetDirection = _currentDirection + radTurnRight;
			}
			
		}
		
		public function get currentDirection():Number {
			var out:Number = _currentDirection % (MathUtils.TWO_PI);
			if (out < 0) out += MathUtils.TWO_PI;
			return out;
		}
		
		public function set targetSpeed(value:Number):void 
		{
			_targetSpeed = value;
		}
		
		public function get movX():Number 
		{
			return _movX;
		}
		
		public function get movY():Number 
		{
			return _movY;
		}
		
		public function set movX(value:Number):void 
		{
			_movX = value;
			//targetDirection = Math.atan2(movY, movX);
		}
		
		public function set movY(value:Number):void 
		{
			_movY = value;
			//targetDirection = Math.atan2(movY, movX);
		}
		
		private static function radRange(radians:Number):Number {
			while (radians < 0) radians += TWO_PI;
			radians %= TWO_PI;
			return radians;
		}
		
		/**
		 * Where 0 = right, PI/2 = down, PI = left,  PI*3/4 = up
		 */
		public function directionToRotationsAndImages(radians:Number):void {
			//var index:int = int( (radRange(radians+TWO_PI/16)) / -TWO_PI * 8);
			var index:int = int( (radRange(radians+TWO_PI/(bootjeTextureAmount*2))) / -TWO_PI * bootjeTextureAmount);
			while (index < 0) index += bootjeTextureAmount;
			index %= bootjeTextureAmount;
			if (index != texIndex) {
				texIndex = index;
				image.texture = bootjeTextures[texIndex];
			}
		}
		
		public function stopInstant():void 
		{
			_targetSpeed = _speed = 0;
		}

		/*public function getMovement():Point {
			var bootjeMovX:Number = _speed * Math.cos(direction);
			var bootjeMovY:Number = _speed * Math.sin(direction);
			return new Point(bootjeMovX, bootjeMovY);
		}
		
		
		public function getMovementOfSurrounding(height:Number = 0):Point
		{
			var dir:Number = direction + Math.PI;
			var bootjeMovX:Number = _speed * Math.cos(dir);
			var bootjeMovY:Number = _speed * Math.sin(dir);
			var exag:Number = MathUtils.map(height, 0, 1, 1, BootjeTest.HEIGHT_PARALLAX_EXAG);
			bootjeMovX *= exag;
			bootjeMovY *= exag;
			return new Point(bootjeMovX, bootjeMovY);
		}*/
		
		
	}

}