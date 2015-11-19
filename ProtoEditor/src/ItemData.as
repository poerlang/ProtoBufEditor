package
{
	import com.as3xls.xls.ExcelFile;
	import com.as3xls.xls.Sheet;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class ItemData
	{
		public var arr:Array;
		public var isTopType:Boolean;

		public function get isClass():Boolean
		{
			return (type2!="int32" && type2!="string");
		}

		public var comm:String;
		private var _type3:String;

		public function get type3():String
		{
			return _type3;
		}

		public function set type3(v:String):void
		{
			_type3 = v;
		}

		private var _type2:String;

		public function get type2():String
		{
			return _type2;
		}

		public function set type2(v:String):void
		{
			_type2 = v;
		}

		private var _type1:String;

		public function get type1():String
		{
			return _type1;
		}

		public function set type1(v:String):void
		{
			if(_type1 && _type1.indexOf("rep")>=0){
				trace(34234);
			}
			_type1 = v;
		}

		public var type1back:String;
		private var _name:String;

		public function get name():String
		{
			return _name;
		}

		public function set name(v:String):void
		{
			_name = v;
			if(v!=null){
				isTopType = false;
			}else{
				isTopType = true;
			}
		}

		public var num:int;
		public var isEnum:Boolean;
		public var params:Array;
		public var paramsStr:String="";
		public function ItemData()
		{
		}
		public static const MODE_NORMAL:int = 0;
		public static const MODE_SERVER:int = 1;
		public static const MODE_CLIENT:int = 2;
		public function toString(mode:int=0,index:int=0):String
		{
			if(mode==MODE_SERVER && type3=="nos"){
				return "";
			}
			if(mode==MODE_CLIENT && type3=="noc"){
				return "";
			}
			var str:String = "";
			var sub:String = "";
			params = [];
			paramsStr = "";
			if(arr){
				var count:int=1;
				if(isTopType){
					for (var i:int = 0; i < arr.length; i++){
						var c:ItemData = arr[i] as ItemData;
						var subStr:String;
							subStr = c.toString(mode,count);
						if(mode==MODE_SERVER && c.type3=="nos"){
							continue;
						}
						if(mode==MODE_CLIENT && c.type3=="noc"){
							continue;
						}
						sub += subStr;
						count++;
					}
				}
				else{
					sub = "[loop"+arr.length+"]";
				}
			}
			if(isTopType){
				str = "\n";
				var noCstring:String = getNoCstring();
				if(comm || noCstring)str+="/*"+ (comm?comm:"") + noCstring+"*/\n";
				if(isEnum){
					str+="enum "+type2+" {\n";
				}else{
					str+="message "+type2+" {\n";
				}
			}else{
				str += "    ";
				var spacesAfterName:String = space(20,name);
				var spacesAfterType2:String = space(20,type2);
				var theNum:int;
				if(mode==MODE_NORMAL){
					theNum = num;
				}else{
					theNum = index;
				}
				if(isEnum){
					str += name+ spacesAfterName +"= "+ theNum+";  "+getCommString(sub)+"\n";
				}else{
					str += type1 +"  "+ type2 +spacesAfterType2+ name+ spacesAfterName +"= "+ theNum+";  "+getCommString(sub)+"\n";
				}
				return str;
			}
			if(isTopType){
				str+=sub;
				str+="}\n";
			}
			return str;
		}
		public function space(num:int,subStr:String):String{
			num = num-subStr.length;
			var str:String = "";
			for (var i:int = 0; i < num; i++){
				str += " ";
			}
			return str;
		}
		public function getCommString(sub:String):String
		{
			var type3Str:String = "";
			if(type3){
				type3Str = "["+type3+"]";
				sub += type3Str;
				sub = sub.replace(/]\[/ig,",");
			}
			if(comm||type3)return "/*"+ (comm?comm:"") + sub+"*/";
			return sub;
		}
		
		public function getNoCstring():String
		{
			if(type3 == "nos"){
				return "[nos]";
			}
			if(type3 == "noc"){
				return "[noc]";
			}
			return "";
		}
		
		public function toXls():void
		{
			var path:String = checkPath(SOManager.get(PathConfigWin.SO_Xls_Path));
			if(!path)
				return;
			path += type2+".xls";
			
			var f:ExcelFile = new ExcelFile();
			var s:Sheet = new Sheet();
			f.sheets.addItem(s);
			
			var col:int=0;
			var me:ItemData = this;
			count(this);
			function count(d:ItemData):void{
				col++;
				if(type1=="repeated"||type1=="class"){
					if(d.arr && d.arr.length!=0){
						for (var i:int = 0; i < d.arr.length; i++){
							var sub:ItemData = d.arr[i] as ItemData;
							count(sub);
						}
					}
				}else{
					return;
				}
			}
			s.resize(3,col);
			
			var deep:int;
			deep=0;
			write(this);
			function write(d:ItemData):void{
				if(!d.isClass){
					s.setCell(0,deep,d.type2);
					s.setCell(1,deep,d.comm+"");
					s.setCell(2,deep,d.name);
					deep++;
				}
				if(d.type1=="repeated"|| (d.type1=="class")){
					if(d.type1=="repeated"){
						s.setCell(0,deep,d.type2+"_count");
						s.setCell(1,deep,d.type2+"数量");
						s.setCell(2,deep,d.arr.length);
						deep++;
					}
					if(d.arr && d.arr.length!=0){
						for (var i:int = 0; i < d.arr.length; i++){
							var sub:ItemData = d.arr[i] as ItemData;
							write(sub);
						}
					}else{
						Alert.show("errrr23432");
					}
				}
			}
			var b:ByteArray = f.saveToByteArray();
			var fs:FileStream = new FileStream();
			fs.open(new File(path),FileMode.WRITE);
			fs.writeBytes(b);
			fs.close();
		}
		
		private function checkPath(path:String):String
		{
			if(!path){
				Alert.show("xls导出目录未设定");
				return null;
			}
			if(path.slice(path.length-1)!="/" || path.slice(path.length-1)!="\\" ){
				path += "/";
			}
			return path;
		}
	}
}