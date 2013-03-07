package clouds 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class CloudController extends Sprite
	{
		
		private var _cloudTypeAmount:int;
		private var _cloudTextures:Vector.<SubTexture> = new Vector.<SubTexture>();
		private var _shadowTextures:Vector.<SubTexture> = new Vector.<SubTexture>();
		
		private var _cloudLayer:Sprite;
		private var _shadowLayer:Sprite;
		
		private var _clouds:Vector.<Image> = new Vector.<Image>();
		private var _shadows:Vector.<Image> = new Vector.<Image>();
		
		private var _targetCloudAmount:int = 3;
		private var _lastMovement:Point;
		
		private var layerHeight:Number = 1;
		
		public function CloudController(cloudLayer:Sprite, shadowLayer:Sprite, cloudTextures:Vector.<SubTexture>, shadowTextures:Vector.<SubTexture>) 
		{
			this._cloudLayer = cloudLayer;
			this._shadowLayer = shadowLayer;
			
			_shadowLayer.x = layerHeight * BootjeTest.HEIGHT_TO_X_OFFSET;
			_shadowLayer.y = layerHeight * BootjeTest.HEIGHT_TO_Y_OFFSET;
			
			this._cloudTextures = cloudTextures;
			this._shadowTextures = shadowTextures;
			_cloudTypeAmount = _cloudTextures.length;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function move(movement:Point):void 
		{
			var mx:Number = movement.x * layerHeight * BootjeTest.HEIGHT_PARALLAX_EXAG;
			var my:Number = movement.y * layerHeight * BootjeTest.HEIGHT_PARALLAX_EXAG;
			_cloudLayer.x += mx;
			_cloudLayer.y += my;
			_shadowLayer.x += mx;
			_shadowLayer.y += my;
			_lastMovement = movement;
		}
		
		/*cloudImage = new Image(cloudTextures[cloudImageIndex]);
			shadowImage = new Image(shadowTextures[cloudImageIndex]);
			shadowImage.x = height * BootjeTest.HEIGHT_TO_X_OFFSET;
			shadowImage.y = height * BootjeTest.HEIGHT_TO_Y_OFFSET;*/
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			for (var i:int = 0; i < _targetCloudAmount; i++) {
				var typeIndex:int = int(Math.random() * _cloudTypeAmount);
				var cloudTex:Texture = _cloudTextures[typeIndex];
				var shadowTex:Texture = _shadowTextures[typeIndex];
				var cloud:Image = new Image(cloudTex);
				var shadow:Image = new Image(shadowTex);
				_cloudLayer.addChild(cloud);
				_shadowLayer.addChild(shadow);
				positionClouds(cloud, _clouds, false);
				shadow.x = cloud.x;
				shadow.y = cloud.y;
				_clouds.push(cloud);
				_shadows.push(shadow);
			}
			
			_cloudLayer.flatten();
			_shadowLayer.flatten();
			
			touchable = false;
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		private function frame(e:EnterFrameEvent):void 
		{
			
			// change weather
			/*var seconds:Number = getTimer() / 1000.0;
			var phaseDuration:Number = 10;
			
			var phase:Number = seconds % phaseDuration; // i.e. 0..10
			var phaseRad:Number = Math.PI * 2 * phase / phaseDuration; // 0..TWO_PI;
			var sin:Number = -Math.cos(phaseRad);
			
			_targetCloudAmount = MathUtils.map(sin, -1, 1, 3, 10);
			trace(phase, sin, _targetCloudAmount);*/
			
			
			
			// Remove clouds if they are offscreen
			
			var cloud:Image, shadow:Image;
			var cWidth:int, cHeight:int;
			var leftTop:Point = new Point(), rightBottom:Point = new Point();
			var cloudLeftTop:Point = new Point(), cloudRightBottom:Point = new Point();
			var shadowLeftTop:Point = new Point(), shadowRightBottom:Point = new Point();
			var cloudShadowRectangle:Rectangle;
			var stageRectangle:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			
			var cloudsChanged:Boolean = false;
			for (var i:int = 0; i < _clouds.length; i++) {
				cloud = _clouds[i];
				shadow = _shadows[i];
				rightBottom.x = cWidth = cloud.width;
				rightBottom.y = cHeight = cloud.height;

				// get global edges of cloud & shadow
				cloud.localToGlobal(leftTop, cloudLeftTop);
				cloud.localToGlobal(rightBottom, cloudRightBottom);
				shadow.localToGlobal(leftTop, shadowLeftTop);
				shadow.localToGlobal(rightBottom, shadowRightBottom);
				
				// create a global rectangle that covers cloud & shadow
				var minX:Number = Math.min(cloudLeftTop.x, cloudRightBottom.x, shadowLeftTop.x, shadowRightBottom.x);
				var maxX:Number = Math.max(cloudLeftTop.x, cloudRightBottom.x, shadowLeftTop.x, shadowRightBottom.x);
				var minY:Number = Math.min(cloudLeftTop.y, cloudRightBottom.y, shadowLeftTop.y, shadowRightBottom.y);
				var maxY:Number = Math.max(cloudLeftTop.y, cloudRightBottom.y, shadowLeftTop.y, shadowRightBottom.y);
				cloudShadowRectangle = new Rectangle(minX, minY, maxX - minX, maxY - minY);
				
				// check if offscreen
				if (!cloudShadowRectangle.intersects(stageRectangle)) {
					// remove
					cloudsChanged = true;
					_clouds.splice(i, 1);
					_shadows.splice(i, 1);
					_cloudLayer.unflatten();
					_shadowLayer.unflatten();
					_cloudLayer.removeChild(cloud);
					_shadowLayer.removeChild(shadow);
					cloud.dispose();
					shadow.dispose();
					i--;
				}
			}
			
			// add clouds if needed
			var toAdd:int = _targetCloudAmount - _clouds.length;
			if (toAdd > 0) {
				//TODO: add depending on last movement
				//trace(_lastMovement); // x<0 -> cloud layer is moving left, add on the right
			}
			
			if (cloudsChanged) {
				_cloudLayer.flatten();
				_shadowLayer.flatten();
			}
			
			
			
		}
		
		private function positionClouds(c:Image, ca:Vector.<Image>, offscreen:Boolean, retries:int = 5):void {
			if (!offscreen) {
				do {
					c.x = MathUtils.random(0, stage.stageWidth - c.width);// Math.random() * stage.stageWidth;
					c.y = MathUtils.random(0, stage.stageHeight - c.height);// Math.random() * stage.stageHeight;
					retries--;
				} while (retries>0 && cloudOverlap(c, ca));
			}
			else {
				//var edge:int = int(Math.random() * 4);
				var screenRect:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				do {
					var leftRight:Boolean = Math.random() < 0.5;
					if (leftRight) {
						c.x = MathUtils.randomExcept( -c.width * 2, stage.stageWidth + c.width, -c.width, stage.stageWidth);
						c.y = MathUtils.random( -c.height, stage.stageHeight);
					} else {
						c.x = MathUtils.random( -c.width, stage.stageWidth);
						c.y = MathUtils.randomExcept( -c.height * 2, stage.stageHeight + c.height, -c.height, stage.stageHeight);
					}
					
					retries--;
					var inView:Boolean = c.getBounds(stage).intersects(screenRect);
					var overlapWithOtherCloud:Boolean = cloudOverlap(c, ca);
					var tryAgain:Boolean = retries > 0 && inView && overlapWithOtherCloud;
				} while (tryAgain);
			}
			
		}
		
		
		
		
		
		private function cloudOverlap(c:Image, ca:Vector.<Image>):Boolean 
		{
			var overlap:Boolean = false;
			var cloudBounds:Rectangle = new Rectangle();
			var testBounds:Rectangle = new Rectangle();
			for (var i:int = 0; i < ca.length; i++) {
				c.getBounds(this, cloudBounds);
				ca[i].getBounds(this, testBounds);
				if (cloudBounds.intersects(testBounds)) {
					return true;
				}
			}
			return false;
		}
		
		private static function random(v0:Number, v1:Number):Number {
			return v0 + Math.random() * (v1 - v0);
		}
		
	}

}