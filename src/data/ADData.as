package data 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class ADData extends EventDispatcher 
	{
		private var _urlLoader:URLLoader;
		
		public var videoData:XML;
		public var imageData:XML;
		
		public function ADData() :void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
		}
		private function loadComHandler(evn:Event):void
		{
			_urlLoader.removeEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
			
			var data:String = String(_urlLoader.data);
			YaoTrace.add(YaoTrace.ALL, "获取广告信息完毕，结果："+data);
			if (data != "")
			{
				var xml:XML
				try
				{
					xml = XML(data);
				}
				catch (err:Error)
				{
					YaoTrace.add(YaoTrace.ALERT, "广告数据xml格式不正确");
				}
				
				if (xml)
				{
					if (xml.images.length()!=0)
					{
						if (xml.images[0].image.length() != 0)
						{
							imageData = xml.images[0];
						}
					}
					if (xml.video.length()!=0)
					{
						if (xml.video[0].@stream != "")
						{
							videoData = xml.video[0];
						}
					}
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function loadErrHandler(evn:Event):void
		{
			YaoTrace.add(YaoTrace.ALERT, "获取广告信息出错，将不会显示广告内容");
			
			_urlLoader.removeEventListener(Event.COMPLETE, loadComHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
			
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		private function securityHandler(evn:SecurityErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ALERT, "跨域，获取广告信息出错。msg:"+evn.text);
		}
		public function load():void
		{
			YaoTrace.add(YaoTrace.ALL, "开始获取广告数据，向服务器发送 flv_id="+Data.parm_flvID+" stream="+Data.parm_stream);
			
			//var parm:URLVariables = new URLVariables();
			//parm.flv_id = Data.parm_flvID;
			//parm.stream = Data.parm_stream;
			
			var urlRequest:URLRequest = new URLRequest();
			//urlRequest.data = parm;
			urlRequest.method = URLRequestMethod.GET;
			urlRequest.url = Data.GET_AD_URL+"flv_id="+Data.parm_flvID+"&stream="+Data.parm_stream+"&ranNum="+String(Math.random());
			
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.load(urlRequest);
			//trace(urlRequest.url);
		}
	}

}