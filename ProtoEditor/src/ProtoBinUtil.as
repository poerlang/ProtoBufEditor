package 
{
	import com.netease.protobuf.Message;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class ProtoBinUtil extends Object
	{
		private static var classMap:Object;
		public static function protoDecode(cfgByte:ByteArray):Object
		{
			cfgByte.endian = flash.utils.Endian.LITTLE_ENDIAN;
			var keyLength:int = 0;
			var keyName:String = "";
			var dataLength:uint;
			var obj:Object = {};
			while(cfgByte.position != cfgByte.length)
			{
				keyLength = cfgByte.readInt();
				keyName = cfgByte.readMultiByte(keyLength, "unix");
				dataLength = cfgByte.readUnsignedInt();
				var dataByte:ByteArray = new ByteArray();
				dataByte.writeBytes(cfgByte, cfgByte.position, dataLength);
				cfgByte.position += dataLength;
				dataByte.position = 0;
				var configType:Class = classMap[keyName];
				if(configType)
				{
					var pbMessage:Message = new configType();
					pbMessage.mergeFrom(dataByte);
				}
				else
				{
					throw new Error("找不到配置文件>>>>>>"+keyName);
				}
				obj[keyName] = pbMessage;
			}
			return obj;
		}
	}
}