package
{
	import com.as3xls.xls.Cell;
	import com.as3xls.xls.ExcelFile;
	import com.as3xls.xls.Sheet;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import parser.Script;
	
	import proto.EquipList2;
	import proto.PlayerInfoList2;

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
		public var value:*;
		
		/**协议序号**/
		public var code:int=-1;
		
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
		public function getLoopNum():int
		{
			var num:int;
			var searchIndex:int = paramsStr.search(/loop\d/);
			if(searchIndex>=0){
				var searchIndex2:int = paramsStr.search(/loop\d\d/);//支持两位数的 repeated 数量
				var units:int = searchIndex2>=0? 2:1;//位数
				num = parseInt(paramsStr.slice(searchIndex+4,searchIndex+4+units));
			}
			return num;
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
			
			var index:int=0;
			write(this,this.type2);
			function write(d:ItemData,parentName:String=""):void{
				if(!d.isClass && d.type1!="repeated"){
					s.setCell(0,index,simple(d.type2));
					s.setCell(1,index,parentName!=""?(parentName+"."+d.name+"."+d.type2):(d.name+"."+d.type2));
					s.setCell(2,index,d.comm+"");
					index++;
				}
				else if (d.type1=="repeated") {
					var subLen:int = d.getLoopNum();
					if(subLen==0){
						Alert.show("你忘了写loop属性");return;
					}
					s.setCell(0,index,"int");
					s.setCell(1,index,"["+(parentName!=""?(parentName+"."+d.name+"("+d.type2):(d.name+"("+d.type2))+")×"+subLen+"]");
					s.setCell(2,index,"["+d.comm+"×"+subLen+"]");
					index++;
					if(!d.arr){
						d.arr = [];
						if(d.isClass){
							var item:ItemData = ProtoParser.classDic[d.type2];
							for (var j:int = 0; j < subLen; j++){
								item = ProtoParser.clone(item);
								d.arr.push(item);
							}
						}
					}
					for (var k:int = 0; k < subLen; k++){
						sub = d.arr[k] as ItemData;
						if(sub && sub.isClass){
							write(sub,parentName+"."+d.type2);
						}else{
							s.setCell(0,index,simple(d.type2));
							//s.setCell(1, index, parentName != ""?(parentName+"." + d.name):d.name);
							s.setCell(1,index,parentName!=""?(parentName+"."+d.name+"."+d.type2):d.name+"."+d.type2);
							s.setCell(2,index,d.comm+"");
							index++;
						}
					}
				}
				else if(d.isClass){
					if(!d.arr){
						d.arr = [];
						if(d.isClass){
							var item2:ItemData = ProtoParser.classDic[d.type2];
							for (var jj:int = 0; jj < subLen; jj++){
								item2 = ProtoParser.clone(item2);
								d.arr.push(item2);
							}
						}
					}
					for (var i:int = 0; i < d.arr.length; i++){
						var sub:ItemData = d.arr[i] as ItemData;
						if(sub.isClass || sub.type1=="repeated"){
							write(sub,parentName!=""?(parentName):"");
						}else{
							s.setCell(0,index,simple(sub.type2));
							s.setCell(1,index,parentName!=""?(parentName+"."+sub.name):sub.name);
							s.setCell(2,index,sub.comm+"");
							index++;
						}
					}
				}
				else {
					throw new Error("未处理的类型");
				}
			}
			for (var l:int = 0; l < s.values.length; l++) 
			{
				var l1:Object = s.values[l];
				var str:String = "";
				for (var m:int = 0; m < l1.length; m++) 
				{
					str+=l1[m].value+ "  " ;
				}
				trace(str);
			}
			trace(34234);
			var b:ByteArray = f.saveToByteArray();
			var fs:FileStream = new FileStream();
			fs.open(new File(path),FileMode.WRITE);
			fs.writeBytes(b);
			fs.close();
		}
		
		public function toCfg():void
		{
			var path:String = checkPath(SOManager.get(PathConfigWin.SO_Xls_Path));
			if(!path)
				return;
			path += type2+".xls";
			var f:ExcelFile = new ExcelFile();
			var fs:FileStream = new FileStream();
			fs.open(new File(path),FileMode.READ);
			var b:ByteArray = new ByteArray();
			fs.readBytes(b);
			fs.close();
			f.loadFromByteArray(b);
			var s:Sheet = f.sheets[0];
			
			var obs:Array = [];
			for (var k:int = 0; k < s.rows; k++){
				obs.push(Script.New(type2));
				//obs.push({});
			}
			for (var i:int = 3; i < s.rows; i++){
				var index:int=0;
				write(this,obs[i],i);
			}
			function write(d:ItemData,p:*,i2:int):void{
				if(d.type1=="repeated"|| (d.type1=="class")){
					var subLen:int = d.getLoopNum();
					if(!d.arr){
						d.arr = [];
						for (var j:int = 0; j < subLen; j++){
							if(d.isClass){
								var item:ItemData = ProtoParser.classDic[d.type2];
								item = ProtoParser.clone(item);
								d.arr.push(item);
							}
						}
					}
					if(d.type1=="repeated"){
						var c:Cell = s.getCell(i2,index);
						var realLen:int = c.value;
						index++;
						if(!p[d.name])p[d.name]=[];
						for (var cc:int = 0;  cc< realLen; cc++){
							if(d.isClass){
								var n:* = Script.New(d.type2);
								var a:* = p[d.name];
								a.push(n);
								write(d.arr[cc],a[cc],i2);
							}else{
								c = s.getCell(i2,index);
								p[d.name].push(c.value);
								index++;
							}
						}
					}
					if(d.type1=="class"){
						for (var i3:int = 0; i3 < d.arr.length; i3++){
							write(d.arr[i3],p,i2);
						}
					}
				}else{
					c = s.getCell(i2,index);
					p[d.name] = c.value;
					index++;
				}
			}
			var list:* = Script.New(type2+"List");
			
			for (var j:int = 3; j < obs.length; j++){
				var o:Object = obs[j];
				list.arr.push(o);
				//var byte:ByteArray = Main.write(o);
			}
			var byte:ByteArray = Main.write(list);
			if(type2.indexOf("Eq")<0){
				var e:PlayerInfoList2 = new PlayerInfoList2();
				e.mergeFrom(byte);
				trace(e);
			}
		}
		
		private function simple(s:String):String
		{
			if(s=="int32")return "int";
			if(s=="string")return "str";
			return s;
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