package collectables
{
	import com.greensock.easing.Sine;
	import com.greensock.TweenMax;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class FloatingPenguin extends Sprite 
	{
		[Embed(source = "../media/textures/penguin64.png")] 
		private const Penguin:Class;
		private var penguinImage:Image;
		
		public function FloatingPenguin() 
		{
			penguinImage = new Image(Texture.fromBitmap(new Penguin()));
			penguinImage.pivotX = penguinImage.width * 0.5;
			penguinImage.pivotY = penguinImage.height * 0.5;
			addChild(penguinImage);
			touchable = false;
			TweenMax.to(penguinImage, MathUtils.random(0.2,0.8), { y:8, yoyo:true, repeat: -1, ease: Sine.easeInOut } );
			
			//penguinImage.rotation = (Math.random() * 10) * 180 / Math.PI;
			//TweenMax.to(penguinImage, 1 + Math.random(), { rotation:-penguinImage.rotation, repeat: -1, ease: Sine.easeInOut } );
		}
		
	}

}