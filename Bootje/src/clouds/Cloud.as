package clouds 
{
	import map.Worldable;
	import starling.display.Image;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Cloud extends Image implements Worldable
	{
		
		//private static var z:Number = 1;
		private var worldX:Number, worldY:Number;
		private var depth:Number;
		private var w:Number, h:Number;
		
		public function Cloud(texture:Texture, worldX:Number, worldY:Number, depth:Number) 
		{
			super(texture);
			touchable = false;
			this.worldX = x = worldX;
			this.worldY = y = worldY;
			this.depth = depth; //getBo
			w = texture.width;
			h = texture.height;
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