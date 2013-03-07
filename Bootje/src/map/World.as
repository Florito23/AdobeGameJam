package map 
{
	import animations.Explosion;
	import boat.Bootje;
	import clouds.AnimObject;
	import clouds.Cloud;
	import flash.desktop.InteractiveIcon;
	import flash.display.Bitmap;
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
	public class World extends Sprite
	{
		
		public static const HEIGHT_TO_X_OFFSET:Number = -48;
		public static const HEIGHT_TO_Y_OFFSET:Number = -256;
		public static const HEIGHT_PARALLAX_EXAG:Number = 1.2;
		
		public static const BOAT_COLLIDE_LAND:String = "boatCollidLand";
		
		private var _bootje:Bootje;
		
		
		
		private var tileLeftTop:Point = new Point();
		private var tileRightBottom:Point = new Point();
		
		private var _halfStageWidth:Number, _halfStageHeight:Number;
		private var _stageRect:Rectangle;
		
		private var waterTexture:Texture;
		private var concreteTextures:Vector.<SubTexture>;
		
		private var imageMapIndices:Vector.<int>;
		private var images:Vector.<Image>;
				
		private var singleTileWidth:int, singleTileHeight:int;
		
		/**
		 * tiles per screen
		 */
		private var tilesOnScreenHorizontal:int;
		/**
		 * tiles per screen
		 */
		private var tilesOnScreenVertical:int;
		
		private var mapTilesHorizontal:int, mapTilesVertical:int;// , size:int;
		
		private var _mapSprite:Sprite;
		
		/**
		 * "width" of this sprite in pixels
		 */
		private var _fullWidth:Number;
		/**
		 * "height" of this sprite in pixels
		 */
		private var _fullHeight:Number;
		
		/*
		 * CLOUDS
		 */
		private static const CLOUD_DENSITY_PER_TILE:Number = 1 / 40.0;
		private var _cloudTextures:Vector.<SubTexture>;
		private var _cloudShadowTextures:Vector.<SubTexture>;
		private var _cloudSprite:Sprite;
		private var _cloudShadowSprite:Sprite;
		
		
		
		
		/*
		
		
		
		private var _cloudPositions:Vector.<Point>;
		private var _cloudTypes:Vector.<int>;*/
		
		
		
		private var tiledMap:Map;
		
		
		private var _worldables:Vector.<Worldable>;
				
		private var _allTextures:AllTextures;
		
		private var _splashLayer:Sprite;
		
		private var collectables:Array;
		
		public function World(tiledMap:Map, allTextures:AllTextures) 
		{
			
			this.tiledMap = tiledMap;
			
			this.mapTilesHorizontal = tiledMap.tilesHorizontal;
			this.mapTilesVertical = tiledMap.tilesVertical;
			
			this.waterTexture = allTextures.waterTexture;// waterTexture;
			this.concreteTextures = allTextures.concreteTextures;// concreteTextures;
			
			this._cloudShadowTextures = allTextures.shadowTextures;
			this._cloudTextures = allTextures.cloudTextures;
			
			this._allTextures = allTextures;
			
			_worldables = new Vector.<Worldable>();
			
			_bootje = new Bootje(allTextures.bootjeTextures);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		
		
		
		
		
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		
			
			_stageRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			// define half of stage
			_halfStageWidth = stage.stageWidth / 2;
			_halfStageHeight = stage.stageHeight / 2;
			
			// define single tile width/height	
			singleTileWidth = waterTexture.width;
			singleTileHeight = waterTexture.height;
			
			// defint full width/height (pixels)
			_fullWidth = singleTileWidth * mapTilesHorizontal;
			_fullHeight = singleTileHeight * mapTilesVertical;
			
			// define how many tiles we need maximum on screen
			tilesOnScreenHorizontal = int(Math.round(Number(stage.stageWidth) / Number(singleTileWidth)) + 1);
			tilesOnScreenVertical = int(Math.round(Number(stage.stageHeight) / Number(singleTileHeight)) + 1);
			
			// Now create all images starting top left
			_mapSprite = new Sprite();
			_mapSprite.touchable = false;
			super.addChild(_mapSprite);
			var tileIndex:int;
			var tileType:int;
			var concreteType:int;
			images = new Vector.<Image>();
			imageMapIndices = new Vector.<int>();
			for (var yy:int = 0; yy < tilesOnScreenVertical;yy++) {
				for (var xx:int = 0; xx < tilesOnScreenHorizontal; xx++) {
					
					// get texture related to tiled map
					var texture:Texture;
					tileIndex = tiledMap.coordsToIndex(xx, yy);
					tileType = tiledMap.getTileType(tileIndex);
					if (tileType == Map.TILE_TYPE_WATER) {
						texture = waterTexture;
					} else {
						concreteType = tiledMap.getConcreteType(tileIndex);
						texture = concreteTextures[concreteType];
					}
					
					// create image and add it
					var img:Image = new Image(texture);
					img.touchable = false;
					img.x = xx * singleTileWidth;
					img.y = yy * singleTileHeight;
					_mapSprite.addChild(img);
					
					//register image
					images.push(img);
					
					// register image related tileIndex
					imageMapIndices.push(tileIndex);
				}
			}

			
			
			/// todo add all other stuff here:
			
			// LOW RES DROP MAP
			collectables = new Array();
			var col:int;
			var gameMapDrop:BitmapData = _allTextures.gamepMapDroppables.bitmapData;
			var tex:Texture;
			for (yy = 0; yy < gameMapDrop.height; yy++) {
				for (xx = gameMapDrop.width-1; xx >= 1 ; xx--) {
					col = gameMapDrop.getPixel(xx, yy) & 0xffffff;
					var wx:Number = Number(xx) / Number(gameMapDrop.width) * _fullWidth;
					var wy:Number = Number(yy) / Number(gameMapDrop.height) * _fullHeight;
					switch (col) {
						case AllTextures.STUFF_DROP_CONTAINERS:
							texture = _allTextures.ccontainerTextures[int(Math.random() * _allTextures.ccontainerTextures.length)];
							for (var pos:int = 0; pos < 2; pos++) {
								if (Math.random()<0.8) {
									wx += (Math.random() - 0.5) * 0.20 * texture.width;
									wy += (Math.random() - 0.5) * 0.20 * texture.height + pos*texture.height;
									var container:Cloud = new Cloud(texture, wx, wy, 0);
									container.x = wx;
									container.y = wy;
									addChild(container);
									registerWorldDisplayable(container);
								}
							}
							break;
							
						case AllTextures.LOWRES_STUFF_DROP_ADOBE:
							var coin:Cloud = new Cloud(_allTextures.adobeTexture, wx, wy, 0);
							coin.x = wx;
							coin.x = wy;
							coin.touchable = false;
							coin.visible = true;
							addChild(coin);
							registerWorldDisplayable(coin);
							break;
							
						case AllTextures.LOWRES_STUFF_DROP_TROPICANA:
							coin = new Cloud(_allTextures.beachTexture, wx, wy, 0);
							coin.x = wx;
							coin.x = wy;
							coin.touchable = false;
							coin.visible = true;
							addChild(coin);
							registerWorldDisplayable(coin);
							break;
							
						case AllTextures.LOWRES_STUFF_DROP_SHANTI:
							coin = new Cloud(_allTextures.shantiTexture, wx, wy, 0);
							coin.x = wx;
							coin.x = wy;
							coin.touchable = false;
							coin.visible = true;
							addChild(coin);
							registerWorldDisplayable(coin);
							break;
					}
				}
			}
			
			
			//HI RES DROPPABLES
			//COINS!
			var dropStuffMap:Bitmap = _allTextures.stuffDropMap;
			var dropStuff:BitmapData = dropStuffMap.bitmapData;
			var boatX:Number, boatY:Number;
			for (yy = 0; yy < dropStuff.height; yy++) {
				for (xx = 0; xx < dropStuff.width; xx++) {
					col = dropStuff.getPixel(xx, yy) & 0xffffff;
					wx = Number(xx) / Number(dropStuff.width) * _fullWidth;
					wy = Number(yy) / Number(dropStuff.height) * _fullHeight;
					
					switch (col) {
						case AllTextures.STUFF_DROP_COINS:
							//trace(x,y+"-->", wx, wy);
							if (Math.random()<0.25) {
								var anim:AnimObject = new AnimObject(_allTextures.bottleTextures, wx, wy, 0);
								anim.animate = true;// Math.random() < 0.2;
								anim.x = wx;
								anim.x = wy;
								anim.touchable = false;
								anim.visible = true;
								addChild(anim);
								registerWorldDisplayable(anim);
								collectables.push(anim);
							}
							break;
							
						case AllTextures.STUFF_BOMB:
							//trace(x,y+"-->", wx, wy);
							if (Math.random()<0.5) {
								coin = new Cloud(_allTextures.mineTexture, wx, wy, 0);
								coin.x = wx;
								coin.x = wy;
								coin.touchable = false;
								coin.visible = true;
								addChild(coin);
								registerWorldDisplayable(coin);
								collectables.push(coin);
							}
							break;
							
						
							
						/*case AllTextures.STUFF_DROP_CONTAINERS:
							wx = int(int(wx / 16) * 16);
							wy = int(int(wy / 2) * 2);
							var container:Cloud = new Cloud(_allTextures.ccontainerTextures[int(Math.random() * _allTextures.ccontainerTextures.length)], wx, wy, 0);
							container.x = wx;
							container.y = wy;
							addChild(container);
							registerWorldDisplayable(container);
							break;*/
							
							
							break;
						case AllTextures.STUFF_DROP_BOAT_START:
							trace("BOOAT",xx,yy+"-->", wx, wy);
							boatX = _bootje.x = wx;
							boatY = _bootje.y = wy;
							trace(_bootje.x, _bootje.y);
							break;
							
						
						default:
							break;
					}
				}
			}
			
		
			
			_splashLayer = new Sprite();
			_splashLayer.touchable = false;
			addChild(_splashLayer);
			for (var i:int = 0; i < SPLASH_COUNT; i++) {
				img = new Image(_allTextures.singleSplashTexture);
				img.x = stage.stageWidth / 2 + 200;
				img.y = stage.stageHeight / 2 + 200;
				_splashLayer.addChild(img);
				splashes[i] = img;
				splashLife[i] = 0;
				splashMov[i] = new Point();
			}
			
			
			
			
			//now add the bootje & set it in center
			
			addChild(_bootje);
			_bootje.x = boatX;
			_bootje.y = boatY;

			//trace(_bootje.x, _bootje.y);
			//for (xx = 0;xx<
			//_bootje.x = _fullWidth / 2;
			//_bootje.y = mapPosToSpritePos(new Point(0, 8)).y;
			//trace(_bootje.x, _bootje.y);
			//_bootje.y = _fullHeight / 2;
			
			
			// create cloud positions
			var cloudAmount:int = int(mapTilesHorizontal*mapTilesVertical*CLOUD_DENSITY_PER_TILE);
			//var _cloudPositions:Vector.<Point> = new Vector.<Point>();
			//var _cloudTypes:Vector.<int> = new Vector.<int>();
			_cloudShadowSprite = new Sprite();
			_cloudShadowSprite.touchable = false;
			_cloudSprite = new Sprite();
			_cloudSprite.touchable = false;
			for (i = 0; i < cloudAmount; i++) {
				var cx:Number = Math.random() * _fullWidth;
				var cy:Number = Math.random() * _fullHeight;
				var type:int = int(Math.random() * _cloudTextures.length);
				var cloud:Cloud;
				var isCloud:Boolean;
				for (var j:int = 0; j < 2; j++) {
					isCloud = j == 0;
					cloud = new Cloud(isCloud?_cloudTextures[type]:_cloudShadowTextures[type], cx, cy, isCloud?1:0);
					cloud.touchable = false;
					cloud.visible = false;
					registerWorldDisplayable(cloud);
					if (isCloud) {
						_cloudSprite.addChild(cloud);
					} else {
						_cloudShadowSprite.addChild(cloud);
					}
				}
			}
			addChild(_cloudShadowSprite);
			addChild(_cloudSprite);
			
			
			
			_cloudSprite = new Sprite();
			addChild(_cloudSprite);
			
			
			updateMapTiles();
			
			
			_mapSprite.flatten();
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		
		
		private function registerWorldDisplayable(worldable:Worldable):void 
		{
			_worldables.push(worldable);
		}
		
		
		
		
		
		
		
		
		private function frame(e:EnterFrameEvent):void 
		{
			
			//trace(_bootje.direction);
			
			//collide boat
			checkCollision();
			
			// move boat
			_bootje.frame(); 
			
			// splashes
			doSplashes();
			
			
			
			// change position of this sprite so that bootje is in center
			x = _halfStageWidth - _bootje.x;
			y = _halfStageHeight -_bootje.y;
			
			// make sure it doesnt clip
			x = Math.min(0, Math.max(-_fullWidth+stage.stageWidth, x));
			y = Math.min(0, Math.max(-_fullHeight+stage.stageHeight, y));
			
			// update map tiles
			updateMapTiles();
			
			// update worldables
			updateWorldables();
			
			// collect worldables
			collectWorldables();
		}
		
		
		public static const COLLIDE_EVENT_START:String = "collideStart";
		public static const COLLIDE_EVENT_SCRATCH_BEGIN:String = "collideScratchBegin";
		public static const COLLIDE_EVENT_SCRATCH_END:String = "collideScratchEnd";
		
		private var lastCollideEvent:String = "";
		private var lastColliding:Boolean = false;
		private var lastScratching:Boolean = false;
		private var tempCurrentBoatPosOnMap:Point = new Point();
		private var tempFutureBoatPosOnMap:Point = new Point();
		private function checkCollision():void 
		{
			// current and future boat position: (sprite coordinates)
			var currentBoatPos:Point = new Point(_bootje.x, _bootje.y);
			var futureBoatPos:Point = currentBoatPos.add(new Point(_bootje.movX, _bootje.movY));
			
			// transform these to map positions:
			spritePosToMapPos(currentBoatPos, tempCurrentBoatPosOnMap);
			spritePosToMapPos(futureBoatPos, tempFutureBoatPosOnMap);
			
			// map coordinates
			var hitLeftRight:int = 0;
			var cx:int = tempCurrentBoatPosOnMap.x;
			var cy:int = tempCurrentBoatPosOnMap.y;
			var cIndex:int = tiledMap.coordsToIndex(cx, cy);
			var fx:int = tempFutureBoatPosOnMap.x;
			var fy:int = tempFutureBoatPosOnMap.y;
			var fIndex:int = tiledMap.coordsToIndex(fx, fy);
			
			var colliding:Boolean = false;
			
			// over map tile edge?
			if (fx != cx || fy != cy) {
				
				// future tile is land?
				if (tiledMap.getTileType(fIndex) == Map.TILE_TYPE_LAND) {
			
					// get the futures bounce tile(s)
					var futureBounceLeft:Boolean = fx == cx - 1;
					var futureBounceRight:Boolean = fx == cx + 1;
					var futureBounceTop:Boolean = fy == cy - 1;
					var futureBounceBottom:Boolean = fy == cy + 1;
					
					// get current surrounding tiles
					var cLeft:int = tiledMap.coordsToIndex(cx - 1, cy);
					var cRight:int = tiledMap.coordsToIndex(cx + 1, cy);
					var cTop:int = tiledMap.coordsToIndex(cx, cy - 1);
					var cBottom:int = tiledMap.coordsToIndex(cx, cy + 1);
					
					var cTileLeftType:int = tiledMap.getTileType(cLeft);
					var cTileRightType:int = tiledMap.getTileType(cRight);
					var cTileTopType:int = tiledMap.getTileType(cTop);
					var cTileBottomType:int = tiledMap.getTileType(cBottom);
					
					var cWaterLeft:Boolean = cTileLeftType == Map.TILE_TYPE_WATER;
					var cWaterRight:Boolean = cTileRightType == Map.TILE_TYPE_WATER;
					var cWaterTop:Boolean = cTileTopType == Map.TILE_TYPE_WATER;
					var cWaterBottom:Boolean = cTileBottomType == Map.TILE_TYPE_WATER;
					
					var topEdge:Boolean = (futureBounceTop && _bootje.movY < 0);
					var bottomEdge:Boolean = (futureBounceBottom && _bootje.movY > 0);
					var leftEdge:Boolean = (futureBounceLeft && _bootje.movX < 0);
					var rightEdge:Boolean = (futureBounceRight && _bootje.movX > 0)
					
					
					
					// going top left:
					if (_bootje.movX <= 0 && _bootje.movY <= 0) {
						// scratching along top edge going left
						if (topEdge && !cWaterTop) {// && cWaterLeft) {
							_bootje.movY = 0; colliding = true;
						}
						// scratching along left edge going top
						if (leftEdge && !cWaterLeft) {// && cWaterTop) {
							_bootje.movX = 0; colliding = true;
						}
					}
					
					// going bottom left:
					else if (_bootje.movX <= 0 && _bootje.movY > 0) {
						// scratching along bottom edge going left
						if (bottomEdge && !cWaterBottom) {// && cWaterLeft) {
							_bootje.movY = 0; colliding = true;
						}
						// scatching along left edge going bottom
						if (leftEdge && !cWaterLeft) {// && cWaterBottom) {
							_bootje.movX = 0; colliding = true;
						}
					}
					
					// going top right:
					if (_bootje.movX > 0 && _bootje.movY <= 0) {
						// scratching along top edge going left
						if (topEdge && !cWaterTop) {// && cWaterLeft) {
							_bootje.movY = 0; colliding = true;
						}
						// scratching along left edge going top
						if (rightEdge && !cWaterRight) {// && cWaterTop) {
							_bootje.movX = 0; colliding = true;
						}
					}
					
					// going bottom right:
					else if (_bootje.movX > 0 && _bootje.movY > 0) {
						// scratching along bottom edge going left
						if (bottomEdge && !cWaterBottom) {// && cWaterLeft) {
							_bootje.movY = 0; colliding = true;
						}
						// scatching along left edge going bottom
						if (rightEdge && !cWaterRight) {// && cWaterBottom) {
							_bootje.movX = 0; colliding = true;
						}
					}
					
					
					
				}
			}
			
			var collidingEvent:String = "";
			
			if (!lastColliding && colliding && lastCollideEvent == "") {
				//trace("BANG");
				collidingEvent = COLLIDE_EVENT_START;
				dispatchEventWith(collidingEvent);
			}
			
			else if (lastColliding && colliding  && lastCollideEvent == COLLIDE_EVENT_START) {
				//trace("SCRATCH START");
				collidingEvent = COLLIDE_EVENT_SCRATCH_BEGIN;
				dispatchEventWith(collidingEvent);
			}
			
			else if (lastColliding && !colliding) { // && lastCollideEvent!=COLLIDE_EVENT_SCRATCH_END
				//trace("STOP SCRATCHING");
				collidingEvent = COLLIDE_EVENT_SCRATCH_END;
				dispatchEventWith(collidingEvent);
			};
			
			
			lastColliding = colliding;
			lastCollideEvent = collidingEvent;
			
		}
		
		
		private static const SPLASH_COUNT:int = 80;
		private var splashes:Vector.<DisplayObject> = new Vector.<DisplayObject>(SPLASH_COUNT);
		private var splashLife:Vector.<int> = new Vector.<int>(SPLASH_COUNT);
		private var splashMov:Vector.<Point> = new Vector.<Point>(SPLASH_COUNT);
		private var splashIndex:Number = 0;
		
		private function doSplashes():void 
		{
			
			var boatDir:Number = _bootje.currentDirection;
			
			var i:int = int(splashIndex);
			
			//var randomDir:Number = Math.random() * 2 * Math.PI;
			var oneDir:Boolean = Math.random() < 0.5;
			var randomDir:Number = boatDir + (oneDir ? -Math.PI / 2 : Math.PI / 2);
			//if (Math.random() < 0.2) randomDir = 0;
			var sideCos:Number = Math.cos(randomDir);
			var sideSin:Number = Math.sin(randomDir);
			splashes[i].x = _bootje.x - 16 + 16 * Math.cos(boatDir) + 8 * sideCos;// + 32 * Math.cos(boatD;
			splashes[i].y = _bootje.y - 32 + 16 * Math.sin(boatDir) + 8 * sideSin;
			splashMov[i].x = _bootje.speed * 0.20 * sideCos;
			splashMov[i].y = _bootje.speed * 0.20 * sideSin;
			splashes[i].alpha = 0.8 * _bootje.speed / Bootje.MAX_BOAT_SPEED;
			
			for (i = 0; i < SPLASH_COUNT; i++) {
				splashes[i].x += splashMov[i].x;
				splashes[i].y += splashMov[i].y;
				splashMov[i].x *= 0.98;
				splashMov[i].y *= 0.98;
				splashes[i].alpha -= 0.01;
			}
			
			splashIndex += 1.0;// 0.2;
			splashIndex %= SPLASH_COUNT;
		}
		
		
		
		private function collectWorldables():void 
		{
			var amount:int = _worldables.length;
			var w:Worldable;
			var wDisp:DisplayObject;
			var wRect:Rectangle = new Rectangle();
			
			var boatRect:Rectangle = new Rectangle(_bootje.x - _bootje.width / 2, _bootje.y - _bootje.height / 2, _bootje.width, _bootje.height);
			var maxSmallerX:Number = _bootje.width / 2;
			var maxSmallerY:Number = _bootje.height / 2;
			
			boatRect.x += maxSmallerX/2 * 0.9;
			boatRect.y += maxSmallerY/2 * 0.9;
			boatRect.width -= maxSmallerX * 0.9;
			boatRect.height -= maxSmallerX * 0.9;
			
			
			
			for (var i:int = 0; i < _worldables.length; i++) {
				
				// get worldable / worldable display object
				w = _worldables[i];
				wDisp = w as DisplayObject;
				if (wDisp.visible && collectables.indexOf(w) >= 0) {
					
					// is wordable collectable?
					wRect.x = wDisp.x;
					wRect.y = wDisp.y;
					wRect.width = wDisp.width;
					wRect.height = wDisp.height;
					
					if (wRect.intersects(boatRect)) {
						
						//trace("COIN", wRect.x, wRect.y);
						BootjeTest.soundPlayer.playCoin();
						dispatchEventWith("SCORE", true, 10);
						
						if (wDisp is Cloud) {
							if ((wDisp as Cloud).texture == _allTextures.mineTexture) {
								var sx:Number = wDisp.x;
								var sy:Number = wDisp.y;
								var explosioin:Explosion = new Explosion();
								explosioin.x = sx + wDisp.width/2;
								explosioin.y = sy + wDisp.height / 2;
								explosioin.scaleX = explosioin.scaleY = 2;
								addChild(explosioin);
								explosioin.start();
								dispatchEventWith("SCORE", true, -50);
							}
						}
						
						
						wDisp.parent.removeChild(wDisp, true);
						_worldables.splice(i, 1);
						i--;
						
					}
				}
			}
		}
		
		
		
		private function updateWorldables():void 
		{
			var amount:int = _worldables.length;
			var w:Worldable;
			var wDisp:DisplayObject;
			var depth:Number;
			var wRect:Rectangle = new Rectangle();
			var wRectCen:Point = new Point();
			var parallaxX:Number, parallaxY:Number, fac:Number;
			
			var dispX:Number, dispY:Number;
			var thisX:Number = this.x;
			var thisY:Number = this.y;
			
			for (var i:int = 0; i < amount; i++) {
				
				// get worldable / worldable display object
				w = _worldables[i];
				wDisp = w as DisplayObject;
				
				// get worldable depth
				depth = w.getDepth();
				
				// set positions of display object without parallax and get its bounds
				//wDisp.x = w.getWorldPositionX();// + depth * HEIGHT_TO_X_OFFSET;// + parallaxX;
				//wDisp.y = w.getWorldPositionY();// + depth * HEIGHT_TO_Y_OFFSET;
				
				
				
				//if (wDisp.x+wDisp.width
				
				
				wRect.x = w.getWorldPositionX() + thisX;
				wRect.y = w.getWorldPositionY() + thisY;
				wRect.height = w.getHeight();// wDisp.height;
				wRect.width = w.getWidth();// wDisp.width;
				
				//wDisp.getBounds(stage, wRect);

				
				
				// simple check:
				/*if (wRect.x > stage.stageWidth || wRect.x + wRect.width < 0 || wRect.y > stage.stageHeight || wRect.y + wRect.width < 0) {
					visible = false;
				} else {*/
				
					//var parallaxX:Number = 0;
					
				if (depth != 0) {
					parallaxX = 0;
					parallaxY = 0;
					fac = 0;
					/*var centerOfObjectXOnStage:Number = (wRect.x + wRect.width / 2); //depth * HEIGHT_PARALLAX_EXAG * cen
					var xInRelationToCenter:Number = centerOfObjectXOnStage - _halfStageWidth;
					var xAsPercentageStageInRelationToCenter:Number = xInRelationToCenter / stage.stageWidth;
					var xAsPercentageStageInRelationToCenterExag:Number = xAsPercentageStageInRelationToCenter * depth * HEIGHT_PARALLAX_EXAG;
					var exagInRelationToCenter:Number = xAsPercentageStageInRelationToCenterExag * stage.stageWidth;
					var exagPosOnStage:Number = exagInRelationToCenter + _halfStageWidth;
					parallaxX = exagPosOnStage - centerOfObjectXOnStage;*/
					
					//parallaxX = (wRect.x + wRect.width / 2 - _halfStageWidth) / stage.stageWidth * depth * HEIGHT_PARALLAX_EXAG * stage.stageWidth + _halfStageWidth - (wRect.x + wRect.width / 2);
					wRectCen.x = wRect.x + wRect.width / 2;
					wRectCen.y = wRect.y + wRect.height / 2;
					
					//parallaxX = (wRectCen.x - _halfStageWidth) * depth * HEIGHT_PARALLAX_EXAG + (_halfStageWidth - wRectCen.x);
					
					//parallaxX = (wRectCen.x - _halfStageWidth) * depth * HEIGHT_PARALLAX_EXAG - (wRectCen.x - _halfStageWidth);
					
					/*parallaxX = (depth * HEIGHT_PARALLAX_EXAG - 1) * (wRectCen.x - _halfStageWidth);
					parallaxY = (depth * HEIGHT_PARALLAX_EXAG - 1) * (wRectCen.y - _halfStageHeight);*/
					
					fac = (depth * HEIGHT_PARALLAX_EXAG - 1);
					parallaxX = fac * (wRectCen.x - _halfStageWidth);
					parallaxY = fac * (wRectCen.y - _halfStageHeight);
					
					//wDisp.x = w.getWorldPositionX() + depth * HEIGHT_TO_X_OFFSET + parallaxX;// + parallaxX;
					//wDisp.y = w.getWorldPositionY() + depth * HEIGHT_TO_Y_OFFSET + parallaxY;
					
					dispX = w.getWorldPositionX() + depth * HEIGHT_TO_X_OFFSET + parallaxX;
					dispY = w.getWorldPositionY() + depth * HEIGHT_TO_Y_OFFSET + parallaxY; //wDisp.y +
					wDisp.x = dispX;// += depth * HEIGHT_TO_X_OFFSET + parallaxX;// + parallaxX;
					wDisp.y = dispY;// += depth * HEIGHT_TO_Y_OFFSET + parallaxY;
					
					
					wRect.x = dispX + thisX;// w.getWorldPositionX() + thisX;
					wRect.y = dispY + thisY;// w.getWorldPositionY() + thisY;
					wRect.height = w.getHeight();// wDisp.height;
					wRect.width = w.getWidth();// wDisp.width;
					/*wRect.height = wDisp.height;
					wRect.width = wDisp.width;*/
					//wDisp.getBounds(stage, wRect);
				} else {
					wDisp.x = w.getWorldPositionX();
					wDisp.y = w.getWorldPositionY();
				}
				
				
				var intersects:Boolean = false;
				
				var x0:Number = wRect.x;
				var x1:Number = wRect.x + wRect.width;
				var y0:Number = wRect.y;
				var y1:Number = wRect.y + wRect.height;
				
				var sx0:Number = _stageRect.x;
				var sx1:Number = _stageRect.x + _stageRect.width;
				var sy0:Number = _stageRect.y;
				var sy1:Number = _stageRect.y + _stageRect.height;
				
				if (x1 < sx0 || x0 > sx1 || y1 < sy0 || y0 > sy1) {
					wDisp.visible = false;
				} else {
					wDisp.visible = true;
				}
				
				/*if (wRect.intersects(_stageRect)) {
					wDisp.visible = true;
				} else {
					wDisp.visible = false;
				}*/
				
				//}
				
			}
			
			// TODO: depth sorting setChildIndex
		}
		
		
		
		private function updateMapTiles():void {
			
			
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
			
			
			tileRightBottom.x = singleTileWidth;// = waterTexture.width;
			tileRightBottom.y = singleTileHeight;// = waterTexture.height;
			
			for (i = 0; i < images.length; i++) {
				
					// get image
					image = images[i];
					
					// get global edge positions of image
					image.localToGlobal(tileLeftTop, globalLeftTop);
					image.localToGlobal(tileRightBottom, globalRightBottom);
					
					// reset jump
					jumpTileBottomToTop = jumpTileLeftToRight = jumpTileRightToLeft = jumpTileTopToBottom = false;
					
					// check if image will jump from edge to edge
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
					
					// Image jumps! :
					if (jumpTileBottomToTop || jumpTileLeftToRight || jumpTileRightToLeft || jumpTileTopToBottom) {
					
						// unflatten
						if (flat) {
							flat = false;
							_mapSprite.unflatten();
						}
						
						// tiledMap coordinates of this image
						tiledMap.indexToCoords(imageMapIndices[i], mapCoords);
						newMapX = mapX = mapCoords[0];
						newMapY = mapY = mapCoords[1];
						
						// jump tile on screen and jump related map coordinates
						if (jumpTileLeftToRight) {
							image.x += tilesOnScreenHorizontal * singleTileWidth;
							newMapX += tilesOnScreenHorizontal;
							newMapX = Math.max(0, Math.min(mapTilesHorizontal - 1, newMapX));
							newMapIndex = tiledMap.coordsToIndex(newMapX, newMapY);
						} else if (jumpTileRightToLeft) {
							image.x -= tilesOnScreenHorizontal * singleTileWidth;
							newMapX -= tilesOnScreenHorizontal;
							newMapX = Math.max(0, Math.min(mapTilesHorizontal - 1, newMapX));
							newMapIndex = tiledMap.coordsToIndex(newMapX, newMapY);
						}
						if (jumpTileTopToBottom) {
							image.y += tilesOnScreenVertical * singleTileHeight;
							newMapY += tilesOnScreenVertical;
							newMapY = Math.max(0, Math.min(mapTilesVertical - 1, newMapY));
							newMapIndex = tiledMap.coordsToIndex(newMapX, newMapY);
						} else if (jumpTileBottomToTop) {
							image.y -= tilesOnScreenVertical * singleTileHeight;
							newMapY -= tilesOnScreenVertical;
							newMapY = Math.max(0, Math.min(mapTilesVertical - 1, newMapY));
							newMapIndex = tiledMap.coordsToIndex(newMapX, newMapY);
						}
						
						// change texture
						imageMapIndices[i] = newMapIndex;
						if (tiledMap.getTileType(newMapIndex) == Map.TILE_TYPE_WATER) {
							image.texture = waterTexture;
						} else {
							image.texture = concreteTextures[tiledMap.getConcreteType(newMapIndex)];
						}
						
						// set new map index
						imageMapIndices[i] = newMapIndex;
						
					}
				
				
			}
			
			
			// flatten;
			if (!flat) {
				_mapSprite.flatten();
			}
			
		}
		
		public function get bootje():Bootje 
		{
			return _bootje;
		}
		
		
		
		
		/*public function mapPosToSpritePos(point:Point, resultPoint:Point = null):Point {
			if (!resultPoint) {
				resultPoint = new Point();
			}
			resultPoint.x = MathUtils.map(point.x, 0, mapTilesHorizontal, singleTileWidth / 2, _fullWidth - singleTileWidth / 2);
			resultPoint.y = MathUtils.map(point.y, 0, mapTilesVertical, singleTileHeight / 2, _fullHeight - singleTileHeight / 2);
			resultPoint.x = Math.max(0, Math.min(_fullWidth, resultPoint.x));
			resultPoint.y = Math.max(0, Math.min(_fullHeight, resultPoint.y));
			return resultPoint;
		}*/
		
		public function mapPosToSpritePos(point:Point, resultPoint:Point = null):Point {
			if (!resultPoint) {
				resultPoint = new Point();
			}
			resultPoint.x = MathUtils.map(point.x, 0, mapTilesHorizontal-1, 0, _fullWidth - singleTileWidth);
			resultPoint.y = MathUtils.map(point.y, 0, mapTilesVertical-1, 0, _fullHeight - singleTileHeight);
			resultPoint.x = Math.max(0, Math.min(_fullWidth-singleTileWidth, resultPoint.x));
			resultPoint.y = Math.max(0, Math.min(_fullHeight-singleTileHeight, resultPoint.y));
			return resultPoint;
		}
		
		/**
		 * Sprite -> map tile pos
		 * @param	point
		 * @param	resultPoint
		 * @return
		 */
		public function spritePosToMapPos(point:Point, resultPoint:Point=null):Point {
			//var out:Point;
			if (resultPoint) {
				//out = resultPoint;
			} else {
				resultPoint = new Point();
			}
			
			resultPoint.x = MathUtils.map(point.x, 0, _fullWidth - singleTileWidth, 0, mapTilesHorizontal-1);
			resultPoint.y = MathUtils.map(point.y, 0, _fullHeight - singleTileHeight, 0, mapTilesVertical-1);
			resultPoint.x = Math.max(0, Math.min(mapTilesHorizontal - 1, resultPoint.x));
			resultPoint.y = Math.max(0, Math.min(mapTilesVertical - 1, resultPoint.y));
			return resultPoint;
		}
		
		/*public function spritePosToMapPos(point:Point, resultPoint:Point=null):Point {
			var out:Point;
			if (resultPoint) {
				out = resultPoint;
			} else {
				out = new Point();
			}
			
			out.x = MathUtils.map(point.x, 0+singleTileWidth/2, _fullWidth-singleTileWidth, 0, mapTilesHorizontal);
			out.y = MathUtils.map(point.y, 0 + singleTileHeight / 2, _fullHeight - singleTileHeight, 0, mapTilesVertical);
			out.x = Math.max(0, Math.min(mapTilesHorizontal - 1, out.x));
			out.y = Math.max(0, Math.min(mapTilesVertical - 1, out.y));
			return out;
		}*/
		
		
		
		/*public function collide(bootje:Bootje):void 
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
		}*/
		
		
		
		
		/*public function getMapType(stageRect:Rectangle):int 
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
		}*/
		
		
		
		/*private function getWaterBounds():Vector.<Rectangle> {
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
		}*/
		
		
		/*override public function set x(value:Number):void {
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
		}*/
		
		/*private function parallaxLayers(deltaX:Number, deltaY:Number):void {
			for (var layerName:String in layerDictionary) {
				(layerDictionary[layerName] as Sprite).x += (deltaX * (layerHeight[layerName]) * (BootjeTest.HEIGHT_PARALLAX_EXAG - 1));
				(layerDictionary[layerName] as Sprite).y += (deltaY * (layerHeight[layerName]) * (BootjeTest.HEIGHT_PARALLAX_EXAG - 1));
			}
		}*/
		
		/*override public function set y(value:Number):void {
			var lastY:Number = y;
			super.y = value;
			var dy:Number = y - lastY;
		}*/
		
		/*private var layerDictionary:Array = new Array();
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
		}*/
		
		
		
		/**
		 * Assumes that object is smaller than tile
		 * @param	identifier
		 * @param	object
		 * @param	inWater
		 */
		/*public function addToLayer(identifier:String, object:DisplayObject, inWaterLandOrBoth:int, boatCollect:Boolean = false, boatCollectCallback:Function = null):void {
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
		}*/
	}

}