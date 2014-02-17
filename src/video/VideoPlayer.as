package video
{
	import data.Data;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.Timer;
	import video.events.BufferingEvent;
	import video.events.LoadingEvent;
	import video.events.NetConnectionEvent;
	import video.events.NetStreamEvent;
	import video.events.OnMetaDataEvent;
	import video.events.PlayingEvent;
	import video.events.PlayStatusEvent;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class VideoPlayer extends Sprite  
	{
		public static const RE_CONNECT_COUNT:uint = 3;
		
		private var _video:Video;
		
		private var _netStream:NetStream;
		private var _netConnetction:NetConnection;
		
		private var _totalTime:Number = 0;//视频总时间
		
		private var _connectSuccess:Boolean = false;//连接是否成功了
		
		private var _playStatus:String = "";
		private var _useFms:Boolean = false;//是否使用fms
		
		private var _playingTimer:Timer;
		private var _loadingTimer:Timer;
		private var _bufferingTimer:Timer;
		private var _reConnectTimer:Timer;
		private var _checkBufferLengthTimer:Timer;
		
		private var _fms:String;
		private var _stream:String;
		private var _bufferTime:Number;
		
		private var _stop:Boolean = false;
		private var _flush:Boolean = false;
		private var _firstOnStart:Boolean = true;
		private var _live:Boolean = false;
		private var _currentReconnectCount:uint = 0;
		
		public var bufferFullCount:uint = 0;//缓冲区满的次数
		
		
		public function VideoPlayer():void
		{
			initVideo(400, 300);
			
			_reConnectTimer = new Timer(100,1);
			_reConnectTimer.addEventListener(TimerEvent.TIMER, reConnectTimerHandler);
		}
		//初始化视频元件
		private function initVideo(videoWidth:Number,videoHeight:Number):void
		{
			_video = new Video();
			_video.width = videoWidth;
			_video.height = videoHeight;
			_video.smoothing = true;
			addChild(_video);
		}
		//初始化连接
		private function initNetConnecttion():void
		{
			 _netConnetction = new NetConnection();
			 _netConnetction.addEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
			 _netConnetction.client = this;
		}
        //初始化流
		private function initStream(nc:NetConnection,videoComonent:Video,bufferTime:Number):void
		{
			_netStream = new NetStream(nc);
			_netStream.client = this;
			_netStream.bufferTime = bufferTime / 1000;
			videoComonent.attachNetStream(_netStream);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, nsStatusHandler);
		}
		private function onConnectSuccess():void
		{
			_connectSuccess = true;
			initTimer();
			initStream(_netConnetction, _video, _bufferTime);
			if (_live)
			{
				_netStream.play(_stream,-1);
			}
			else
			{
				_netStream.play(_stream,0);
			}	
		}
		private function ncStatusHandler(evn:NetStatusEvent):void
		{
			var msg:String = evn.info.code;
			trace(msg)
			switch (msg) 
			{ 
				case "NetConnection.Connect.Success":
					onConnectSuccess();
					break;
				case "NetConnection.Connect.Failed":
					_reConnectTimer.start();
					break
				case "NetConnection.Connect.Rejected":
				    break;
				case "NetConnection.Connect.Closed":
					clear()
					break;
			}
			var event:NetConnectionEvent = new NetConnectionEvent(NetConnectionEvent.CHANGE);
			event.status = msg;
			dispatchEvent(event);
		}
		private function reConnectTimerHandler(evn:TimerEvent):void
		{
			reConnect();
		}
		private function reConnect():void
		{
			if (_currentReconnectCount < RE_CONNECT_COUNT)
			{
				_currentReconnectCount++;
				trace("再次尝试连接服务器")
				if (_fms == "")
				{
					_netConnetction.connect(null);
				}
				else
				{
					_netConnetction.connect(_fms);
				}
			}
			else
			{
				_connectSuccess = false;
				
				var event:NetConnectionEvent = new NetConnectionEvent(NetConnectionEvent.CHANGE);
				event.status = "NetConnection.ReConnect.Failed";
				dispatchEvent(event);
			}
		}
		private function onStreamNotFound():void
		{
			if (_loadingTimer)
			{
				_loadingTimer.stop();
			}
			_playingTimer.stop();
			dispatchEvent(new Event("streamNotFound"));
		}
		private function nsStatusHandler(evn:NetStatusEvent):void
		{
			var msg:String = evn.info.code;
			trace(msg)
			switch (msg) 
			{ 
				case "NetStream.Play.Start":
					onPlayStart();
					break;
				case "NetStream.Buffer.Full":
					bufferFullCount++;
				    _flush = false;
					_bufferingTimer.reset();
					
				    break;
				case "NetStream.Buffer.Empty":
					onBufferEmpty();
				    break;
				case "NetStream.Seek.Notify":
					_flush = false;
					_playingTimer.start();
				    break;
				case "NetStream.Seek.InvalidTime":	
					_netStream.seek(evn.info.details);
				    break;
				case "NetStream.Buffer.Flush":
				    _flush = true;
				    break;	
				case "NetStream.Unpause.Notify":
				    break;	
				case "NetStream.Play.Stop":
				    _stop = true;
				    break;	
				case "NetStream.Play.StreamNotFound":
					onStreamNotFound();
					break;
				case "NetStream.Play.UnpublishNotify":
					_checkBufferLengthTimer.start();
					break;
				case "NetStream.Play.PublishNotify":
					if (_playStatus == "" || _playStatus == Data.UN_PUBLISH)
					{
						_bufferingTimer.reset();
						_bufferingTimer.start();
					}
					_checkBufferLengthTimer.reset();
					break;
			}
			var event:NetStreamEvent = new NetStreamEvent(NetStreamEvent.CHANGE);
			event.status = msg;
			dispatchEvent(event);
		}
        private function onPlayStart():void
		{
			if (!_useFms)
			{
				_loadingTimer.reset()
				_loadingTimer.start();
			}
			_playingTimer.reset();
			_playingTimer.start();
			
			_bufferingTimer.reset();
			_bufferingTimer.start();
			
			if (_firstOnStart)
			{	
				_firstOnStart = false;
				
				_playStatus = Data.PLAY;	
				
				var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
				event.status = Data.PLAY;
				dispatchEvent(event);
			}
		}
		private function playComplete():void
		{
			_firstOnStart = true;
			_playStatus = Data.COMPLETE;
			
			_bufferingTimer.stop();
			_playingTimer.stop();
			//_netStream.seek(0);
			//_netStream.pause();
					
			bufferFullCount = 0;
			
			
			var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
			if (_live)
			{
				event.status = Data.UN_PUBLISH;
			}
			else
			{
				event.status = Data.COMPLETE;
			}
			dispatchEvent(event);
		}
		private function onBufferEmpty():void
		{			
			if (!_useFms)
			{
				if (_flush && _stop)
				{
					playComplete();
				}
			}
			
			if (_playStatus != Data.COMPLETE)
			{
				trace("缓冲缓冲")
				_bufferingTimer.start();
			}
		}
		private function initTimer():void
		{
			_playingTimer = new Timer(200);
			_checkBufferLengthTimer = new Timer(200);
			
			if (_live)
			{
				_checkBufferLengthTimer.addEventListener(TimerEvent.TIMER, checkBufferLengthTimerHandler);
			}
			else
			{
	
			}
			_playingTimer.addEventListener(TimerEvent.TIMER, playingTimerHandler);	
			if (!_useFms)
			{
				_loadingTimer = new Timer(100);
				_loadingTimer.addEventListener(TimerEvent.TIMER, loadingHandler);
			}

			_bufferingTimer = new Timer(200);
			_bufferingTimer.addEventListener(TimerEvent.TIMER, bufferingTimerHandler);
		}
		 //加载中
		private function loadingHandler(evn:Event):void
		{
			var per:Number = _netStream.bytesLoaded / _netStream.bytesTotal;
			
			var event:LoadingEvent = new LoadingEvent(LoadingEvent.LOADING);
			event.percent = per;
			dispatchEvent(event);
		}
		private function playingTimerHandler(evn:TimerEvent):void
		{
			//trace(int(_netStream.info.currentBytesPerSecond/1024),int(_netStream.info.playbackBytesPerSecond*8/1024))
			
			var event:PlayingEvent = new PlayingEvent(PlayingEvent.PLAYING);
			event.currentTime = _netStream.time * 1000;
			event.currentDownLoadSpeed = int(_netStream.info.currentBytesPerSecond / 1024);
			event.currentRate = int(_netStream.info.playbackBytesPerSecond * 8 / 1024);
			dispatchEvent(event);
		}
		private function bufferingTimerHandler(evn:TimerEvent):void
		{
			var event:BufferingEvent = new BufferingEvent(BufferingEvent.BUFFERING);
			event.percent = _netStream.bufferLength/_netStream.bufferTime;
			dispatchEvent(event);
		}
		private function checkBufferLengthTimerHandler(evn:TimerEvent):void
		{
			if (_netStream.bufferLength == 0)
			{
				playComplete();
				_netStream.close();
				_netStream.play(_stream, -1);
				
				_checkBufferLengthTimer.reset();
			}
		}
		private function _pause():void
		{
			if (_connectSuccess)
			{
				if (_playStatus == Data.PLAY)
				{
					_netStream.pause();
					_playStatus = Data.PAUSE;
					//_playingTimer.stop();
					trace("暂停")
					var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
					event.status = Data.PAUSE;
					dispatchEvent(event);
				}
			}
		}
		private function _seek(time:Number):void
		{
			if (_connectSuccess)
			{
				_playingTimer.stop();
				_netStream.seek(time);
			}
		}
		private function _resume():void
		{
			if (_connectSuccess)
			{
				switch(_playStatus)
				{
					case Data.PAUSE:
						_netStream.resume();
						_playStatus = Data.PLAY;
						//_playingTimer.start();
						break;
					case Data.COMPLETE:
						_netStream.play(_stream,0);
						_playStatus = Data.PLAY;
						_playingTimer.start();
						break;
				}
				var event:PlayStatusEvent = new PlayStatusEvent(PlayStatusEvent.CHANGE);
				event.status = Data.PLAY;
				dispatchEvent(event);
			}
		}
		public function clear():void
		{			
			if (_netConnetction)
			{
				_netConnetction.removeEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
				_netConnetction.close();
				_netConnetction = null;
			}

			if (_netStream)
			{
				_netStream.close();
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, nsStatusHandler);
				_netStream = null;
			}
			
			_totalTime = 0;
			bufferFullCount = 0;
			_firstOnStart = true;
			_connectSuccess = false;
			_playStatus= "";
		    _useFms = false;
			_stop = false;
			_flush = false;
			
			_video.smoothing = false;
			_video.clear();
			
			if (_playingTimer)
			{
				_playingTimer.stop();
				_playingTimer.removeEventListener(TimerEvent.TIMER, playingTimerHandler);
				_playingTimer = null;
			}
			
			if (!_useFms)
			{
				if (_loadingTimer != null)
				{
					_loadingTimer.stop();
					_loadingTimer.removeEventListener(TimerEvent.TIMER, loadingHandler);
					_loadingTimer = null;
				}
			}
			if (_bufferingTimer)
			{
				_bufferingTimer.stop();
				_bufferingTimer.removeEventListener(TimerEvent.TIMER, bufferingTimerHandler);
				_bufferingTimer = null;
			}
			if (_checkBufferLengthTimer)
			{
				_checkBufferLengthTimer.reset();
				_checkBufferLengthTimer.removeEventListener(TimerEvent.TIMER, checkBufferLengthTimerHandler);
				_checkBufferLengthTimer = null;
			}
		}
		
		private function _play(stream:String,fms:String,bufferTime:Number,live:Boolean):void
		{
			_video.smoothing = true;
			
			if (_netConnetction != null)
			{
				clear();
			}
			_bufferTime = bufferTime;
			_stream = stream;
			_live = live;
			_fms = fms;
			//removeChild(_video);
			//initVideo(400,300);
			
			initNetConnecttion();
			//trace(fms)
			if (fms == "")
			{
				_useFms = false;
				_netConnetction.connect(null);
			}
			else
			{
				_useFms = true;
				_netConnetction.connect(fms);
			}
		}
		///////////////////////////////////////////////////////////////////////////////////////////////
		public function onMetaData(obj:Object):void
		{
			_totalTime = obj.duration*1000;
			trace("onme:",obj.width,obj.height)
			var event:OnMetaDataEvent = new OnMetaDataEvent(OnMetaDataEvent.ON_METADATA);
			event.videoWidth = obj.width;
			event.videoHeight = obj.height;
			dispatchEvent(event);
		}
		public function onPlayStatus(obj:Object):void
		{
			switch (obj.code)
			{
				case "NetStream.Play.Complete":
					if (_useFms)
					{
						playComplete();
					}
				    break;
				case "NetStream.Play.TransitionComplete":
				    trace("流切换成功")
					break;
			}
		}
		public function onBWDone(e=null):void
		{
			
		}
		public function onXMPData(obj:Object):void
		{
			
		}
		public function onFI(obj:Object):void
		{
			
		}
		public function get close()
		{
			
		}
		public function get onTimeCoordInfo()
		{
			
		}
		/****************************************************************************** 方法 **********************/
		public function play(stream:String,fms:String="",bufferTime:Number=5000,live:Boolean=false):void
		{
			_play(stream,fms,bufferTime,live);
		}
		public function play2():void
		{
			if (_live)
			{
				_netStream.play(_stream,-1);
			}
			else
			{
				_netStream.play(_stream,0);
			}
		}
		public function pause():void
		{
			_pause();
			//_netConnetction.close();
		}
		public function resume():void
		{
			_resume();
		}
		public function seek(time:Number):void
		{
			_seek(time);
		}
		//设置音量
		public function setVol(n:Number):void
		{
			SoundMixer.soundTransform = new SoundTransform( n );
		}
		public function stop():void
		{
			//_netStream.close();
		}
		public function closeNetconnection():void
		{
			if (_netConnetction)
			{
				_netConnetction.close();
			}
		}
		/****************************************************************************** 属性 ********************/
		//连接是否成功
		public function get connectSuccess():Boolean
		{
			return _connectSuccess;
		}
		//视频持续时间
		public function get totalTime():Number
		{
			if (_connectSuccess)
			{
				return _totalTime;
			}
			return 0;
		}
		public function get status():String
		{
			return _playStatus;
		}
	}
	
}