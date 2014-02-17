package  
{
	import ad.AD;
	import com.greensock.motionPaths.RectanglePath2D;
	import data.Data;
	import data.DispatchEvents;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import skin.ControlBarManager;
	import skin.events.ProgressChangeEvent;
	import skin.events.VolChangeEvent;
	import video.AdvVideoPlayer;
	import skin.Skin;
	import video.events.BufferingEvent;
	import video.events.LoadingEvent;
	import video.events.NetConnectionEvent;
	import video.events.NetStreamEvent;
	import video.events.OnMetaDataEvent;
	import video.events.PlayingEvent;
	import video.events.PlayStatusEvent;
	import video.VideoPlayer;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	
	/**
	 * ...
	 * @author t
	 */
	public class ABC extends EventDispatcher 
	{
	    private var _skin:Skin;
		private var _videoPlayer:AdvVideoPlayer;
		private var _controlBarManager:ControlBarManager
		private var _stage:Stage;
		private var _ad:AD;
		private var _waitOnLive:Boolean = true;
		private var _showADTimer:Timer;
		
		public function ABC() :void
		{
			_showADTimer = new Timer(Data.SHOW_AD_AFTER_TIME);
			_showADTimer.addEventListener(TimerEvent.TIMER, showADTimerHandler);
		}
		private function showADTimerHandler(evn:TimerEvent):void
		{
			_ad.start();
			_showADTimer.reset();
		}
		private function setVideoPlayer(v:AdvVideoPlayer):void
		{
			_videoPlayer = v;
			_videoPlayer.addEventListener(PlayStatusEvent.CHANGE, playStatusChangeHandler);
			_videoPlayer.addEventListener(PlayingEvent.PLAYING, playingHandler);
			_videoPlayer.addEventListener(BufferingEvent.BUFFERING, bufferingHandler);
			_videoPlayer.addEventListener(NetStreamEvent.CHANGE, netStreamChangeHandler);
			_videoPlayer.addEventListener(NetConnectionEvent.CHANGE, netConnectionChangeHandler);
			_videoPlayer.addEventListener(LoadingEvent.LOADING, loadingHandler);
			_videoPlayer.addEventListener(OnMetaDataEvent.ON_METADATA, onMetaDataHandler);
			_videoPlayer.addEventListener("streamNotFound", streamNotFoundHandler);
		}
		private function setSkin(s:Skin):void
		{
			_skin = s;
			
			_controlBarManager = new ControlBarManager();
			_controlBarManager.addEventListener("fullscreenBtnClick", fullscreenBtnClickHandler);
		    _controlBarManager.addEventListener("playBtnClick", playBtnClickHandler);
			_controlBarManager.addEventListener("pauseBtnClick", pauseBtnClickHandler);
			_controlBarManager.addEventListener("screenClickHotClick", screenClickHotClickHandler);
			_controlBarManager.addEventListener("bigPlayBtnClick", bigPlayBtnClickHandler);
			_controlBarManager.addEventListener(VolChangeEvent.CHANGE, volChangeHandler);
			_controlBarManager.addEventListener(ProgressChangeEvent.CHANGE, progressChangeHandler);
			_controlBarManager.add(_skin,Data.live);
		}
		private function playStatusChangeHandler(evn:PlayStatusEvent):void
		{
			if (evn.status == Data.PLAY)
			{
				if (_videoPlayer.bufferFullCount > 0)
				{
					if (_videoPlayer.status == Data.PLAY)
					{
						_controlBarManager.setVideoStatus = evn.status;
					}
				}
			}
			else
			{
				_controlBarManager.setVideoStatus = evn.status;
			}
			
			switch(evn.status)
			{
				case Data.PLAY:
					break;
				case Data.COMPLETE:
					onPlayComplete();
					break;
				case Data.UN_PUBLISH:
					onUnPublish();
					break;
			}
		}
		private function onPlayComplete():void
		{
			_videoPlayer.visible = false;
			_controlBarManager.progressBarEnabled = false;
			_controlBarManager.playBtnEnabled = false;
			_controlBarManager.setBuffering(false);
			DispatchEvents.STREAM_PLAY_COMPLETE();
		}
		private function onUnPublish():void
		{
			_videoPlayer.visible = false;
			_controlBarManager.progressBarEnabled = false;
			_controlBarManager.playBtnEnabled = false;
			_waitOnLive = true;
		    _ad.start()
			_controlBarManager.setBuffering(false);
			DispatchEvents.STREAM_PLAY_COMPLETE();
		}
		private function onNetConnectionClose():void
		{
			if (Data.live)
			{
				_waitOnLive = true;
			}
			_videoPlayer.visible = false;
			_controlBarManager.progressBarEnabled = false;
			//_controlBarManager.playBtnEnabled = false;
			_controlBarManager.setBuffering(false);
			_controlBarManager.setVideoStatus = Data.COMPLETE;
			_controlBarManager.bigPlayBtnType = "connect";
			_controlBarManager.adMsg = "";
			if (Data.live)
			{
				_controlBarManager.alertMsg = "";
			}
			else
			{
				_controlBarManager.alertMsg = "和服务器断开";
			}
			_ad.close();
			
		}
		private function playingHandler(evn:PlayingEvent):void
		{
			_controlBarManager.setTime(evn.currentTime, _videoPlayer.totalTime);
			_controlBarManager.setDownLoadSpeed(evn.currentDownLoadSpeed,evn.currentRate);
		}
		private function bufferingHandler(evn:BufferingEvent):void
		{
			if (Data.live)
			{
				if (evn.percent == 0)
				{
					if (_waitOnLive)
					{
						alertMsg1 = "当前没有直播";
					}
					else
					{
						setBuffering(String(int(evn.percent * 100)));
					}
				}
				else
				{
					_waitOnLive = false;
					setBuffering(String(int(evn.percent * 100)));
				}
				
			}
			else
			{
				setBuffering(String(int(evn.percent * 100)));
			}
		}
		private function setBuffering(str:String):void
		{
			alertMsg1 = "";
			if (_videoPlayer.status != Data.PAUSE)
			{
				_controlBarManager.setBuffering(true, "已缓冲 " + str + "%");
			}
			else
			{
				_controlBarManager.setBuffering(false, "已缓冲 " + str + "%");
			}
		}
		private function loadingHandler(evn:LoadingEvent):void
		{
			_controlBarManager.loadPer = evn.percent;
		}
		private function onMetaDataHandler(evn:OnMetaDataEvent):void
		{
			if (Data.videoRatio == 0)
			{
				Data.videoRatio = evn.videoWidth / evn.videoHeight;
			}
			scale(Data.isFullScreen,Data.videoRatio);
		}
		private function streamNotFoundHandler(evn:Event):void
		{
			alertMsg1 = "视频加载失败";
			DispatchEvents.STREAM_NOT_FOUND();
		}
		private function netStreamChangeHandler(evn:NetStreamEvent)
		{
			YaoTrace.add(YaoTrace.ALERT, "流状态："+evn.status);
			switch(evn.status)
			{
				case "NetStream.Buffer.Full":
					_videoPlayer.visible = true;
					_controlBarManager.progressBarEnabled = true;
					_controlBarManager.playBtnEnabled = true;
					alertMsg1 = "";
					_controlBarManager.setBuffering(false);
					if (_videoPlayer.bufferFullCount == 1)
					{
						_controlBarManager.setVideoStatus = Data.PLAY;
					}
					if (Data.live)
					{
						_ad.close();
						_controlBarManager.adMsg = "";
						_showADTimer.reset();
					}
					break;
				case "NetStream.Buffer.Empty":
					if (Data.live)
					{
						trace("广告开始计时")
						_showADTimer.reset();
						_showADTimer.start();
					}
					break;
				case "NetStream.Play.UnpublishNotify":
					//onUnPublish()
					break;
				case "NetStream.Play.PublishNotify":
					_ad.close();
					_controlBarManager.adMsg = "";
				    _videoPlayer.visible = true;
					_controlBarManager.progressBarEnabled = true;
					_controlBarManager.playBtnEnabled = true;
					break;
			}
		}
		private function netConnectionChangeHandler(evn:NetConnectionEvent)
		{
			YaoTrace.add(YaoTrace.ALERT, "连接状态：" + evn.status);
			switch(evn.status)
			{
				case "NetConnection.ReConnect.Failed":
					alertMsg1 = "服务器连接失败"
					DispatchEvents.CONNECT_FAILED();
					break;
				case "NetConnection.Connect.Success":
					/*if (Data.live)
					{
						this.alertMsg1 = "当前没有直播"
					}*/
					break;
				case "NetConnection.Connect.Closed":
					//alertMsg1 = "服务器连接已断开"
					onNetConnectionClose();
					break;
			}
		}
		
		private function fullscreenBtnClickHandler(evn:Event):void
		{
			switch(_stage.displayState) 
			{
				case "normal":
					_stage.displayState = "fullScreen";  					
					scale(true,Data.videoRatio);
					break;
				case "fullScreen":
					default:
					_stage.displayState = "normal";  
					scale(false,Data.videoRatio);
					break;
			}
			if (Data.adShow)
			{
				_ad.close();
				_ad.start()
			}
		}
		private function playBtnClickHandler(evn:Event):void
		{
			_videoPlayer.resume();
		}
		private function pauseBtnClickHandler(evn:Event):void
		{
			_videoPlayer.pause();
		}
		private function volChangeHandler(evn:VolChangeEvent):void
		{
			_videoPlayer.setVol(evn.vol);
		}
		private function progressChangeHandler(evn:ProgressChangeEvent):void
		{
			_videoPlayer.seek(evn.per*_videoPlayer.totalTime/1000);
		}
		private function screenClickHotClickHandler(evn:Event):void
		{
			if (_videoPlayer.bufferFullCount > 0)
			{
				switch(_videoPlayer.status)
				{
					case Data.PLAY:
						pause();
						break;
					case Data.PAUSE:
						resume();
						break;
				}
			}
		}
		private function bigPlayBtnClickHandler(evn:Event):void
		{
				if (_controlBarManager.bigPlayBtnType=="resume")
				{
					resume();
				}
				else if (_controlBarManager.bigPlayBtnType=="connect")
				{
					_controlBarManager.bigPlayBtnType = "resume";
					play(Data.stream, Data.fms, Data.bufferTime);
				}
		}
		private function readyHandler(evn:Event):void
		{
			_videoPlayer.visible = false;
		}
		private function fullScreenHandler(evn:FullScreenEvent):void
		{
			if (!evn.fullScreen)
			{
				_controlBarManager.isFullScreen = false;
			}
		}
		
		public function addObject(v:AdvVideoPlayer,s:Skin,ad:AD,sta:Stage):void
		{
			_stage = sta;
			_stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
			
			//模拟断网
			/*_stage.addEventListener(KeyboardEvent.KEY_DOWN,deyhdfdf)
			function deyhdfdf(e)
			{
				_videoPlayer.closeNetconnection();
			}*/
			
			_ad = ad;
			_ad.addEventListener("ready", readyHandler);
			
			setSkin(s);
			setVideoPlayer(v);
		}
		public function scale(isFullScreen:Boolean,xx):void
		{
			Data.isFullScreen = isFullScreen;
			if (isFullScreen)
			{
				_videoPlayer.scale(new Rectangle(0,0,_stage.stageWidth,_stage.stageHeight),xx);
			}
			else
			{
				_videoPlayer.scale(new Rectangle(0,0,_stage.stageWidth,_stage.stageHeight-_skin.controlBar.height),xx);
			}
			_controlBarManager.scale();
			trace("全屏状态："+isFullScreen)
			_controlBarManager.isFullScreen = isFullScreen;
			if (Data.live)
			{
				if (Data.adShow)
				{
					_ad.close();
					_ad.start();
				}
				//_ad.scaleAD();
			}
		}
		public function pause():void
		{
			_videoPlayer.pause();
		}
		public function resume():void
		{
			_videoPlayer.resume();
		}
		public function play(stream:String,fms:String,bufferTime:Number=3000):void
		{
			YaoTrace.add(YaoTrace.ALL, "准备播放视频 fms:" + fms + " stream:" + stream);
			alertMsg1 = "正在连接服务器......";
			_videoPlayer.play(stream,fms,bufferTime,Data.live);
		}
		public function set alertMsg1(msg:String):void
		{
			_controlBarManager.alertMsg = msg;
		}
	}

}