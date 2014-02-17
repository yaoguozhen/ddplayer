package skin 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Skin extends EventDispatcher
	{
		private var _loader:Loader;
		private var _missComponent:String = "";
		private var _content:MovieClip;
		private var _controlBar:MovieClip;
		private var _screenClickHot:Sprite;
		private var _bigPlayBtn:MovieClip;
		private var _buffering:MovieClip;
		private var _alertMsg:MovieClip;
		private var _bg:MovieClip;
		private var _adMsg:MovieClip;
		private var _logo:MovieClip;
		
		public function Skin() :void
		{			
			initLoader();
			creatScreenClickHot();
		}
		private function initLoader():void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
		}
		/**
		 * 加载完毕
		 * @param	evn
		 */
		private function loadComHandler(evn:Event):void
		{
			YaoTrace.add(YaoTrace.ALL, "皮肤文件加载完毕");
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
			
			_content = MovieClip(_loader.content);
			_controlBar = _content.controlBar;
			_bigPlayBtn = _content.bigPlayBtn;
			_buffering = _content.buffering;
			_alertMsg = _content.alertMsg;
			_adMsg = _content.adMsg;
			_bg = _content.bg;
			_logo = _content.logo;
			
			_missComponent = SkinChecker.check(_content);

			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function securityErrHandler(evn:SecurityErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "皮肤文件加载出错:"+evn.text);
		}
		/**
		 * 加载失败
		 * @param	evn
		 */
		private function loadErrorHandler(evn:IOErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "皮肤文件加载出错");
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
			
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		private function creatScreenClickHot():void
		{
			_screenClickHot = new Sprite();
			_screenClickHot.graphics.beginFill(0x0000ff, 0);
			_screenClickHot.graphics.drawRect(0, 0, 100, 100);
			_screenClickHot.doubleClickEnabled = true;
		}
		//记载皮肤
		public function load(skinURL:String):void
		{
			YaoTrace.add(YaoTrace.ALL, "开始加载皮肤文件:" + skinURL);
			_loader.load(new URLRequest(skinURL),new LoaderContext(true));
		}
		public function get missComponent():String
		{
			return _missComponent;
		}
		public function get controlBar():MovieClip
		{
			return _controlBar;
		}
		public function get screenClickHot():Sprite
		{
			return _screenClickHot;
		}
		public function get bigPlayBtn():MovieClip
		{
			return _bigPlayBtn;
		}
		public function get alertMsg():MovieClip
		{
			return _alertMsg;
		}
		public function get adMsg():MovieClip
		{
			return _adMsg;
		}
		public function get buffering():MovieClip
		{
			return _buffering;
		}
		public function get bg():MovieClip
		{
			return _bg;
		}
		public function get logo():MovieClip
		{
			return _logo;
		}
	}

}