package
{
	public class ItemData
	{
		public var arr:Array;
		public var isTopType:Boolean;
		public var comm:String;
		public var type3:String;
		public var type2:String;
		public var type1:String;
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
		public function ItemData()
		{
		}
		public function toString():String
		{
			var str:String = "";
			var sub:String = "";
			if(arr){
				if(isTopType){
					for (var i:int = 0; i < arr.length; i++){
						var c:ItemData = arr[i] as ItemData;
						sub+=c.toString();
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
				if(isEnum){
					str += name+ spacesAfterName +"= "+ num+";  "+getCommString(sub)+"\n";
				}else{
					str += type1 +"  "+ type2 +spacesAfterType2+ name+ spacesAfterName +"= "+ num+";  "+getCommString(sub)+"\n";
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
			}
			if(comm||type3)return "/*"+ (comm?comm:"") + sub + type3Str+"*/";
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
	}
}