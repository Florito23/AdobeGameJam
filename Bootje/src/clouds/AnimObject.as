package clouds 
{
	import map.Worldable;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class AnimObject extends Image implements Worldable
	{
		
		//private static var z:Number = 1;
		private var textures:Vector.<SubTexture>;
		private var currentFrame:Number;
		private var maxFrames:int
		private var worldX:Number, worldY:Number;
		private var depth:Number;
		private var w:Number, h:Number;
		
		public function AnimObject(textures:Vector.<SubTexture>, worldX:Number, worldY:Number, depth:Number) 
		{
			this.textures = textures;
			maxFrames = textures.length;
			currentFrame = int(Math.random() * maxFrames);
			super(textures[currentFrame]);
			touchable = false;
			this.worldX = x = worldX;
			this.worldY = y = worldY;
			this.depth = depth; //getBo
			w = texture.width;
			h = texture.height;
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, anim);
		}
		
		
		public function set animate(value:Boolean):void {
			if (value) {
				if (!hasEventListener(EnterFrameEvent.ENTER_FRAME)) {
					addEventListener(EnterFrameEvent.ENTER_FRAME, anim);
				}
			} else {
				if (hasEventListener(EnterFrameEvent.ENTER_FRAME)) {
					removeEventListener(EnterFrameEvent.ENTER_FRAME, anim);
				}
			}
		}
		
		private var spd:Number = MathUtils.random(0.08, 0.15);
		private function anim(e:EnterFrameEvent):void 
		{
			currentFrame += spd;// 0.15;
			currentFrame %= maxFrames;
			texture = textures[int(currentFrame)];
		}
		
		public function getWidth():Number {
			return w;
		}
		public function getHeight():Number {
			return h
		}
		
		public function getWorldPositionX():Number {
			return worldX;
		}
		
		public function getWorldPositionY():Number {
			return worldY;
		}
		
		public function getDepth():Number {
			return depth;
		}
		
	}

}