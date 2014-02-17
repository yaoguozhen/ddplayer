package  
{
	import data.Data;
	/**
	 * ...
	 * @author yaoguozhen
	 */
	public class CheckData 
	{
		public static function check():String
		{
			var msg:String = "";
			if (Data.skin== null || Data.skin== undefined || Data.skin== "null" || Data.skin== "undefined")
			{
				msg+="参数 skin 必须被设置 | "
			}
			if (Data.stream== null || Data.stream== undefined || Data.stream== "null" || Data.stream== "undefined")
			{
				msg+="参数 streamName 必须被设置 | "
			}
			if (Data.live)
			{
				if (Data.fms == "")
				{
					msg += "live 参数被设置为true，此时 fms 参数也必须要被设置 | ";
				}
			}
			
			return msg;
		}
	}

}