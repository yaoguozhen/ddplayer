package 
{
	import ad.AD;
	import data.ADData;
	import data.DispatchEvents;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetFilterEvent;
	import flash.external.ExternalInterface;
	import skin.Skin;
	import video.AdvVideoPlayer;
	import data.Data
	import zhen.guo.yao.components.yaotrace.YaoTrace;

	/**
	 * ...
	 * @author yaoguozhen
	 */
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="30")] 
	public class Main extends Sprite 
	{
		private var _skin:Skin;
		private var _videoPlayer:AdvVideoPlayer;
		private var _abc:ABC;
		private var _ad:AD;
		private var _adData:ADData;
		
		public function Main():void 
		{
			try
			{
				//ExternalInterface.addCallback("v_start", v_start);
				//ExternalInterface.addCallback("v_pause", v_pause);
				//ExternalInterface.addCallback("v_resume", v_resume);
			}
			catch (err:Error)
			{
				
			}
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			YaoTrace.init(stage, "xxx.123.qaz");
			YaoTrace.add(YaoTrace.ALL, "030830更新信息：可动态设置缓冲时间；修改了播放中广告依旧出现的bug");
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
            
			stage.scaleMode=StageScaleMode.NO_SCALE  
			stage.align = StageAlign.TOP_LEFT
			stage.addEventListener(Event.RESIZE, resizeHandler);
			
			DispatchEvents.init(this);
			
			_videoPlayer = new AdvVideoPlayer();
			_ad = new AD();
			
			Data.getData(stage);
			
			var checkRezult:String = CheckData.check();
			if (checkRezult == "")
			{
				v_start(Data.skin, Data.stream, Data.fms, Data.videoRatio, Data.bufferTime);
				
				if (Data.live)
				{
					if (Data.parm_flvID != "" && Data.parm_stream != "")
					{
						_adData = new ADData();
						_adData.addEventListener(Event.COMPLETE, adDataLoadComHandler);
						_adData.addEventListener(IOErrorEvent.IO_ERROR, adDataLoadErrHandler);
						_adData.load();
					}
					else
					{
						YaoTrace.add(YaoTrace.ALERT, "没有广告相关设置，不加载广告数据");
					}
				}
				else
				{
					YaoTrace.add(YaoTrace.ALERT, "当前为点播，不加载广告数据");
				}
			}
			else
			{
				YaoTrace.add(YaoTrace.ERROR, checkRezult);
			}
		}
		private function adDataLoadComHandler(evn:Event):void
		{
			if (_adData.imageData)
			{
				_ad.setData(AD.IMAGE, _adData.imageData);
				_ad.load();
				_ad.start();
			}
			else if (_adData.videoData)
			{
				_ad.setData(AD.VIDEO, _adData.videoData);
				_ad.start();
			}
			else
			{
				YaoTrace.add(YaoTrace.ALERT, "广告数据获取完毕，但是解析时出现问题");
			}
		}
		private function adDataLoadErrHandler(evn:IOErrorEvent):void
		{
			//_ad.setData(AD.VIDEO, _adData.videoData);
			//_ad.load();
		}
		private function initSkinLoader():void
		{
			_skin = new Skin();
			_skin.addEventListener(Event.COMPLETE, skinLoadComHandler);
			_skin.addEventListener(IOErrorEvent.IO_ERROR, skinLoadErrHandler);
		}
		private function skinLoadComHandler(evn:Event):void
		{
			if (_skin.missComponent=="")
			{
				addChild(_skin.bg);
				addChild(_videoPlayer);
				addChild(_skin.alertMsg);
				addChild(_skin.controlBar);
				addChild(_skin.buffering);
				addChild(_skin.logo);
				addChild(_skin.screenClickHot);
				addChild(_ad);
				addChild(_skin.bigPlayBtn);
				addChild(_skin.adMsg);
				
				
				_abc = new ABC();
				_abc.addObject(_videoPlayer, _skin,_ad, stage);
				
				if (Data.live)
				{
					_abc.play(Data.stream,Data.fms, Data.bufferTime);
				}
				else
				{
					if (Data.autoPlay)
					{
						_abc.play(Data.stream,Data.fms, Data.bufferTime);
					}
				}
				
				_abc.scale(false, Data.videoRatio);
			}
			else
			{
				YaoTrace.add(YaoTrace.ERROR, "皮肤文件中缺少原件:"+_skin.missComponent);
				trace(_skin.missComponent)
			}
		}
		private function skinLoadErrHandler(evn:Event):void
		{
			_abc.alertMsg1 = "皮肤加载失败";
		}
		
		private function resizeHandler(evn:Event):void
		{
			_abc.scale(false,Data.videoRatio);
		}
		private function getVideoRatio(videoRatio:String):Number
		{
			if (videoRatio != "")
			{
				var array:Array = videoRatio.split(":");
				if (array.length == 2)
				{
					return Number(array[0]) / Number(array[1]);
				}
				else
				{
					YaoTrace.add(YaoTrace.ALERT, "设置视频比例数据格式不正确");
				}
			}
			return 0;
		}
		
		/*******************************************************************************************/
		
		public function v_start(skinSrc:String,stream:String,fms:String="",videoRatio="",bufferTime:Number=3000):void
		{
			if (stage!=null)
			{			
				Data.videoRatio=getVideoRatio(videoRatio);

				if (_skin == null)
				{
					initSkinLoader();
					_skin.load(skinSrc+"?random="+Math.random());
				}
				else
				{
					_abc.play(stream,fms, bufferTime);
					_abc.scale(false,Data.videoRatio);
				}
			}
		}
		public function v_pause():void
		{
			_abc.pause();
		}
		public function v_resume():void
		{
			_abc.resume();
		}
	}
}