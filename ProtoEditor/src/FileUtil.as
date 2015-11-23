package
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtil
	{
		public static function File2ByteArray(f:File):ByteArray
		{
			var b:ByteArray = new ByteArray();
			var s:FileStream = new FileStream();
			s.open(f,FileMode.READ);
			s.readBytes(b);
			b.position = 0;
			return b;
		}
		public static function File2String(f:File):String
		{
			var b:ByteArray = new ByteArray();
			var s:FileStream = new FileStream();
			s.open(f,FileMode.READ);
			var str:String = s.readUTFBytes(s.bytesAvailable);
			return str;
		}
		public static function getDir(s:String,otherFileName:String = ""):String
		{
			s = s.replace(/\\/ig,"/");
			var split:Array = s.split("/");
			var fileName:String = split.pop();
			var dir:String = split.join("/");
			if(otherFileName!="")
				return dir+otherFileName;
			return dir;
		}
		
		static public function saveByKey(key:String,content:String):*
		{
			var tmp:* = SOManager.get(key);
			if(tmp){
				save(tmp,content);
				return tmp;
			}
			return null
		}
		
		public static function save(path:String, content:String):void
		{
			var f:File = new File(path);
			var s:FileStream = new FileStream();
			s.open(f,FileMode.WRITE);
			s.writeUTFBytes(content);
			s.close();
		}
	}
}