package  
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class MathUtils 
	{
		
		public static const TWO_PI:Number = 2 * Math.PI;
		
		public static function random(v0:Number, v1:Number):Number {
			return v0 + Math.random() * (v1 - v0);
		}
		
		public static function randomExcept(v0:Number, v1:Number, e0:Number, e1:Number):Number {
			var v:Number;
			do {
				v = random(v0, v1);
			} while (v > e0 && v < e1);
			return v;
		}
		
		public static function map(v:Number, v0:Number, v1:Number, w0:Number, w1:Number):Number {
			return w0 + (w1 - w0) * (v - v0) / (v1 - v0);
		}
	}

}