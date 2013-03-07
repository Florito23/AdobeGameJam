package wasser 
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Water extends Sprite 
	{
		
		private var imgWidth:int, imgHeight:int;
		private var fullWidth:int, fullHeight:int;
		
		private var allImages:Vector.<Image> = new Vector.<Image>();
		private var allImageCount:int;
		
		/*private var leftImages:Vector.<Image> = new Vector.<Image>();
		private var rightImages:Vector.<Image> = new Vector.<Image>();
		private var topImages:Vector.<Image> = new Vector.<Image>();
		private var bottomImages:Vector.<Image> = new Vector.<Image>();*/
		
		public function Water() 
		{
			super();
			
			/*imgWidth = waterBitmap.width;
			imgHeight = waterBitmap.height;*/
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/*public function move(speed:Number, direction:Number):void 
		{
			direction += Math.PI;
			var bootjeMovX:Number = speed * Math.cos(direction);
			var bootjeMovY:Number = speed * Math.sin(direction);
			x += bootjeMovX;
			y += bootjeMovY;
		}*/
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/*var maxIY:int = int(Math.round(stage.stageHeight / imgHeight));
			var maxIX:int = int(Math.round(stage.stageWidth / imgWidth));
			fullWidth = (maxIX+1) * imgWidth;
			fullHeight = (maxIY+1) * imgHeight;
			trace(fullWidth, fullHeight);
			//trace(maxIY, maxIX);
			
			for (var iy:int = 0; iy < maxIY + 1; iy ++) {
				var isLeft:Boolean = iy == 0;
				var isRight:Boolean = ix == maxIY;
				var yy:Number = iy * imgHeight;
				for (var ix:int = 0; ix < maxIX + 1; ix ++ ) {
					var isTop:Boolean = ix == 0;
					var isBottom:Boolean = ix == maxIX;
					var xx:Number = ix * imgWidth;
					var texture:Texture = waterTexture;// Math.random() < 0.9 ? waterTexture : waterTextureDarker;
					var image:Image = new Image(texture);
					image.x = xx;
					image.y = yy;
					addChild(image);
					allImages.push(image);
					/*if (isLeft) leftImages.push(image);
					if (isRight) rightImages.push(image);
					if (isTop) topImages.push(image);
					if (isBottom) bottomImages.push(image);
				}
			}
			
			allImageCount = allImages.length;*/
			
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		private function frame(e:EnterFrameEvent):void 
		{
			/*var image:Image;
			var leftTop:Point = new Point(0, 0);
			var globalLeftTop:Point = new Point();
			var rightBottom:Point = new Point(imgWidth, imgHeight);
			var globalRightBottom:Point = new Point();
			for (var i:int = 0; i < allImageCount; i++) {
				image = allImages[i];
				image.localToGlobal(leftTop, globalLeftTop);
				image.localToGlobal(rightBottom, globalRightBottom);
				
				if (globalLeftTop.x < -imgWidth) {
					image.x += fullWidth;
				}
				if (globalLeftTop.y < -imgHeight) {
					image.y += fullHeight;
				}
				if (globalRightBottom.x > stage.stageWidth+imgWidth) {
					image.x -= fullWidth;
				}
				if (globalRightBottom.y > stage.stageHeight + imgHeight) {
					image.y -= fullHeight;
				}
			}*/
		}
		
	}

}