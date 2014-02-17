package ad 
{
	import com.greensock.plugins.VolumePlugin;
	import data.Data;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	import com.greensock.*;
    import com.greensock.easing.*;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Images extends MovieClip 
	{
		private var _loader:Loader
		private var _xmlList:XMLList;
		private var _currentLoadIndex:uint = 0;
		private var _currentShowIndex:uint=0;
		private var _currentShowImage:MovieClip;
		private var _nextShowImage:MovieClip;
		private var _allLoadFinish:Boolean = false;
		private var _imageArray:Array = [];
		private var _imageCount:uint;
		private var _missCount:uint = 0;
		private var _scaleManager:ImageScaleManager
		private var _timer:Timer;
		
		public var ready:Boolean = false;
		
		public function Images():void 
		{
			_scaleManager = new ImageScaleManager();
			
			_timer = new Timer(4000);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			initLoader();
		}
		private function initLoader():void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
		}
		private function loadComHandler(evn:Event):void
		{
			YaoTrace.add(YaoTrace.ALL, "广告图片加载完毕!");
			
			var image = evn.target.content;
			
			var mc:MovieClip = new MovieClip();
			mc.addChild(image);
			mc.imageInitWidth = image.width;
			mc.imageInitHeight = image.height;
			
			_imageArray.push(mc);
			
			ready = true;
			dispatchEvent(new Event("ready"));
			
			onLoadResult()
		}
		private function loadErrHandler(evn:Event):void
		{
			YaoTrace.add(YaoTrace.ALERT, "广告图片加载出错!");
			_missCount ++;
			onLoadResult();
		}
		private function securityErrHandler(evn:SecurityErrorEvent):void
		{
			YaoTrace.add(YaoTrace.ERROR, "广告图片文件加载出错:" + evn.text);
			_missCount ++;
			onLoadResult();
		}
		private function onLoadResult():void
		{
			if (_currentLoadIndex == _imageCount - 1)
			{
				YaoTrace.add(YaoTrace.ALL, "广告图片加载操作全部完成。这不等于全部加载成功，可能有加载失败的!");
				
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComHandler);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrHandler);
				_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrHandler);
				
				_allLoadFinish = true;
			}
			else
			{
				_currentLoadIndex++;
				YaoTrace.add(YaoTrace.ALL,"开始加载第"+String(_currentLoadIndex+1)+"个广告图片")
				_loader.load(new URLRequest(_xmlList[_currentLoadIndex].@src+"?random="+Math.random),new LoaderContext(true));
			}
		}
		private function timerHandler(evn:TimerEvent):void
		{
			_currentShowIndex++;
			showImage();
		}
		private function showImage():void
		{
			if (_allLoadFinish)
			{
				if (_currentShowIndex+1 > _imageCount - _missCount)
				{
					_currentShowIndex = 0;
				}
				/**/
				imageChange();
			}
			else
			{
				if (_imageArray[_currentShowIndex + 1])
				{
					imageChange();
				}
			}
		}
		private function imageChange():void
		{
			if (_imageArray.length == 1)
			{
				if (!_currentShowImage)
				{
					_currentShowImage = _imageArray[_currentShowIndex];
					setImage(_currentShowImage, 0, true);
					addChild(_currentShowImage);                                         
					TweenLite.to(_currentShowImage, 1.5, { x:_currentShowImage.x - 100, alpha:1, ease:Cubic.easeInOut } );
				}
			}
			else if (_imageArray.length > 1)
			{
				if (_currentShowImage)
				{
					TweenLite.to(_currentShowImage, 0.5, { x:_currentShowImage.x - 100, alpha:0, ease:Cubic.easeInOut, onComplete:moveOutHandler } );
				}
				
				_nextShowImage = _imageArray[_currentShowIndex];
				setImage(_nextShowImage, 0, true);
				addChild(_nextShowImage);                                         
				TweenLite.to(_nextShowImage, 1.5, { x:_nextShowImage.x - 100, alpha:1, ease:Cubic.easeInOut, onComplete:moveInHandler } );
			}
		}
		private function moveOutHandler():void
		{
			
		}
		private function moveInHandler():void
		{
			try
			{
				removeChild(_currentShowImage);
			}
			catch (err:Error)
			{
				
			}
			_currentShowImage = _nextShowImage;
			_nextShowImage = null;
		}
		public function init(xml:XML):void
		{
			_xmlList = xml.image;
			_imageCount = _xmlList.length();
		}
		private function setImage(target:MovieClip,alpha:Number,setToStartPosition:Boolean=true):void
		{
			if (target)
			{
				_scaleManager.scale(target, Data.isFullScreen, stage.stageWidth - 100, stage.stageHeight - 80);
				if (setToStartPosition)
				{
					target.x = (stage.stageWidth - target.width) / 2+100;
				}
				target.y = (stage.stageHeight - target.height) / 2;
				target.alpha = alpha;
			}
		}
		public function scaleAD():void
		{
			if (_currentShowImage)
			{
				setImage(_currentShowImage, _currentShowImage.alpha, false);
			}
			if (_nextShowImage)
			{
				setImage(_nextShowImage, _nextShowImage.alpha, false);
			}
		}
		public function load():void
		{
			YaoTrace.add(YaoTrace.ALL, "开始加载第" + String(_currentLoadIndex + 1) + "个广告图片");
			_loader.load(new URLRequest(_xmlList[_currentLoadIndex].@src+"?random="+Math.random),new LoaderContext(true));
		}
		public function start():void
		{
			if (!_timer.running)
			{
				showImage();
				_timer.start();
			}
		}
		public function close():void
		{
			_timer.reset();
			if (_currentShowImage)
			{
				TweenLite.killTweensOf(_currentShowImage);
				removeChild(_currentShowImage);
			}
			if (_nextShowImage)
			{
				TweenLite.killTweensOf(_nextShowImage);
				removeChild(_nextShowImage);
			}
			_currentShowImage = null;
			_nextShowImage = null;
		}
	}

}