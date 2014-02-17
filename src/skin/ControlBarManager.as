package skin 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.system.Capabilities;
	import com.greensock.*;
	import com.greensock.easing.*;
	import data.Data;
	import skin.events.ProgressChangeEvent;
	import skin.events.VolChangeEvent;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class ControlBarManager extends EventDispatcher 
	{
		private var _controlBar:MovieClip;
		private var _progressBar:YaoSlider;
		private var _volBar:YaoSlider;
		private var _hideControlBarTime:Timer;
		
		private var _isShow:Boolean = true;
		private var _stage:Stage;
		private var _screenClickHot:Sprite;
		private var _bigPlayBtn:MovieClip;
		private var _buffering:MovieClip;
		private var _alertMsg:MovieClip;
		private var _adMsg:MovieClip;
		private var _bg:MovieClip;
		private var _logo:MovieClip;
		
		private var _nnnn:uint = 0;
		
		private var _live:Boolean = false;
		
		private var _isFullScreen:Boolean = false;
		public var bigPlayBtnType:String=""//resume 被当做恢复播放按钮。connect被当做开始连接按钮
		
		public function ControlBarManager() :void
		{
				
		}
		private function initTimer():void
		{
			_hideControlBarTime = new Timer(3000, 1);
			_hideControlBarTime.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		private function timerHandler(evn:TimerEvent):void
		{
			if (_isShow)
			{
				hide();
			}
		}
		private function init(s:Skin):void
		{
			_screenClickHot = s.screenClickHot;
			_bigPlayBtn = s.bigPlayBtn;
			_buffering = s.buffering;
			_bg = s.bg;
			_logo = s.logo;
			_alertMsg = s.alertMsg;
			_adMsg = s.adMsg;
			_controlBar = s.controlBar;
			_stage = _controlBar.stage;
			
			_adMsg.txt.autoSize = "left";
			
			_controlBar.playBtn.visible = true;
			_controlBar.playBtn.buttonMode = true;
			_controlBar.pauseBtn.visible = false;
			_controlBar.pauseBtn.buttonMode = true;
			_controlBar.stopBtn.visible = false;
			_controlBar.stopBtn.buttonMode = true;
			_controlBar.fullscreenBtn.buttonMode = true;
			_bg.visible=false
			
			_controlBar.progressBar.followBar.width = 0;
			_controlBar.progressBar.loadingBar.width = 0;
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler123);
			
			_volBar = new YaoSlider();
			_volBar.init(_controlBar.volBar, 0, 1, true, true);
			_volBar.currentPercent = 1;
			_volBar.addEventListener(YaoSlider.CHANGE, volBarChangeHandler);
			
			_controlBar.fullscreenBtn.addEventListener(MouseEvent.CLICK, fullscreenBtnClickHandler);
			_controlBar.playBtn.addEventListener(MouseEvent.CLICK, playBtnClickHandler);
			_controlBar.pauseBtn.addEventListener(MouseEvent.CLICK, pauseBtnClickHandler);
			
			
			_controlBar.progressBar.loadingBar.width = 0;
			_controlBar.progressBar.followBar.width = 0;
			
			_progressBar = new YaoSlider();
			_progressBar.init(_controlBar.progressBar, 0, 1, false, true);
			_progressBar.active = false;
			_progressBar.currentPercent = 0;
			
			_progressBar.addEventListener(YaoSlider.CHANGE, progressBarChangeHandler);
			_progressBar.addEventListener(YaoSlider.BLOCK_PRESSED, progressBarPressedHandler);
			_progressBar.addEventListener(YaoSlider.BLOCK_RELEASED, progressBarReleasedHandler);
			//_progressBar.addEventListener(YaoSlider.PASS_CLICKED, passClickedHandler);
			
			_screenClickHot.addEventListener(MouseEvent.CLICK, screenClickHotClickHandler);
			_screenClickHot.addEventListener(MouseEvent.DOUBLE_CLICK, screenClickHotDoubleClickHandler);
			
			if (Data.live)
			{
				_bigPlayBtn.visible = false;
				bigPlayBtnType = "resume";
			}
			else
			{
				if (Data.autoPlay)
				{
					_bigPlayBtn.visible = false;
					bigPlayBtnType = "resume";
				}
				else
				{
					bigPlayBtnType = "connect";
				}
			}
			_bigPlayBtn.buttonMode = true;
			_bigPlayBtn.addEventListener(MouseEvent.CLICK, bigPlayBtnClickHandler);
			
			_buffering.visible = false;
			_logo.visible = Data.showLogo;
			if (_live)
			{
				_controlBar.progressBar.visible = false;
				_controlBar.time.visible = false;
				_controlBar.downLoadSpeed.visible = true;
			}
			else
			{
				_controlBar.downLoadSpeed.visible = false;
			}
			
			
			
			recordInitNumber();
		}
		private function recordInitNumber():void
		{
			record(_controlBar.controlBarBg);
			record(_controlBar.playBtn);
			record(_controlBar.pauseBtn);
			record(_controlBar.fullscreenBtn);
			record(_controlBar.volBtn);
			record(_controlBar.volBar);
			record(_controlBar.downLoadSpeed);
			record(_controlBar.time);
			record(_controlBar.progressBar);
		}
		private function record(mc:MovieClip):void
		{
			mc.initX = mc.x;
			mc.initY = mc.y;
			mc.disRight = _controlBar.width - mc.x;
		}
		private function stageMouseMoveHandler123(evn:MouseEvent):void
		{
			if (_isFullScreen)
			{
				_hideControlBarTime.reset();
				_hideControlBarTime.start();
				if (!_isShow)
				{
					show();
				}
			}
		}
		private function playBtnClickHandler(evn:MouseEvent):void
		{
			dispatchEvent(new Event("playBtnClick"));
		}
		private function pauseBtnClickHandler(evn:MouseEvent):void
		{
			dispatchEvent(new Event("pauseBtnClick"));
		}
		private function fullscreenBtnClickHandler(evn:MouseEvent):void
		{
			dispatchEvent(new Event("fullscreenBtnClick"));
		}
		private function progressBarChangeHandler(evn:Event):void
		{
			var event:ProgressChangeEvent = new ProgressChangeEvent(ProgressChangeEvent.CHANGE);
			event.per = _progressBar.currentPercent;
			dispatchEvent(event);
		}
		private function progressBarPressedHandler(evn:Event):void
		{
			dispatchEvent(new Event("progressBarBlockPressed"))
		}
		private function progressBarReleasedHandler(evn:Event):void
		{
			dispatchEvent(new Event("progressBarBlockReleased"))
		}
		private function screenClickHotClickHandler(evn:Event):void
		{
			dispatchEvent(new Event("screenClickHotClick"));
		}
		private function screenClickHotDoubleClickHandler(evn:Event):void
		{
			//dispatchEvent(new Event("screenClickHotDoubleClick"));
		}
		private function bigPlayBtnClickHandler(evn:Event)
		{
			_bigPlayBtn.visible = false;
			dispatchEvent(new Event("bigPlayBtnClick"));
		}
		private function passClickedHandler(evn:Event):void
		{
			dispatchEvent(new Event("passClicked"))
		}
		private function pathClickHandler(evn:MouseEvent):void
		{
			if ((_controlBar.progressBar.path.mouseX / _controlBar.progressBar.width) < _controlBar.progressBar.loadingBar.scaleX)
			{
				_progressBar.currentPercent = _controlBar.progressBar.path.mouseX / _controlBar.progressBar.width;
				dispatchEvent(new Event("progressBarChange"));
			}
		}
		private function soundBtnClickHandler(evn:MouseEvent):void
		{
			/*if (_controlBar.progressBar.soundBtn.currentFrame == 1)
			{
				_controlBar.progressBar.soundBtn.gotoAndStop(2);
				_volBar.currentPercent = 0;
			}
			else
			{
				_controlBar.progressBar.soundBtn.gotoAndStop(1);
				_volBar.currentPercent = 0;
			}*/
		}
		private function volBarChangeHandler(evn:Event):void
		{
			var event:VolChangeEvent = new VolChangeEvent(VolChangeEvent.CHANGE);
			event.vol = _volBar.currentPercent;
			dispatchEvent(event);
		}
		private function show(immediately:Boolean=false):void
		{
				_isShow = true;
				TweenLite.killTweensOf(_controlBar);
				var targetPosition:Number = _stage.stageHeight - _controlBar.height;
				if (immediately)
				{
					_controlBar.y =targetPosition;
				}
				else
				{
					TweenLite.to(_controlBar, 0.5, { y:targetPosition, ease:Circ.easeOut } );
				}
		}
		private function hide(immediately:Boolean=false):void
		{
			_isShow = false;
			TweenLite.killTweensOf(_controlBar);
			var targetPosition:Number = _stage.stageHeight;
			if (immediately)
			{
				_controlBar.y = targetPosition;
			}
			else
			{
				TweenLite.to(_controlBar, 0.5, { y:targetPosition, ease:Circ.easeOut } );
			}
		}
		public function add(skin:Skin,live:Boolean=false):void
		{
			_live = live;
			initTimer();
			init(skin);
		}
		//设置时间信息
		public function setTime(currentTime:Number,totalTime:Number):void
		{
			_controlBar.time.txt.text = MyDate.getFormatTime(currentTime, true) + " / " + MyDate.getFormatTime(totalTime, true);
		    if (totalTime > 0)
			{
				_progressBar.currentPercent = currentTime / totalTime;
			}
		}
		public function setDownLoadSpeed(B:Number,b:Number,clear:Number=0):void
		{
			if (clear == 1)
			{
				//_controlBar.downLoadSpeed.btxt.text  = String(b) + "Kb/S";
				_controlBar.downLoadSpeed.Btxt.text  = String(B) + "KB/S";
			}
			else
			{
				_nnnn++;
				if (_nnnn == 5)
				{
					//_controlBar.downLoadSpeed.btxt.text  = String(b) + "Kb/S";
					_controlBar.downLoadSpeed.Btxt.text  = String(B) + "KB/S";
					_nnnn = 0;
				}
			}
		}
		public function setBuffering(show:Boolean,msg:String=""):void
		{
			if (Data.adShow)//如果正在显示广告
			{
				_buffering.visible = false;
				//adMsg = "让我们和您一起感受新人的幸福 "+msg;
				adMsg = ""+msg;
			}
			else//如果没有显示广告
			{
				_buffering.label.text = msg;
				_buffering.visible = show;
			}
		}
		public function scale():void
		{
			_controlBar.y = _stage.stageHeight - _controlBar.height;
			_controlBar.controlBarBg.width = _stage.stageWidth;
			_controlBar.volBtn.x = _controlBar.controlBarBg.width - _controlBar.volBtn.disRight;
			_controlBar.volBar.x = _controlBar.controlBarBg.width - _controlBar.volBar.disRight;
			_controlBar.time.x = _controlBar.controlBarBg.width - _controlBar.time.disRight;
			_controlBar.downLoadSpeed.x=_controlBar.controlBarBg.width - _controlBar.downLoadSpeed.disRight;
			_controlBar.fullscreenBtn.x = _controlBar.controlBarBg.width - _controlBar.fullscreenBtn.disRight;			
			_controlBar.progressBar.progressBarBg.width = _controlBar.time.x - _controlBar.progressBar.x - 8;
			/*
			    下面如果直接写
			        path.width=XXXXXXXX
				则
				    path.mouseX属性不准确
			*/
			_controlBar.progressBar.path.getChildAt(0).width = _controlBar.progressBar.progressBarBg.width;
			_screenClickHot.width = _controlBar.controlBarBg.width;
			_screenClickHot.height = _stage.stageHeight - _controlBar.controlBarBg.height;
			_bigPlayBtn.x = (_stage.stageWidth-_bigPlayBtn.width) / 2;
			_bigPlayBtn.y = (_stage.stageHeight-_bigPlayBtn.height) / 2;
			//_bigPlayBtn.x = 10;
			//_bigPlayBtn.y = _stage.stageHeight - _controlBar.controlBarBg.height - _bigPlayBtn.height - 20;
			_buffering.x = _stage.stageWidth / 2;
			_buffering.y = _stage.stageHeight / 2;
			_alertMsg.x = 10;
			_alertMsg.y = _stage.stageHeight - _controlBar.controlBarBg.height - _alertMsg.height - 3;
			_bg.x = 0;
			_bg.y = 0;
			_bg.width = _stage.stageWidth;
			_bg.height = _stage.stageHeight - _controlBar.controlBarBg.height;
			
			_adMsg.x = (_stage.stageWidth - _adMsg.width) / 2;
			_adMsg.y = 10;
			
			_logo.x = 20;
			_logo.y = 20;
		}
		public function get isFullScreen():Boolean
		{
			return _isFullScreen;
		}
	    public function set isFullScreen(b:Boolean):void
		{
			_isFullScreen = b;
			if (b)
			{
				TweenLite.killTweensOf(_controlBar);
				_hideControlBarTime.start();
			}
			else
			{
				TweenLite.killTweensOf(_controlBar);
				_hideControlBarTime.reset();
				show(true);
			}
		}
		public function set playBtnEnabled(b:Boolean):void
		{
			trace(b,b)
			if (b)
			{
				_controlBar.playBtn.addEventListener(MouseEvent.CLICK, playBtnClickHandler);
			}
			else
			{
				_controlBar.playBtn.removeEventListener(MouseEvent.CLICK, playBtnClickHandler);
			}
				
			_controlBar.playBtn.buttonMode = b;
		}
		public function set progressBarEnabled(b:Boolean):void
		{
			_progressBar.active = b;
		}
		//设置播放状态
		public function set setVideoStatus(status:String):void
		{
			switch(status)
			{
				case Data.PLAY:
					_controlBar.playBtn.visible = false;
					_controlBar.pauseBtn.visible = true;
					_bigPlayBtn.visible = false;
					break;
				case Data.PAUSE:
					_controlBar.playBtn.visible = true;
					_controlBar.pauseBtn.visible = false;
					_bigPlayBtn.visible = true;
					setDownLoadSpeed(0, 0,1);
					break;
				case Data.COMPLETE:
				case Data.UN_PUBLISH:
					_controlBar.playBtn.visible = true;
					_controlBar.pauseBtn.visible = false;
					_progressBar.currentPercent = 0;
					if (status == Data.COMPLETE)
					{
						_bigPlayBtn.visible = true;
					}
					setDownLoadSpeed(0, 0,1);
					break;
			}
		}
		//设置下载进度
		public function set loadPer(n:Number):void
		{
			_controlBar.progressBar.loadingBar.width = _controlBar.progressBar.progressBarBg.width*n;
		}
		//设置播放进度
		public function set playPer(n:Number):void
		{
			_progressBar.currentPercent = n;
		}
		//进度条当前值
		public function get progressBarCurrentPercent():Number
		{
			return _progressBar.currentPercent;
		}
		//进度条滑块是不是被按下了
		public function get progressBarBlockPressed():Boolean
		{
			return _progressBar.blockPressed;
		}
		public function set alertMsg(msg:String):void
		{
			_alertMsg.txt.text = msg;
		}
		public function set adMsg(msg:String):void
		{
			_adMsg.txt.text = msg;
			_adMsg.x = (_stage.stageWidth - _adMsg.width) / 2;
		}
	}

}