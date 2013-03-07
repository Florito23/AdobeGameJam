package map 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import textures.AllTextures;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Map 
	{
		
		private static const LAND_PERCENTAGE_MAX:Number = 0.20; // 10%
		private static const CENTER_CLEAR_RADIUS:int = 8;
		private static const PERLIN_SIZE_DIVIDER:Number = 8;
		private static const PERLIN_OCTAVES:int = 3;
		
		private var _tilesHorizontal:int, _tilesVertical:int;// , size:int;
		private var _tilesAmount:int;
		
		
		public static const TILE_TYPE_WATER:int = -1;
		public static const TILE_TYPE_LAND:int = 0;
		
		/**
		 * LAND or WATER
		 */
		private var _tileTypes:Vector.<int>; 
		
		/**
		 * Type of land (for edge textures)
		 */
		private var _concreteTypes:Vector.<int>;
		
		
		/*
		 * 
		 * SOUND MAP
		 * 
		 */
		public static const SOUND_TYPE_LAND:int = 0;
		public static const SOUND_TYPE_WATER:int = 1;
		public static const SOUND_TYPE_SHANTI:int = 2;
		public static const SOUND_TYPE_SEAGULLS:int = 3;
		public static const SOUND_TYPE_TROPICANA:int = 4;
		public static const SOUND_TYPE_LAND_COLOR:int = 0x000000;
		public static const SOUND_TYPE_WATER_COLOR:int = 0xFFFFFF;
		public static const SOUND_TYPE_SHANTI_COLOR:int = 0x00FF00;
		public static const SOUND_TYPE_SEAGULLS_COLOR:int = 0x0000FF;
		public static const SOUND_TYPE_TROPICANA_COLOR:int = 0xFF00FF;
		public static const SOUND_TYPES:Vector.<int> = new <int> [
			SOUND_TYPE_LAND_COLOR,
			SOUND_TYPE_WATER_COLOR,
			SOUND_TYPE_SHANTI_COLOR,
			SOUND_TYPE_SEAGULLS_COLOR,
			SOUND_TYPE_TROPICANA_COLOR
		];
		
		
		/**
		 * Type of sound
		 */
		private var _soundMap:Vector.<int>;
		
		
		
		//private var mapBitmap:Bitmap;
		
		public function Map(mapBitmap:Bitmap, soundBitmap:Bitmap) //tilesHorizontal:int, tilesVertical:int
		{
			
			//mapBitmap = map;
			
			
			this._tilesHorizontal = mapBitmap.width;
			this._tilesVertical = mapBitmap.height;
			/*this._tilesHorizontal = tilesHorizontal;
			this._tilesVertical = tilesVertical;*/
			_tilesAmount = tilesHorizontal * tilesVertical;
			
			
			
			// create map with WATER
			_tileTypes = new Vector.<int>(_tilesAmount);
			for (var i:int = 0; i < _tilesAmount; i++) {
				_tileTypes[i] = TILE_TYPE_WATER;
			}
			
			// create map from bitmap
			i = 0;
			var bmp:BitmapData = mapBitmap.bitmapData;
			for (var yi:int = 0; yi < mapBitmap.height; yi++) {
				for (var xi:int = 0; xi < mapBitmap.width; xi++) {
					_tileTypes[i] = (bmp.getPixel(xi, yi) & 0xff) > 64 ? TILE_TYPE_WATER:TILE_TYPE_LAND;
					i++;
				}
			}
			
			// create sound map
			i = 0;
			_soundMap = new Vector.<int>();
			bmp = soundBitmap.bitmapData;
			for (yi = 0; yi < mapBitmap.height; yi++) {
				for (xi = 0; xi < mapBitmap.width; xi++) {
					_soundMap[i] = (bmp.getPixel(xi, yi) & 0xffffff);/// > 64 ? TILE_TYPE_WATER:TILE_TYPE_LAND;
					//trace(i,_soundMap[i]);
					i++;
				}
			}
			
			// Turn edges into LAND
			//TODO: this should not be necessary to be more than 1, cuz we should stop the map on edge!!!
			//generateNoiseMap();
			
			
			// Define the concrete edge types
			_concreteTypes = new Vector.<int>(_tilesAmount);
			i = 0;
			for (yi = 0; yi < tilesVertical; yi++) {
				for (xi = 0; xi < tilesHorizontal; xi++) {
					var isWater:Boolean = (_tileTypes[coordsToIndex(xi, yi)] == TILE_TYPE_WATER);
					var edgeIndex:int = -1;
					if (isWater) {
						// do nothing -> edge index = -1;
					} else {
						// is concrete
						var waterTop:Boolean = yi==0 || (yi > 0 && _tileTypes[coordsToIndex(xi, yi - 1)] == TILE_TYPE_WATER);
						var waterRight:Boolean = xi==tilesHorizontal-1 || (xi < tilesHorizontal - 1 && _tileTypes[coordsToIndex(xi + 1, yi)] == TILE_TYPE_WATER);
						var waterBottom:Boolean = yi==tilesVertical-1 || (yi < tilesVertical - 1 && _tileTypes[coordsToIndex(xi, yi + 1)] == TILE_TYPE_WATER);
						var waterLeft:Boolean = xi==0 || (xi > 0 && _tileTypes[coordsToIndex(xi - 1, yi)] == TILE_TYPE_WATER);
						edgeIndex = AllTextures.concreteEdgesToIndex(waterTop, waterRight, waterBottom, waterLeft);						
					}
					_concreteTypes[i] = edgeIndex;
					i++;
				}
			}
			
			trace(this);
			trace(_tilesHorizontal, _tilesVertical);
			
		}
		
		private function generateNoiseMap():void {
			var tilesOnScreenHorizontal:int = 1;
			var tilesOnScreenVertical:int = 1;
			
			for (var xi:int = 0; xi < tilesHorizontal; xi++) {
				for (var yo:int = 0; yo < tilesOnScreenVertical;yo++) {
					_tileTypes[tilesHorizontal*yo + xi] = TILE_TYPE_LAND;
					_tileTypes[(tilesVertical - 1 - yo) * tilesHorizontal + xi] = TILE_TYPE_LAND;
				}
			}
			for (var yi:int = 0; yi < tilesVertical; yi++) {
				for (var xo:int = 0; xo < tilesOnScreenHorizontal;xo++) {
					_tileTypes[yi * tilesHorizontal + xo] = TILE_TYPE_LAND;
					_tileTypes[yi * tilesHorizontal + tilesHorizontal - 1 - xo] = TILE_TYPE_LAND;
				}
			}
			
			
			
			// Generate map with Perlin Noise
			
			var bmp:BitmapData = new BitmapData(tilesHorizontal, tilesVertical, false);
			var fractalNoise:Boolean = true;
			bmp.perlinNoise(tilesHorizontal/PERLIN_SIZE_DIVIDER, tilesVertical/PERLIN_SIZE_DIVIDER, PERLIN_OCTAVES, int(getTimer()*Math.random()*10000), false, fractalNoise, 7, true);
			
			var i:int = 0;
			var col:int;
			
			var wantedLandCount:int = int((tilesHorizontal - 2) * (tilesVertical - 2) * LAND_PERCENTAGE_MAX);
			var thresh:int = 0;
			var landCount:int = 0;
			do {
				landCount = 0;
				i = 0;
				for (yi = 0; yi < tilesVertical; yi++) {
					for (xi = 0; xi < tilesHorizontal; xi++) {
						col = bmp.getPixel(xi, yi);
						col = col & 0xff; // 0..255;
						if (col < thresh) {
							_tileTypes[i] = TILE_TYPE_LAND;
							landCount++;
						}
						i++;
					}
				}
				thresh += 16;
				//trace("wanted", wantedLandCount, "found", landCount, "of max", (tilesHorizontal-2)*(tilesVertical-2));
			} while (landCount < wantedLandCount && thresh<=256);

			
			
			// Create a big circle with WATER in the center
			
			var cx:int = tilesHorizontal / 2;
			var cy:int = tilesVertical / 2;
			var x0:int = cx - CENTER_CLEAR_RADIUS;
			var x1:int = cx + CENTER_CLEAR_RADIUS;
			var y0:int = cy - CENTER_CLEAR_RADIUS;
			var y1:int = cy + CENTER_CLEAR_RADIUS;
			var dx:int, dy:int, d:Number;
			for (yi = y0; yi <= y1; yi++) {
				for (xi = x0; xi <= x1; xi++) {
					dx = cx -xi;
					dy = cy -yi;
					d = Math.sqrt(dx * dx + dy * dy);
					if (d <= CENTER_CLEAR_RADIUS) {
						_tileTypes[coordsToIndex(xi, yi)] = TILE_TYPE_WATER;
					}
				}
			}
		}
		
		public function getTileType(tileIndex:int):int {
			tileIndex = Math.max(0, Math.min(_tilesAmount - 1, tileIndex));
			return _tileTypes[tileIndex];
		}
		
		public function getConcreteType(tileIndex:int):int {
			tileIndex = Math.max(0, Math.min(_tilesAmount - 1, tileIndex));
			return _concreteTypes[tileIndex];
		}
		
		public function getSoundType(tileIndex:int):int {
			tileIndex = Math.max(0, Math.min(_tilesAmount - 1, tileIndex));
			return _soundMap[tileIndex];
		}
		
		
		/*public function getSoundTypePercentages(mapPoint:Point, tileAreaWidth:int, tileAreaHeight:int, result:Vector.<Number> = null):Vector.<Number> {
			var out:Vector.<Number>;
			if (result) {
				if (result.length != SOUND_TYPES.length) throw new Error("Please give me a result vector of length Map.SOUND_TYPES.length");
				out = result;
				for (var i:int = 0; i < out.length; i++) {
					out[i] = 0;
				}
			} else {
				out = new Vector.<Number>(SOUND_TYPES.length);
			}
			var countPerType:Vector.<int> = getSoundTypes(mapPoint, tileAreaWidth, tileAreaHeight);
			var totalCount:Number = tileAreaWidth * tileAreaHeight;
			trace("total=", totalCount);
			for (i = 0; i < out.length; i++) {
				out[i] = countPerType[i] / totalCount;
			}
			return out;
		}*/
		
		/**
		 * Returns a list of counted sound types
		 * @param	tileX
		 * @param	tileY
		 * @param	width
		 * @param	height
		 * @param	result
		 * @return
		 */
		public function getSoundTypePercentages(mapPoint:Point, tileAreaWidth:int, tileAreaHeight:int, result:Vector.<Number> = null):Vector.<Number> {
			var soundTypeAmount:int = SOUND_TYPES.length;
			
			// init result
			var out:Vector.<Number>;
			if (result) {
				if (result.length != soundTypeAmount) throw new Error("Please give me a result vector of length Map.SOUND_TYPES.length");
				out = result;
				for (var i:int = 0; i < out.length; i++) {
					out[i] = 0;
				}
			} else {
				out = new Vector.<int>(SOUND_TYPES.length);
			}
			
			// get mapPoint as ints
			var tileX:int = Math.max(0, Math.min(_tilesHorizontal - 1, int(mapPoint.x)));
			var tileY:int = Math.max(0, Math.min(_tilesVertical - 1, int(mapPoint.y)));
			
			// get map area
			var x0:int = tileX-tileAreaWidth / 2;
			var x1:int = x0 + tileAreaWidth;
			var y0:int = tileY-tileAreaHeight / 2;
			var y1:int = y0 + tileAreaHeight;
			
			// get max map area
			var areaSize:Number = tileAreaWidth * tileAreaHeight;
			if (areaSize <= 0) return out;
			
			// count sound types
			var counts:Vector.<int> = new Vector.<int>(SOUND_TYPES.length);
			var xx:int, yy:int;
			var st:int;
			var indexRow:int = 0, index:int = 0;
			var outsideY:Boolean, outsideX:Boolean;
			var soundTileType:int;
			for (yy = y0; yy < y1; yy++) {
				indexRow = yy * _tilesHorizontal;
				outsideY = yy<0 || yy>=_tilesVertical;
				for (xx = x0; xx < x1; xx++) {
					index = indexRow + xx;
					outsideX = xx<0 || xx>=_tilesHorizontal;
					if (outsideY || outsideX) {
						// do nothing
					} else {
						// inside:
						soundTileType = _soundMap[index];
						for (st = 0; st < soundTypeAmount; st++) {
							if (soundTileType == SOUND_TYPES[st]) {
								counts[st]++;
							}
						}
					}
				}
			}
			
			// now calc percentages
			for (i = 0; i < SOUND_TYPES.length; i++) {
				out[i] = counts[i] / areaSize;
			}
			return out;
		}
		
		public function coordsToIndex(x:int, y:int):int {
			x = Math.max(0, Math.min(_tilesHorizontal - 1, x));
			y = Math.max(0, Math.min(_tilesVertical - 1, y));
			return y * _tilesHorizontal + x;
		}
		
		public function indexToCoords(i:int, result:Vector.<int> = null):Vector.<int> {
			i = Math.max(0, Math.min(_tilesAmount-1, i));
			var out:Vector.<int>;
			if (result) {
				out = result;
			} else {
				out = new Vector.<int>();
			}
			var y:int = i / _tilesHorizontal;
			var x:int = i % _tilesHorizontal;
			out[0] = x;
			out[1] = y;
			return out;
		}
	
		
		private static function typeToString(type:int, edgeType:int):String {
			switch (type) {
				case TILE_TYPE_WATER: return ".."; break;
				case TILE_TYPE_LAND: return "XX";break// "" + (edgeType < 10?"0":"") + edgeType; break;
			}
			return "  ";
		}
		
		public function toString():String {
			var out:String = "";
			var nl:String = "\n";
			var i:int = 0;
			for (var y:int = 0; y < _tilesVertical; y++) {
				for (var x:int = 0; x < _tilesHorizontal; x++) {
					out += typeToString(_tileTypes[i], _concreteTypes[i]);
					i++;
				}
				out += nl;
			}
			
			return out;
		}
		
		public function get tilesHorizontal():int 
		{
			return _tilesHorizontal;
		}
		
		public function get tilesVertical():int 
		{
			return _tilesVertical;
		}
		
		
		
	}
	

}