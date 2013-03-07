package textures
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import starling.textures.Texture;
	import starling.textures.SubTexture;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class AllTextures
	{
		
		//[Embed(source = "BootjeSemi_8x(128x102)in(128x128).png")]
		//[Embed(source="AndreasBoat_8x(128x95)in(128x128).png")]
		//[Embed(source = "AndreasBoat_8x(256x180)in(256x256).png")]
		[Embed(source="boat-directions.png")]
		private var BootjeAnim:Class;
		private var bootjeBitmap:Bitmap;
		private var bootjeTexture:Texture;
		private var _bootjeTextures:Vector.<SubTexture> = new Vector.<SubTexture>();
		private const BOOTJE_WIDTH:int = 192;// 128;
		private const BOOTJE_HEIGHT:int = 128;//18095;
		
		[Embed(source="Cloud0withShadow.png")]
		private var Cloud0:Class;
		[Embed(source="Cloud1withShadow.png")]
		private var Cloud1:Class;
		private var CloudClasses:Vector.<Class> = new <Class>[Cloud0, Cloud1];
		private var cloudBitmaps:Vector.<Bitmap> = new Vector.<Bitmap>();
		private var _cloudTextures:Vector.<SubTexture> = new Vector.<SubTexture>();
		private var _shadowTextures:Vector.<SubTexture> = new Vector.<SubTexture>();
		
		
		// concrete simple atlas contains:
		// 0000 0001 0010 0011
		// 0100 0101 0110 0111
		// 1000 1001 1010 1011
		// 1100 1101 1110 1111
		// bits refer to edge faces water = true
		
		[Embed(source="ConcreteSimpleAtlas.png")]
		private var ConcreteAtlas:Class;
		private var concretBitmap:Bitmap;
		private var concreteTexture:Texture;
		private var _concreteTextures:Vector.<SubTexture> = new Vector.<SubTexture>(16);
		
		[Embed(source="grayLagoon.png")]
		//[Embed(source="grayLagoonBlur10.png")]
		private var WaterClass:Class;
		private var waterBitmap:Bitmap;
		private var _waterTexture:Texture;
		
		// GameMape (water/land)
		[Embed(source="GameMap.png")]
		private var GameMapClass:Class;
		private var _gameBitmap:Bitmap;
		
		[Embed(source="LowResDropMap.png")]
		private var GameMapDroppables:Class;
		private var _gamepMapDroppables:Bitmap;
		
		[Embed(source="SoundMap.png")]
		private var SoundMapClass:Class;
		private var _soundBitmap:Bitmap;
		
		[Embed(source = "StuffDropMap.png")]
		private var StuffDropMap:Class;
		private var _stuffDropMap:Bitmap;
		
		public static const STUFF_DROP_COINS:int = 0xff0000;
		public static const STUFF_BOMB:int = 0x88aacc;
		public static const STUFF_DROP_CONTAINERS:int = 0x008800
		public static const STUFF_DROP_BOAT_START:int = 0x000000;
		public static const LOWRES_STUFF_DROP_ADOBE:int = 0x4488FF;
		public static const LOWRES_STUFF_DROP_TROPICANA:int = 0xff00ff;
		public static const LOWRES_STUFF_DROP_SHANTI:int = 0x00FF00;
		
		[Embed(source="Coin.png")]
		private var CoinClass:Class;
		private var _coinBitmap:Bitmap;
		private var _coinTexture:Texture;
		
		//[Embed(source="flashe.png")]
		[Embed(source="flasche-motion.png")]
		private var BottleClass:Class;
		private var _bottleBitmap:Bitmap;
		private var _bottleTexture:Texture;
		private var _bottleTextures:Vector.<SubTexture>;
		
		[Embed(source="mine.png")]
		private var MineClass:Class;
		private var _mineBitamp:Bitmap;
		private var _mineTexture:Texture;
		
		[Embed(source="AdobeBuilding.png")]
		private var AdobeClass:Class;
		private var _adobeBtimap:Bitmap;
		private var _adobeTexture:Texture;
		
		[Embed(source="shanti.png")]
		private var ShantiClass:Class;
		private var _shantiBitmap:Bitmap;
		private var _shantiTexture:Texture;
		
		[Embed(source="beachclub.png")]
		private var BeachClub:Class;
		private var _beachClub:Bitmap;
		private var _beachTexture:Texture;
		
		[Embed(source="SingleSplash.png")]
		private var SingleSplash:Class;
		private var _singleSplash:Bitmap;
		private var _singleSplashTexture:Texture;
		
		//Containers
		[Embed(source="droppables/Containers.png")]
		private var ContainerAtlas:Class;
		private var containerBitmap:Bitmap;
		private var containerTexture:Texture;
		private var _ccontainerTextures:Vector.<SubTexture> = new Vector.<SubTexture>(4);
		
		public function AllTextures()
		{
			// Bootje Textures
			bootjeBitmap = new BootjeAnim() as Bitmap;
			bootjeTexture = Texture.fromBitmap(bootjeBitmap);
			_bootjeTextures = new Vector.<SubTexture>();
			for (var i:int = 0; i < 8; i++)
			{
				var tx:int = i * BOOTJE_WIDTH;
				var ty:int = 0;
				var tw:int = BOOTJE_WIDTH;
				var th:int = BOOTJE_HEIGHT;
				var region:Rectangle = new Rectangle(tx, ty, tw, th);
				var tex:SubTexture = new SubTexture(bootjeTexture, region);
				_bootjeTextures.push(tex);
			}
			
			// Cloud Textures
			for each (var CloudClass:Class in CloudClasses)
			{
				var cloudBitmap:Bitmap = new CloudClass() as Bitmap;
				cloudBitmaps.push(cloudBitmap);
				var texture:Texture = Texture.fromBitmap(cloudBitmap);
				var cloudRect:Rectangle = new Rectangle(0, 0, cloudBitmap.width / 2, cloudBitmap.height);
				var shadowRect:Rectangle = new Rectangle(cloudBitmap.width / 2, 0, cloudBitmap.width / 2, cloudBitmap.height);
				var cloudTexture:SubTexture = new SubTexture(texture, cloudRect);
				var shadowTexture:SubTexture = new SubTexture(texture, shadowRect);
				_cloudTextures.push(cloudTexture);
				_shadowTextures.push(shadowTexture);
			}
			
			// concrete textures
			concretBitmap = new ConcreteAtlas() as Bitmap;
			concreteTexture = Texture.fromBitmap(concretBitmap);
			var size:int = 128;
			var index:int = 0;
			for (var y:int = 0; y < 4; y++) {
				for (var x:int = 0; x < 4; x++) {
					var rect:Rectangle = new Rectangle(x * size, y * size, size, size);
					var sub:SubTexture = new SubTexture(concreteTexture, rect);
					_concreteTextures[index] = sub;
					index++;
				}
			}
			
			//adobe
			_adobeBtimap = new AdobeClass() as Bitmap;
			_adobeTexture = Texture.fromBitmap(_adobeBtimap);
			
			// shanti
			_shantiBitmap = new ShantiClass() as Bitmap;
			_shantiTexture = Texture.fromBitmap(_shantiBitmap);
			
			//coin
			_coinBitmap = new CoinClass() as Bitmap;
			_coinTexture = Texture.fromBitmap(_coinBitmap);
			
			//
			_mineBitamp = new MineClass() as Bitmap;
			_mineTexture = Texture.fromBitmap(_mineBitamp);
			
			_bottleBitmap = new BottleClass() as Bitmap;
			_bottleTexture = Texture.fromBitmap(_bottleBitmap);
			_bottleTextures = new Vector.<SubTexture>(7);
			var indices:Vector.<int> = new <int> [ 0,1,2,3,4,5,7];
			var w:int = _bottleTexture.width / 8;
			var h:int = _bottleTexture.height;
			for (i = 0; i < 7; i++) {
				_bottleTextures[i] = new SubTexture(_bottleTexture, new Rectangle(indices[i] * w, 0, w, h));
			}
			
			
			
			// water texture
			waterBitmap = new WaterClass() as Bitmap;
			_waterTexture = Texture.fromBitmap(waterBitmap);
			
			// tropicana beach club
			_beachClub = new BeachClub() as Bitmap;
			_beachTexture = Texture.fromBitmap(_beachClub);
		
			_singleSplash = new SingleSplash() as Bitmap;
			_singleSplashTexture = Texture.fromBitmap(_singleSplash);
			
			// containers
			containerBitmap = new ContainerAtlas() as Bitmap;
			containerTexture = Texture.fromBitmap(containerBitmap);
			for (i = 0; i < _ccontainerTextures.length; i++) {
				var sw:int = containerTexture.width / 4;
				rect.x = sw * i;
				rect.y = 0;
				rect.width = sw;
				rect.height = containerTexture.height;
				_ccontainerTextures[i] = new SubTexture(containerTexture, rect);
			}
			
			
			// game map
			_gameBitmap = new GameMapClass() as Bitmap;
			
			// low res drop map
			_gamepMapDroppables = new GameMapDroppables() as Bitmap;
			
			
			// sound map
			_soundBitmap = new SoundMapClass() as Bitmap;
			
			// stuff drop map
			_stuffDropMap = new StuffDropMap() as Bitmap;
			
		}
		
		public static function concreteEdgesToIndex(waterTop:Boolean, waterRight:Boolean, waterBottom:Boolean, waterLeft:Boolean):int {
			var bitTop:int = waterTop ? 1:0;
			var bitRight:int = waterRight ? 1:0;
			var bitBottom:int = waterBottom ? 1:0;
			var bitLeft:int = waterLeft ? 1:0;
			var index:int = bitTop << 3 | bitRight << 2 | bitBottom << 1 | bitLeft; // encoded top, right, left, bottom
			return index;
		}

		
		
		public function get bootjeTextures():Vector.<SubTexture>
		{
			return _bootjeTextures;		
		}
		
		public function get cloudTextures():Vector.<SubTexture> 
		{
			return _cloudTextures;
		}
		
		public function get shadowTextures():Vector.<SubTexture> 
		{
			return _shadowTextures;
		}
		
		public function get waterTexture():Texture 
		{
			return _waterTexture;
		}
		
		public function get concreteTextures():Vector.<SubTexture> 
		{
			return _concreteTextures;
		}
		
		public function get gameBitmap():Bitmap 
		{
			return _gameBitmap;
		}
		
		public function get soundBitmap():Bitmap 
		{
			return _soundBitmap;
		}
		
		public function get stuffDropMap():Bitmap 
		{
			return _stuffDropMap;
		}
		
		public function get coinTexture():Texture 
		{
			return _coinTexture;
		}
		
		public function get ccontainerTextures():Vector.<SubTexture> 
		{
			return _ccontainerTextures;
		}
		
		public function get gamepMapDroppables():Bitmap 
		{
			return _gamepMapDroppables;
		}
		
		public function get adobeTexture():Texture 
		{
			return _adobeTexture;
		}
		
		public function get bottleTextures():Vector.<SubTexture> 
		{
			return _bottleTextures;
		}
		
		public function get beachTexture():Texture 
		{
			return _beachTexture;
		}
		
		public function get shantiTexture():Texture 
		{
			return _shantiTexture;
		}
		
		public function get singleSplashTexture():Texture 
		{
			return _singleSplashTexture;
		}
		
		public function get mineTexture():Texture 
		{
			return _mineTexture;
		}
	
	}

}