package morn.core.components
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class StarBar extends View
	{
		private var _skin:String;
		
		private var _bmpdColor:BitmapData;
		private var _bmpdGray:BitmapData;
		private var _bmpdHalf:BitmapData;
		private var _starArray:Array;
		
		private var _value:Number = 1.5;
		private var _max:int = 3;
		private var _spaceX:int;
		
		public function StarBar(skin:String = null)
		{
			_starArray = new Array();
			this.skin = skin;
		}

		public function set skin(value:String):void
		{
			if(_skin != value){
				_skin = value;
				
				_starArray.splice(0, _starArray.length);
				_bmpdColor = App.asset.getBitmapData(_skin);
				_bmpdGray = _bmpdColor.clone();
				_bmpdGray.applyFilter(_bmpdGray, _bmpdGray.rect, new Point(), grayFilter);
				_bmpdHalf = _bmpdColor.clone();
				var halfRect:Rectangle = _bmpdGray.rect;
				halfRect.left  = halfRect.width / 2;
				_bmpdHalf.applyFilter(_bmpdHalf, halfRect, new Point(halfRect.left), grayFilter);
				
				_starArray.push(_bmpdGray, _bmpdHalf, _bmpdColor);
				
				callLater(render);
			}
		}
		private static const grayFilter:ColorMatrixFilter = new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0]);
		private function render():void{
			var value:Number = _value;
			var result:int;
			var temp:Number;
			
			while(numChildren > 0){
				removeChildAt(0);
			}
			
			for (var i:int = 0; i < _max; i++) 
			{
				temp = --value;
				if(temp >= 0){
					result = 2;
				}else if(temp == -0.5){
					result = 1;
				}else if(temp < -0.5){
					result = 0;
				}
				
				var bmp:AutoBitmap = new AutoBitmap();
				bmp.bitmapData = _starArray[result];
				
				bmp.x = i * (bmp.width + spaceX);
				addChild(bmp);
			}
		}
		
		public function get spaceX():int
		{
			return _spaceX;
		}
		
		public function set spaceX(value:int):void
		{
			if(_spaceX != value){
				_spaceX = value;
				
				callLater(render);
			}
		}
		
		public function get value():Number
		{
			return _value;
		}
		
		public function set value(value:Number):void
		{
			if(_value != value){
				_value = value;
				
				callLater(render);
			}
		}
		
		public function get max():int
		{
			return _max;
		}
		
		public function set max(value:int):void
		{
			if(_max != value){
				_max = value;
				
				callLater(render);
			}
		}
		
		public function get skin():String
		{
			return _skin;
		}
	}
}