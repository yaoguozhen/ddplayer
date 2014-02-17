package ad 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class ImageScaleManager 
	{
		
		public function ImageScaleManager() 
		{
			
		}
		private function _scale(obj:MovieClip,width:Number,height:Number):void
		{			
			var areaPer:Number = width / height;
			var objPer:Number = obj.imageInitWidth / obj.imageInitHeight;

			if (objPer >= areaPer)
			{
				obj.width = width;
				obj.height = width / objPer;				
			}
			else
			{
				obj.height = height;
				obj.width = height * objPer;
			}
		}
		public function scale(obj:MovieClip,fullscreen:Boolean,width:Number,height:Number):void
		{
			if (obj.imageInitWidth > width || obj.imageInitHeight > height)
			{
				_scale(obj, width, height);
			}
			else
			{
				obj.width = obj.imageInitWidth;
				obj.height = obj.imageInitHeight;	
			}
		}
	}

}