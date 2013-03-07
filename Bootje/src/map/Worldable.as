package map 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public interface Worldable 
	{
		
		function getWorldPositionX():Number;
		function getWorldPositionY():Number;
		function getDepth():Number;
		function getWidth():Number;
		function getHeight():Number;
		//function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle;
		//function get visible():Boolean;
		//function get z():Number;
		//function set z(value:Number);
	}
	
}