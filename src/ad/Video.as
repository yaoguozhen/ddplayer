package ad 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import video.AdvVideoPlayer;
	import video.events.NetStreamEvent;
	import video.events.OnMetaDataEvent;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Video extends MovieClip 
	{
		private var _xml:XML;
		private var _videoPlayer:AdvVideoPlayer;
		private var _videoRatio:Number;
		private var _videoInitWidth:Number
		private var _videoInitHeight:Number;
		
		public function Video():void 
		{
			_videoPlayer = new AdvVideoPlayer();
			_videoPlayer.addEventListener(NetStreamEvent.CHANGE, netStreamChangeHandler);
			_videoPlayer.addEventListener(OnMetaDataEvent.ON_METADATA, onMetaDataHandler);
		}
		private function onMetaDataHandler(evn:OnMetaDataEvent):void
		{
			_videoInitWidth = evn.videoWidth;
			_videoInitHeight = evn.videoHeight;
			
			_videoRatio =_videoInitWidth / _videoInitHeight;
			scaleAD();
		}
		private function netStreamChangeHandler(evn:NetStreamEvent)
		{
			switch(evn.status)
			{
				case "NetStream.Buffer.Full":
					dispatchEvent(new Event("ready"));
					break;
			}
		}
		private function _scale():void
		{			
			var areaPer:Number = stage.stageWidth / (stage.stageHeight-40);

			if (_videoRatio >= areaPer)
			{
				_videoPlayer.width =  stage.stageWidth;
				_videoPlayer.height = _videoPlayer.width / _videoRatio;				
			}
			else
			{
				_videoPlayer.height =  stage.stageHeight-40;
				_videoPlayer.width = _videoPlayer.height * _videoRatio;
			}
		}
		public function init(xml:XML):void
		{
			_xml = xml;
		}
		public function scaleAD():void
		{
			if (_videoInitWidth > stage.stageWidth || _videoInitHeight > stage.stageHeight-40)
			{
				_scale();
			}
			else
			{
				_videoPlayer.width = _videoInitWidth;
				_videoPlayer.height = _videoInitHeight;	
			}
			
			_videoPlayer.x = (stage.stageWidth - _videoPlayer.width) / 2;
			_videoPlayer.y = (stage.stageHeight-40 - _videoPlayer.height) / 2;
		}
		public function start():void
		{
			_videoPlayer.play(_xml.@stream,"",3000,"false");
			addChild(_videoPlayer);
			scaleAD();
		}
		public function close():void
		{
			if (_videoPlayer.stage)
			{
				removeChild(_videoPlayer);
				_videoPlayer.clear();
			}
		}
	}

}