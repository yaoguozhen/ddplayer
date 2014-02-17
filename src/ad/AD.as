package ad 
{
	import data.Data;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class AD extends Sprite 
	{
		public static const IMAGE:String = "image";
		public static const VIDEO:String = "video";
		
		private var _currentAD:MovieClip;
		private var _images:Images;
		private var _video:Video;
		private var _type:String;
		private var _adStart:Boolean=false
		
		public function AD() :void
		{
			_images = new Images();
			_images.addEventListener("ready", readyHandler);
			_video = new Video();
			_video.addEventListener("ready", readyHandler);
		}
		private function readyHandler(evn:Event):void
		{
			if (_adStart)
			{
				Data.adShow = true;
				dispatchEvent(new Event("ready"));
			}
		}
		public function start():void
		{
			close();
			trace("==================================== 播放广告")
			_adStart = true;
			switch(_type)
			{
				case IMAGE:
					_currentAD = _images;
					if (_currentAD.ready)
					{
						Data.adShow = true;
						dispatchEvent(new Event("ready"));
					}
					break;
				case VIDEO:
					_currentAD = _video;
					break;
			}
			if (_currentAD)
			{
				addChild(_currentAD);
				_currentAD.start();
			}
		}
		public function setData(type:String,data:XML):void
		{
			_type = type;
			switch(_type)
			{
				case IMAGE:
					_images.init(data);
					break;
				case VIDEO:
					_video.init(data);
					break;
			}
		}
		public function load():void
		{
			if (_images)
			{
				_images.load();
			}
		}
		public function close():void
		{
			trace("==================================== 停止广告")
			if (_currentAD)
			{
				_currentAD.close();
				try
				{
					removeChild(_currentAD);
				}
				catch (err:Error)
				{
					
				}
				_currentAD = null;
			}
			_adStart = false;
			Data.adShow = false;
		}
		public function scaleAD():void
		{
			if (_currentAD)
			{
				_currentAD.scaleAD()
			}
		}
	}

}