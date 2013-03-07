package 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	//[SWF(width="1024", height="768", frameRate="60", backgroundColor="#8888ff")]
	public class Main extends Sprite 
	{
		
		public static const FPS:int = 60;
		
		private var starling:Starling;
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			// new to AIR? please read *carefully* the readme.txt files!
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Starling.handleLostContext = false;
			Starling.multitouchEnabled = true;
			
			starling = new Starling(BootjeTest, stage);
			starling.antiAliasing = 4;
			//starling.showStats = true;
			starling.start();
		}
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}