package map 
{
	import animations.Bootje;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.SubTexture;
	import textures.AllTextures;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class GameMap extends Sprite
	{
		
		public static const BOAT_COLLIDE_LAND:String = "boatCollidLand";
		
		private static const LAND_PERCENTAGE_MAX:Number = 0.20; // 10%
		private static const CENTER_CLEAR_RADIUS:int = 8;
		private static const PERLIN_SIZE_DIVIDER:Number = 8;
		private static const PERLIN_OCTAVES:int = 3;
		
		public static const WATER:int = -1;
		public static const LAND:int = 0;
		
		private static function intToString(type:int, edgeType:int):String {
			switch (type) {
				case WATER: return ".."; break;
				case LAND: return "XX";break// "" + (edgeType < 10?"0":"") + edgeType; break;
			}
			return "  ";
		}
		
		
		private var tilesHorizontal:int, tilesVertical:int, size:int;
		
		/**
		 * LAND or WATER
		 */
		private var gameMap:Vector.<int>; 
		
		private var concreteType:Vector.<int>;
		
		private var tileLeftTop:Point = new Point();
		private var tileRightBottom:Point = new Point();
		private var waterTexture:Texture;
		private var concreteTextures:Vector.<SubTexture>;
		
		private var imageMapIndices:Vector.<int>;
		private var images:Vector.<Image>;
		//private var tfs:Vector.<TextField>;
		private var imageIsLeft:Vector.<Boolean>;
		private var imageIsRight:Vector.<Boolean>;
		private var imageIsBottom:Vector.<Boolean>;
		private var imageIsTop:Vector.<Boolean>;
				
		private var singleTileWidth:int, singleTileHeight:int;
		
		/**
		 * tiles per screen
		 */
		private var tilesOnScreenHorizontal:int;
		/**
		 * tiles per screen
		 */
		private var tilesOnScreenVertical:int;
		
		//public var boatQuad:Sprite;
		
		
		
		
		private var waterLayer:Sprite;
		private var landLayer:Sprite;
		
		
		public function GameMap(tilesHorizontal:int, tilesVertical:int, waterTexture:Texture, concreteTextures:Vector.<SubTexture>) 
		{
			this.tilesHorizontal = tilesHorizontal;
			this.tilesVertical = tilesVertical;
			size = tilesHorizontal * tilesVertical;
			
			this.waterTexture = waterTexture;
			this.concreteTextures = concreteTextures;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		
			
			// define tile width/height
			
			tileRightBottom.x = singleTileWidth = waterTexture.width;
			tileRightBottom.y = singleTileHeight = waterTexture.height;
			
			
			
			// define how many tiles on screen
			
			tilesOnScreenHorizontal = int(Math.round(Number(stage.stageWidth) / Number(singleTileWidth)) + 1);
			tilesOnScreenVertical = int(Math.round(Number(stage.stageHeight) / Number(singleTileHeight)) + 1);
			
			
			
			concreteType = new Vector.<int>(size);
			
			gameMap = new Vector.<int>(size);
			for (var i:int = 0; i < size; i++) {
				gameMap[i] = WATER;
			}
			
			// make top and bottom edge
			for (var xi:int = 0; xi < tilesHorizontal; xi++) {
				for (var yo:int = 0; yo < tilesOnScreenVertical;yo++) {
					gameMap[tilesHorizontal*yo + xi] = LAND;
					gameMap[(tilesVertical - 1 - yo) * tilesHorizontal + xi] = LAND;
				}
			}
			for (var yi:int = 0; yi < tilesVertical; yi++) {
				for (var xo:int = 0; xo < tilesOnScreenHorizontal;xo++) {
					gameMap[yi * tilesHorizontal + xo] = LAND;
					gameMap[yi * tilesHorizontal + tilesHorizontal - 1 - xo] = LAND;
				}
			}
			
			// generate islands with perlin noise
			
			var bmp:BitmapData = new BitmapData(tilesHorizontal, tilesVertical, false);
			var fractalNoise:Boolean = true;
			bmp.perlinNoise(tilesHorizontal/PERLIN_SIZE_DIVIDER, tilesVertical/PERLIN_SIZE_DIVIDER, PERLIN_OCTAVES, int(getTimer()*Math.random()*10000), false, fractalNoise, 7, true);
			
			i = 0;
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
							gameMap[i] = LAND;
							landCount++;
						}
						i++;
					}
				}
				thresh += 16;
				trace("wanted", wantedLandCount, "found", landCount, "of max", (tilesHorizontal-2)*(tilesVertical-2));
			} while (landCount < wantedLandCount && thresh<=256);
			
			trace("--------------");
			trace(this);
			
			// now remove tiles in center
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
						gameMap[coordsToIndex(xi, yi)] = WATER;
					}
				}
			}
			
			
			// now define concrete edges for each tile
			i = 0;
			for (yi = 0; yi < tilesVertical; yi++) {
				for (xi = 0; xi < tilesHorizontal; xi++) {
					var isWater:Boolean = (gameMap[coordsToIndex(xi, yi)] == WATER);
					var edgeIndex:int = -1;
					if (isWater) {
						// do nothing -> edge index = -1;
					} else {
						// is concrete
						var waterTop:Boolean = yi==0 || (yi > 0 && gameMap[coordsToIndex(xi, yi - 1)] == WATER);
						var waterRight:Boolean = xi==tilesHorizontal-1 || (xi < tilesHorizontal - 1 && gameMap[coordsToIndex(xi + 1, yi)] == WATER);
						var waterBottom:Boolean = yi==tilesVertical-1 || (yi < tilesVertical - 1 && gameMap[coordsToIndex(xi, yi + 1)] == WATER);
						var waterLeft:Boolean = xi==0 || (xi > 0 && gameMap[coordsToIndex(xi - 1, yi)] == WATER);
						edgeIndex = AllTextures.concreteEdgesToIndex(waterTop, waterRight, waterBottom, waterLeft);
					}
					concreteType[i] = edgeIndex;
					i++;
				}
			}
			
			//xi = 0;
			//yi = 0;
			
			trace(this);
			
		
						
			// now create the images
			
			waterLayer = new Sprite();
			//waterSprite.alpha = 0.2;
			landLayer = new Sprite();
			
			addChild(waterLayer);
			addChild(landLayer);
			
			
			
			var mapTileOffsetX:int = tilesHorizontal / 2 - tilesOnScreenHorizontal / 2;
			var mapTileOffsetY:int = tilesVertical / 2 - tilesOnScreenVertical / 2;
			
			
			var index:int;
			images = new Vector.<Image>();
			//tfs = new Vector.<TextField>();
			imageIsLeft = new Vector.<Boolean>();
			imageIsTop = new Vector.<Boolean>();
			imageIsBottom = new Vector.<Boolean>();
			imageIsRight = new Vector.<Boolean>();
			imageMapIndices = new Vector.<int>();
			for (var yy:int = 0; yy < tilesOnScreenVertical;yy++) {
				for (var xx:int = 0; xx < tilesOnScreenHorizontal; xx++) {
					var texture:Texture;
					isWater = true;
					index = coordsToIndex(xx + mapTileOffsetX, yy + mapTileOffsetY);
					if (concreteType[index] == -1) {
						texture = waterTexture;
					} else {
						texture = concreteTextures[concreteType[index]];
						isWater = false;
					}
					var img:Image = new Image(texture);
					img.touchable = false;
					img.x = xx * singleTileWidth;
					img.y = yy * singleTileHeight;
					
					if (isWater) {
						waterLayer.addChild(img);
					} else {
						landLayer.addChild(img);
					}
					//addChildAt(img, 0);
					
					images.push(img);
					/*var tf:TextField = new TextField(128, 127, "hoi", "Verdana", 24, 0, true);
					tf.border = true;
					addChild(tf);
					tf.x = img.x;
					tf.y = img.y;
					tf.text = (xx + mapTileOffsetX) + "/" + (yy + mapTileOffsetY);
					tfs.push(tf);*/
					imageMapIndices.push(index);
					imageIsLeft.push(xx == 0);
					imageIsRight.push(xx == tilesOnScreenHorizontal - 1);
					imageIsTop.push(yy == 0);
					imageIsBottom.push(yy == tilesOnScreenVertical - 1);
				}
			}
			
			/*boatQuad = new Sprite();
			var quad:Quad = new Quad(50, 50, 0xff0000);
			xx = tilesOnScreenHorizontal / 2;
			yy = tilesOnScreenVertical / 2;
			quad.x = -25;
			quad.y = -25;
			boatQuad.addChild(quad);
			boatQuad.x = xx * singleTileWidth;
			boatQuad.y = yy * singleTileHeight;
			addChild(boatQuad);*/
			
			trace(xi, yi);
			touchable = false;
			
			landLayer.flatten();
			waterLayer.flatten();
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		
		
		
		private function frame(e:EnterFrameEvent):void 
		{
			//var ti:int = getTimer();
			
			var image:Image;
			var i:int;
			var globalLeftTop:Point = new Point();
			var globalRightBottom:Point = new Point();
			var jumpTileLeftToRight:Boolean = false;
			var jumpTileRightToLeft:Boolean = false;
			var jumpTileTopToBottom:Boolean = false;
			var jumpTileBottomToTop:Boolean = false;
			var flat:Boolean = true;
			var mapCoords:Vector.<int> = new Vector.<int>();
			var mapX:int, mapY:int;
			var newMapX:int, newMapY:int;
			var newMapIndex:int;
			
			
			
			//for (var ee:int = 0; ee < allEdgeImages.length; ee++) {
			//	for (i = 0; i < allEdgeImages[ee].length;i++) {
				//trace(allEdgeImages[ee].length);
			//}
			
			
			
			
			for (i = 0; i < images.length; i++) {
				
				
					
					// get image
					image = images[i];
					
					// get global edge positions of image
					image.localToGlobal(tileLeftTop, globalLeftTop);
					image.localToGlobal(tileRightBottom, globalRightBottom);
					
					// reset jump
					jumpTileBottomToTop = jumpTileLeftToRight = jumpTileRightToLeft = jumpTileTopToBottom = false;
					
					if (globalLeftTop.x < -singleTileWidth) {
						jumpTileLeftToRight = true;
					} else if (globalRightBottom.x > stage.stageWidth + singleTileWidth) {
						jumpTileRightToLeft = true;
					}
					
					if (globalLeftTop.y < -singleTileHeight) {
						jumpTileTopToBottom = true;
					} else if (globalRightBottom.y > stage.stageHeight + singleTileHeight) {
						jumpTileBottomToTop = true;
					}
					
					
					if (jumpTileBottomToTop || jumpTileLeftToRight || jumpTileRightToLeft || jumpTileTopToBottom) {
					//if (globalLeftTop.x < -singleTileWidth) {
						if (flat) {
							flat = false;
							landLayer.unflatten();
							waterLayer.unflatten();
						}
						
						indexToCoords(imageMapIndices[i], mapCoords);
						newMapX = mapX = mapCoords[0];
						newMapY = mapY = mapCoords[1];
						
						if (jumpTileLeftToRight) {
							image.x += tilesOnScreenHorizontal * singleTileWidth;
							newMapX += tilesOnScreenHorizontal;
							newMapX = Math.max(0, Math.min(tilesHorizontal - 1, newMapX));
							newMapIndex = coordsToIndex(newMapX, newMapY);
							/*tfs[i].x += tilesOnScreenHorizontal * singleTileWidth;
							tfs[i].text = newMapX + "/" + newMapY;*/
						} else if (jumpTileRightToLeft) {
							image.x -= tilesOnScreenHorizontal * singleTileWidth;
							newMapX -= tilesOnScreenHorizontal;
							newMapX = Math.max(0, Math.min(tilesHorizontal - 1, newMapX));
							newMapIndex = coordsToIndex(newMapX, newMapY);
							/*tfs[i].x -= tilesOnScreenHorizontal * singleTileWidth;
							tfs[i].text = newMapX + "/" + newMapY;*/
						}
						
						if (jumpTileTopToBottom) {
							image.y += tilesOnScreenVertical * singleTileHeight;
							newMapY += tilesOnScreenVertical;
							newMapY = Math.max(0, Math.min(tilesVertical - 1, newMapY));
							newMapIndex = coordsToIndex(newMapX, newMapY);
							/*tfs[i].y += tilesOnScreenVertical * singleTileWidth;
							tfs[i].text = newMapX + "/" + newMapY;*/
						} else if (jumpTileBottomToTop) {
							image.y -= tilesOnScreenVertical * singleTileHeight;
							newMapY -= tilesOnScreenVertical;
							newMapY = Math.max(0, Math.min(tilesVertical - 1, newMapY));
							newMapIndex = coordsToIndex(newMapX, newMapY);
							/*tfs[i].y -= tilesOnScreenVertical * singleTileWidth;
							tfs[i].text = newMapX + "/" + newMapY;*/
						}

						
						imageMapIndices[i] = newMapIndex;
						if (concreteType[newMapIndex] == -1) {
							image.texture = waterTexture;
							if (image.parent == landLayer) {
								landLayer.removeChild(image);
								waterLayer.addChild(image);
							}
						} else {
							image.texture = concreteTextures[concreteType[newMapIndex]];
							if (image.parent == waterLayer) {
								waterLayer.removeChild(image);
								landLayer.addChild(image);
							}
						}
					}
				
				
			}
			
			
			if (!flat) {
				landLayer.flatten();
				waterLayer.flatten();
			}
			
			//trace("frameTime", getTimer() - ti);
		}
		
		
		
		
		private function coordsToIndex(x:int, y:int):int {
			return y * tilesHorizontal + x;
		}
		
		private function indexToCoords(i:int, result:Vector.<int>=null):Vector.<int> {
			var out:Vector.<int>;
			if (result) {
				out = result;
			} else {
				out = new Vector.<int>();
			}
			var y:int = i / tilesHorizontal;
			var x:int = i % tilesHorizontal;
			out[0] = x;
			out[1] = y;
			return out;
		}
		
		private function getTile(x:int, y:int):int {
			return gameMap[y * tilesHorizontal + x];
		}
		
		private function setTile(x:int, y:int, type:int):void {
			gameMap[y * tilesHorizontal + x] = type;
		}
		
		public function toString():String {
			var out:String = "";
			var nl:String = "\n";
			var i:int = 0;
			for (var y:int = 0; y < tilesVertical; y++) {
				for (var x:int = 0; x < tilesHorizontal; x++) {
					out += intToString(gameMap[i], concreteType[i]);
					i++;
				}
				out += nl;
			}
			
			return out;
		}
		
		
		
		public function collide(bootje:Bootje):void 
		{
			
			var boatMov:Point = bootje.getMovement();
			var stageRect:Rectangle = bootje.bounds;// getStageRect();
			stageRect.x += boatMov.x;
			stageRect.y += boatMov.y;
			
			var boatMapX:Number = stageRect.x - this.x;
			var boatMapY:Number = stageRect.y - this.y;
			
			var x0:Number = stageRect.x - this.x;
			var y0:Number = stageRect.y - this.y;
			var x1:Number = stageRect.x + stageRect.width - this.x;
			var y1:Number = stageRect.y + stageRect.height - this.y;
			
			var mapX0:int = int(tilesHorizontal/2 -1 + (x0 - stage.stageWidth / 2) / singleTileWidth);
			var mapY0:int = int(tilesVertical / 2 -1 + (y0 - stage.stageHeight / 2) / singleTileHeight);
			var mapX1:int = int(tilesHorizontal/2 -1 + (x1 - stage.stageWidth / 2) / singleTileWidth);
			var mapY1:int = int(tilesVertical / 2 -1 + (y1 - stage.stageHeight / 2) / singleTileHeight);
			
			var mapIndex00:int = coordsToIndex(mapX0, mapY0);
			var mapIndex01:int = coordsToIndex(mapX0, mapY1);
			var mapIndex10:int = coordsToIndex(mapX1, mapY0);
			var mapIndex11:int = coordsToIndex(mapX1, mapY1);
			
			var collideLeftEdge:Boolean = false;
			var collideRightEdge:Boolean = false;
			var collideTopEdge:Boolean = false;
			var collideBottomEdge:Boolean = false;
			
			if (concreteType[mapIndex00] != -1) {
				collideLeftEdge = true;
				collideTopEdge = true;
			} else if (concreteType[mapIndex01] != -1) {
				collideLeftEdge = true;
				collideBottomEdge = true;
			} else if (concreteType[mapIndex10] != -1) {
				collideRightEdge = true;
				collideTopEdge = true;
			} else if (concreteType[mapIndex11] != -1) {
				collideRightEdge = true;
				collideBottomEdge = true;
			}
			
			if (!collideRightEdge && !collideBottomEdge && !collideLeftEdge && !collideTopEdge) {
				//trace("WATER");
			} else {
				var collide:Boolean = false;
				if (collideLeftEdge && boatMov.x < 0 || collideRightEdge && boatMov.y > 0) {
					bootje.bounceHorizontal();
					collide = true;
				}
				if (collideTopEdge && boatMov.y < 0 || collideBottomEdge && boatMov.y > 0) {
					bootje.bounceVertical();
					collide = true;
				}
				
				dispatchEventWith(BOAT_COLLIDE_LAND);
				//trace("land...");
			}
			
			/*if (concreteType[mapIndex] == -1) {
				trace("WATER");
				return WATER;
			} else {
				trace("LAND");
				return LAND;// concreteType[mapIndex];// image.texture = concreteTextures[concreteType[newMapIndex]];
			}*/
			//trace(mapX, mapY);
		}
		
		public function getMapType(stageRect:Rectangle):int 
		{
			//var boatStageX:Number = bootje.x;
			//var boatStageY:Number = bootje.y;
			var boatMapX:Number = stageRect.x - this.x;
			var boatMapY:Number = stageRect.y - this.y;
			//unflatten();
			//boatQuad.x = boatMapX;
			//boatQuad.y = boatMapY;
			//trace(boatMapX, boatMapY);
			
			var x0:Number = stageRect.x - this.x;
			var y0:Number = stageRect.y - this.y;
			var x1:Number = stageRect.x + stageRect.width - this.x;
			var y1:Number = stageRect.y + stageRect.height - this.y;
			
			var mapX0:int = int(tilesHorizontal/2 -1 + (x0 - stage.stageWidth / 2) / singleTileWidth);
			var mapY0:int = int(tilesVertical / 2 -1 + (y0 - stage.stageHeight / 2) / singleTileHeight);
			var mapX1:int = int(tilesHorizontal/2 -1 + (x1 - stage.stageWidth / 2) / singleTileWidth);
			var mapY1:int = int(tilesVertical / 2 -1 + (y1 - stage.stageHeight / 2) / singleTileHeight);
			
			var mapIndex00:int = coordsToIndex(mapX0, mapY0);
			var mapIndex01:int = coordsToIndex(mapX0, mapY1);
			var mapIndex10:int = coordsToIndex(mapX1, mapY0);
			var mapIndex11:int = coordsToIndex(mapX1, mapY1);
			
			if (concreteType[mapIndex00] != -1) {
				return LAND;
			} else if (concreteType[mapIndex01] != -1) {
				return LAND;
			} else if (concreteType[mapIndex10] != -1) {
				return LAND;
			} else if (concreteType[mapIndex11] != -1) {
				return LAND;
			} else {
				return WATER;
			}
			/*if (concreteType[mapIndex] == -1) {
				trace("WATER");
				return WATER;
			} else {
				trace("LAND");
				return LAND;// concreteType[mapIndex];// image.texture = concreteTextures[concreteType[newMapIndex]];
			}*/
			//trace(mapX, mapY);
		}
		
		
		
		private function getWaterBounds():Vector.<Rectangle> {
			var out:Vector.<Rectangle> = new Vector.<Rectangle>();
			for (var i:int = 0; i < waterLayer.numChildren; i++) {
				out.push(waterLayer.getChildAt(i).bounds);
			}
			return out;
		}
		
		private function getLandBounds():Vector.<Rectangle> {
			var out:Vector.<Rectangle> = new Vector.<Rectangle>();
			for (var i:int = 0; i < waterLayer.numChildren; i++) {
				out.push(landLayer.getChildAt(i).bounds);
			}
			return out;
		}
		
		
		override public function set x(value:Number):void {
			var lastX:Number = x;
			super.x = value;
			var dx:Number = x - lastX;
			parallaxLayers(dx,0);
		}
		
		override public function set y(value:Number):void {
			var lastY:Number = y;
			super.y = value;
			var dy:Number = y - lastY;
			parallaxLayers(0,dy);
		}
		
		private function parallaxLayers(deltaX:Number, deltaY:Number):void {
			for (var layerName:String in layerDictionary) {
				(layerDictionary[layerName] as Sprite).x += (deltaX * (layerHeight[layerName]) * (BootjeTest.HEIGHT_PARALLAX_EXAG - 1));
				(layerDictionary[layerName] as Sprite).y += (deltaY * (layerHeight[layerName]) * (BootjeTest.HEIGHT_PARALLAX_EXAG - 1));
			}
			/*for (var i:int = 0; i < layerDictionary.length; i++) {
				trace(i);
				if (layerHeight[i]) {
					(layerDictionary[i] as Sprite).x += (deltaX * height * (BootjeTest.HEIGHT_PARALLAX_EXAG - 1));
				}
			}*/
		}
		
		/*override public function set y(value:Number):void {
			var lastY:Number = y;
			super.y = value;
			var dy:Number = y - lastY;
		}*/
		
		private var layerDictionary:Array = new Array();
		private var layerHeight:Array = new Array();
		
		public function newLayer(identifier:String, height:Number=0):Sprite {
			if (layerDictionary[identifier]) {
				throw new Error("Layer exists, please remove or use other name!");
			} else {
				var sprite:Sprite = new Sprite();
				sprite.touchable = false;
				layerDictionary[identifier] = sprite;
				layerHeight[identifier] = height;
				addChild(sprite);
				return sprite;
			}
		}
		
		
		
		/**
		 * Assumes that object is smaller than tile
		 * @param	identifier
		 * @param	object
		 * @param	inWater
		 */
		public function addToLayer(identifier:String, object:DisplayObject, inWaterLandOrBoth:int, boatCollect:Boolean = false, boatCollectCallback:Function = null):void {
			if (!layerDictionary[identifier]) {
				throw new Error("Cant add to a non-existing layer, create first");
			} else {
				var sprite:Sprite = layerDictionary[identifier] as Sprite;
				var tileIndex:int;
				var type:int;
				var correctType:Boolean;
				do {
					tileIndex = int(Math.random() * gameMap.length);
					type = gameMap[tileIndex];
					correctType = (inWaterLandOrBoth==2) || (inWaterLandOrBoth==0 && type == WATER) || (inWaterLandOrBoth==1 && type == LAND);
				} while (!correctType);
				
				var tileXY:Vector.<int> = indexToCoords(tileIndex);
				var tileX:int = tileXY[0];
				var tileY:int = tileXY[1];
				var mapTileOffsetX:int = tilesHorizontal / 2 - tilesOnScreenHorizontal / 2;
				var mapTileOffsetY:int = tilesVertical / 2 - tilesOnScreenVertical / 2;
				var spriteX:Number = (tileX - mapTileOffsetX) * singleTileWidth;
				var spriteY:Number = (tileY - mapTileOffsetY) * singleTileHeight;
				spriteX += Math.random() * (singleTileWidth - object.width);
				spriteY += Math.random() * (singleTileHeight - object.height);
				object.x = spriteX;
				object.y = spriteY;
				//trace(tileX,tileY,spriteX, spriteY);
				sprite.addChild(object);
			}
		}
		
		public function removeFromLayer(identifier:String, object:DisplayObject, dispose:Boolean = true):void {
			if (!layerDictionary[identifier]) {
				throw new Error("Cant add to a non-existing layer, create first");
			} else {
				var sprite:Sprite = layerDictionary[identifier] as Sprite;
				sprite.removeChild(object);
				if (dispose) object.dispose();
			}
		}
		
		public function removeLayer(identifier:String, dispose:Boolean = true ):void {
			if (!layerDictionary[identifier]) {
				throw new Error("Cant add to a non-existing layer, create first");
			} else {
				var sprite:Sprite = layerDictionary[identifier] as Sprite;
				removeChild(sprite);
				if (dispose) sprite.dispose();
				layerDictionary[identifier] = null;
				layerHeight[identifier] = null;
			}
		}
	}

}