package data 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import zhen.guo.yao.components.yaotrace.YaoTrace;
	
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class Data
	{
		//播放状态
		public static const PLAY:String = "_play";
		public static const PAUSE:String = "_pause";
		public static const COMPLETE:String = "_playComplete";
		public static const UN_PUBLISH:String = "_unPublish";
		
		public static const GET_AD_URL:String = "http://www.doudoulive.cn/flv/get_pic_info/?";//获取图片、视频信息地址
		//public static const GET_AD_URL:String = "http://localhost/a.txt?";
		public static const SHOW_AD_AFTER_TIME:Number = 10*1000;//流中断多长时间后，显示图片、视频
		
		public static var videoRatio:Object="";//视频宽高比例
		public static var bufferTime:Number = 3*1000;//缓冲时间
		public static var fms:String = "";//fms地址
		public static var stream:String="";//流名称
		public static var skin:String = "";//皮肤地址
		public static var live:Boolean = false;//是否是直播
		public static var autoPlay:Boolean = false;//是否自动播放
		public static var showLogo:Boolean = false;//是否显示logo
		
		public static var parm_flvID:String = "";
		public static var parm_stream:String = "";
		
		public static var isFullScreen:Boolean = false;//是否是全屏		
		public static var adShow:Boolean = false;//广告是否显示了
		
		public static function getData(obj:Stage):void
		{
			Data.skin = obj.loaderInfo.parameters.skin;
			Data.stream = "02e4aa5c";
			var f = "rtmp://weblukerlivedown.ccgslb.com.cn/3a0c51bce5b5d151";
			var r = obj.loaderInfo.parameters.ratio;
			var l = obj.loaderInfo.parameters.live;
			var a = obj.loaderInfo.parameters.autoPlay;
			var logo = obj.loaderInfo.parameters.showLogo;
			var pf = obj.loaderInfo.parameters.flv_id;
			var ps = obj.loaderInfo.parameters.stream;
			var bt = obj.loaderInfo.parameters.bufferTime;
			
			
			/*Data.skin ="videoPlayerSkin.swf";
			Data.stream = "tv05";
			var f = "rtmp://113.57.230.25:554/live/";
			var r = "16:9";
			var l = "true";
			var a = "true";
			var pf = "";
			var ps = "";
			var logo = "false";
			var bt="5"*/
			
			
			/*Data.skin ="videoPlayerSkin.swf";
			Data.stream = "qq";
			var f = "rtmp://weblukerlivedown.ccgslb.com.cn/c74f7e57623aee81";
			//var f = "rtmp://61.156.15.20:8080/liverepeater";
			var r = "null";
			var l = "true";
			var logo = "true";
			var a = "false";
			var pf = "87";
			var ps = "759121b0"
			var bt = "10";*/
			
			
			
			/*Data.skin ="videoPlayerSkin.swf";
			Data.stream = "livestream23";
			
			var f = "rtmp://weblukerlivedown.ccgslb.com.cn/c74f7e57623aee81";
			var r = "16:9";
			var l = "false";
			var a = "true";
			var pf = "";
			var ps = "";*/
			
			/*Data.skin ="videoPlayerSkin.swf";
			Data.stream = "livestream2356";
			var f = "rtmp://localhost/test/";
			var r = "";
			var l = "true";
			var logo = "false";
			var a = "false";
			var pf = "87";
			var ps = "759121b0";*/
			
			/*Data.skin ="videoPlayerSkin.swf";
			//Data.stream = "http://www.hunshitong.cn/portal_media/hst.flv";
			Data.stream = "abccc";
			//var f = "rtmp://weblukerliveup.ccgslb.com.cn/weblukerlive";
			var f = "rtmp://localhost/test";
			var r = "";
			var l = "true";
			var a = "true";
			var pf = "";
			var ps = "a.flv";
			var logo = "true";
			var bt = "1";*/
			
		    YaoTrace.add(YaoTrace.ALL, "接收到 skin 值为：" + Data.skin);
		    YaoTrace.add(YaoTrace.ALL, "接收到 streamName 值为：" + Data.stream);
			YaoTrace.add(YaoTrace.ALL, "接收到 fms 值为：" + f);
		    YaoTrace.add(YaoTrace.ALL, "接收到 ratio 值为：" + r);
		    YaoTrace.add(YaoTrace.ALL, "接收到 live 值为：" + l);
		    YaoTrace.add(YaoTrace.ALL, "接收到 autoPlay 值为：" + a);
		    YaoTrace.add(YaoTrace.ALL, "接收到 showLogo 值为：" + logo);
			YaoTrace.add(YaoTrace.ALL, "接收到 bufferTime 值为：" + bt);
			YaoTrace.add(YaoTrace.ALL, "接收到 flv_id 值为：" + pf);
		    YaoTrace.add(YaoTrace.ALL, "接收到 stream2 值为：" + ps);
			
			//检测传入的数据是否合法
			if (f != null && f != undefined && f != "null" && f != "undefined")
			{
			    Data.fms=f;
			}
			if (r != null && r != undefined && r != "null" && r != "undefined")
			{
			    Data.videoRatio=r;
			}
			if(l=="true")
			{
			    Data.live=true;
			}
			if(a=="true")
			{
			    Data.autoPlay=true;
			}
			if(logo=="true")
			{
			    Data.showLogo=true;
			}
			if (pf != null && pf != undefined && pf != "null" && pf != "undefined")
			{
			    Data.parm_flvID=pf;
			}
			if (ps != null && ps != undefined && ps != "null" && ps != "undefined")
			{
			    Data.parm_stream=ps;
			}
			if (bt != null && bt != undefined && bt != "null" && bt != "undefined" && bt != "")
			{
			    Data.bufferTime=Number(bt)*1000;
			}
		}
		
	}

}