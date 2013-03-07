package  
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class Frame extends Sprite 
	{
		[Embed(source = "media/textures/frameT.png")]
		private static const  FrameT:Class;
		private var imgFrameT:Image;
		
		[Embed(source = "media/textures/frameL.png")]
		private static const FrameL:Class;
		private var imgFrameL:Image;
		
		[Embed(source = "media/textures/frameR.png")]
		private static const  FrameR:Class;
		private var imgFrameR:Image;
		
		[Embed(source = "media/textures/frameB.png")]
		private static const FrameB:Class;
		private var imgFrameB:Image;
		
		public function Frame() 
		{
			imgFrameT = new Image(Texture.fromBitmap(new FrameT()));
			addChild(imgFrameT);
			
			imgFrameL = new Image(Texture.fromBitmap(new FrameL()));
			addChild(imgFrameL);
			
			imgFrameR = new Image(Texture.fromBitmap(new FrameR()));
			imgFrameR.x = 1024 - 32;
			addChild(imgFrameR);
			
			imgFrameB = new Image(Texture.fromBitmap(new FrameB()));
			imgFrameB.y = 1024 - 32;
			addChild(imgFrameB);
		}
		
		public function  resize(w:uint, h:uint):void 
		{
			this.width = w;
			this.height = h;
		}
		
	}

}