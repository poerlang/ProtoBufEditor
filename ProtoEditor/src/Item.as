package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.ComboBox2;
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import parser.Script;
	
	public class Item extends VBox
	{
		//data:
		public var _propArray:Array = [];
		public var subArray:Array = [];
		
		public var desc:String = "";
		public var type1:String = "";		//类型
		public var type2:String = "";		//类名
		public var val:* = null;
		public var deep:int = 0;
		private var me:Item;

		private var inputText:InputText;
		private var subs:VBox;

		private var label:Label;
		public var ob:ItemData;
		private var hasDraw:Boolean;

		public function get isTopType():Boolean
		{
			return ob.isTopType;
		}

		public function get protos():Array
		{
			return _propArray;
		}
		public function set protos(value:Array):void
		{
			_propArray = value;
		}
		public function Item()
		{
			me = this;
			addEventListener(Event.ADDED_TO_STAGE,onAdd);
		}
		
		protected function onAdd(e:Event):void
		{
			if(hasDraw){
				return;
			}
			drawByProtos();
			up();
		}
		
		private function drawByProtos():void{
			wrap(this,ob);
			hasDraw = true;
			menu = new HBox(me);
			if(ob.arr && ob.arr.length>0){
				if(!subs)subs = new VBox(me);
				for (var i:int = 0; i < _propArray.length; i++){
					var sub:* = _propArray[i];
					var item1:Item = new Item();
					item1.ob = sub;
					item1.deep = deep+1;
					subs.addChild(item1);
				}
			}
			
			var deepStr:String = "";
			for (var k:int = 0; k < deep; k++) 
			{
				deepStr += "    ";
			}
			new Label(menu,0,0,deepStr);
			
			inputText = new InputText(menu,0,0,ob.isClass?type2:ob.name,function(e):void{
				ob.name = e.target.text;
				save();
			}); inputText. width=150;
			
			if(ob.isClass && ob.type1!="repeated"){
				new ComboBox(menu,0,0,type2=="enum"?"enum":"class",comb_type0,function(c):void{
					ob.type1 = c.selectedItem;
					save();
					if(ob.type1=="enum"){
						ob.isEnum = true;
					}else{
						ob.isEnum = false;
					}
					if(!subs) return;
					for (var j:int = 0; j < subs.numChildren; j++){
						var s:Item = subs.getChildAt(j) as Item;
						if(s.ob.type1back==null){
							s.ob.type1back = s.ob.type1==""?comb_type1[0]:s.ob.type1;
						}
						s.ob.isEnum = ob.type1=="enum";
						if(s.ob.isEnum){
							s.ob.type1 = "";
						}else{
							s.ob.type1 = s.ob.type1back;
						}
						s.clear();
						s.drawByProtos();
					}
					save();
				});
			}else{
				if(type1!="")new ComboBox(menu,0,0,type1,comb_type1,function(c:ComboBox):void{
					ob.type1back = ob.type1 = c.selectedItem+"";
					clear();
					drawByProtos();
					save();
				});
				if(type1!="")new ComboBox2(menu,0,0,type2,comb_type2,function(c:ComboBox2):void{
					if(c.text=="class"){
						c.text = "";
						Alert.show("请输入类名");
						return;
					}
					ob.type2 = c.text;
					save();
				},function(key:String):Array{
					var tmp:Array = [];
					key = key.toLowerCase();
					var dic:Array = ProtoListWin.ins.classDic;
					for (var j:int = 0; j < dic.length; j++){
						var str:String = dic[j];
						if(str.toLowerCase().indexOf(key)>=0){
							tmp.push(str);
						}
					}
					return tmp;
				});
			}
			new InputText(menu,0,0,ob.comm,function(e):void{
				ob.comm = e.target.text;
				save();
			})
			
			if(ob.type1=="repeated"){
				if(!subs)subs = new VBox(me);
				function addsub(p:Item,data:ItemData=null):void{
					p.alpha = 1;
					var item2:Item = new Item;
					
					if(data==null){
						data = new ItemData();
						data.type1 = "required";
						data.type2 = ob.type2;
						data.name = "";
					}
					wrap(item2,data);
					p.subArray.push(item2);
					item2.deep = p.deep+1;
					if(!p.subs)p.subs = new VBox(p); 
					if(data.isClass){
						data.type1 = "class";
					}
					p.subs.addChild(item2);
					if(data.isClass && data.type1!="repeated"){
						var aClass:ItemData = ProtoParser.classDic[data.type2];
						if(aClass && aClass.arr){
							for (var i2:int = 0; i2 < aClass.arr.length; i2++){
								var c:ItemData = aClass.arr[i2] as ItemData;
								addsub(item2,c);
							}
						}
					}
					p.up();
					p.saveSubs();
					p.save();
				}
				var num:int = ob.getLoopNum();
				if(num>0){
					for (var j:int = 0; j < num; j++){
						setTimeout(addsub,55*j,me);
					}
				}
				function onPlus():void{
					addsub(me);
				}
				var plus:PushButton = new PushButton(menu,0,0,"+",onPlus);
				var minus:PushButton = new PushButton(menu,0,0,"-",function():void{
					if(subs.numChildren==0){
						return;
					}
					var child:Item = subs.getChildAt(subs.numChildren-1) as Item;
					subs.removeChild(child);
					var index:int = subArray.indexOf(child);
					if(index>=0){
						subArray.splice(index,1);
					}
					if(subs.numChildren==0){
						alpha = 0.3;
					}
					if(isOptional){
						subArray = [];
						plus.enabled = true;
					}
					up();
					me.saveSubs();
					save();
				});
			}
			if(deep<2){
				new ComboBox(menu,0,0,ob.type3?value2label(ob.type3,comb_type3):"",comb_type3,function(c:ComboBox):void{
					ob.type3 = c.selectedItem.value+"";
					save();
					if(!subs) return;
					for (var j:int = 0; j < subs.numChildren; j++){
						var s:Item = subs.getChildAt(j) as Item;
						s.ob.type3 = null;
						s.clear();
						s.drawByProtos();
					}
					save();
				},135);
			}
			if(ob.isClass){
				if(deep<2){
					new PushButton(menu,0,0,"添加子项",function():void{
						me.alpha = 1;
						var item2:Item = new Item;
						var data:ItemData = new ItemData();
						data.name = "";
						if(ob.isEnum){
							data.isEnum = ob.isEnum;
							data.type1 = "";
						}else{
							data.type1 = "required";
						}
						data.type2 = "int32";
						wrap(item2,data);
						subArray.push(item2);
						item2.deep = deep+1;
						if(!subs)subs = new VBox(me);
						subs.addChild(item2);
						up();
						save();
					});
				}
				if(!isTopType){
					if(deep<3){
						new PushButton(menu,0,0,"删除此项",function():void{
							dispose();
							save();
						});
					}
				}
			}else{
				if(deep<3){
					new PushButton(menu,0,0,"删除此项",function():void{
						dispose();
						save();
					});
				}
			}
			var inputValue:InputText = new InputText(menu,0,0,"value");
			inputValue.addEventListener(Event.CHANGE,function(e:Event):void{
				var input:InputText = e.target as InputText;
				value = type2=="int32"?parseInt(input.text):input.text;
			});
		}
		
		public static var classDic:Dictionary = new Dictionary();
		private function save():void
		{
			ProtoListWin.ins.onSave.dispatch();
		}
		
		private function dispose():void
		{
			if(parent){
				var p:Item;
				if(parent.parent){
					p = parent.parent as Item;
				}
				parent.removeChild(this);
				if(p)p.saveSubs();
			}
		}
		public function value2label(key:String,arr:Array):String{
			for (var i:int = 0; i < arr.length; i++){
				if(key==arr[i].value)
					return arr[i].label;
			}
			return null;
		}
		private function clear():void
		{
			hasDraw = false;
			removeChildren();
		}
		public static const comb_type0:Array = ["enum","class"];
		public static const comb_type1:Array = ["required","optional","repeated"];
		public static const comb_type2:Array = ["int32","string","bytes","class"];
		public static const comb_type3:Array = [{value:"",label:""},{value:"nos",label:"此字段服务端不使用"},{value:"noc",label:"此字段客户端不使用"}];

		private var menu:HBox;
		public var value:*;

		public function get isEnum():Boolean
		{
			if(!ob.hasOwnProperty("isEnum"))
				return false;
			return ob.isEnum;
		}


		public function get isOptional():Boolean
		{
			return ob.type1=="optional";
		}

		public function up():void
		{
			setTimeout(function():void{
				if(!subs)return;
				subs.draw();
					me.draw();
					if (me.parent == null || me.parent.parent==null) return;
					var p:Item = me.parent.parent as Item;
					if(p){
						p.up();
					}
			},1);
		}

		public static function wrap(item:Item,obj:ItemData):Item
		{
			item.ob = obj;
			if(obj.hasOwnProperty("arr"))item.protos = obj.arr;
			item.type1 = obj.type1;
			item.type2 = obj.type2;
			item.val = obj.num;
			return item;
		}
		
		private function returnRightType(text:String, type:String):*
		{
			switch(type)
			{
				case "bytes":
				{
					return parseFloat(text);
					break;
				}
				case "int32":
				{
					return parseInt(text);
					break;
				}
				case "flash.utils.ByteArray":
				{
					//写入格式:    1,90,233,8,5,66,255
					var split:Array = text.split(",");
					var b:ByteArray = new ByteArray();
					for (var i:int = 0; i < split.length; i++) 
					{
						b.writeByte(parseInt(split[i]));
					}
					return b;
					break;
				}
				default:
				{
					return text;
				}
			}
			return null;
		}
		
		public function saveSubs():void
		{
			var newArr:Array = [];
			if(!subs)subs = new VBox(me);
			for (var i:int = 0; i < subs.numChildren; i++){
				var item:Item = subs.getChildAt(i) as Item;
				item.ob.num=i+1;
				newArr.push(item.ob);
			}
			ob.arr = newArr;
		}
		public function toMsg():ByteArray
		{
			var msg:* = write(this);
			function write(d:Item):*{
				var item:Item;
				var subLen:int;
				if(d.subs)subLen = d.subs.numChildren;
				if(d.type1=="class"){
					var msg:* = Script.New(type2);
					for (var i:int = 0;  i< subLen; i++){
						item = d.subs.getChildAt(i) as Item;
						var v:* = write(item);
						if(item.ob.type1=="optional"){
							msg[item.ob.name+"$field"] = v;
						}else{
							msg[item.ob.name] = v;
						}
						
					}
					return msg;
				}
				if(d.type1=="repeated"){
					var tmp:Array = [];
					for (var k:int = 0;  k< subLen; k++){
						item = d.subs.getChildAt(k) as Item;
						tmp.push(write(item));
					}
					return tmp;
				}
				return d.value;
			}
			var b:* = Main.write(msg)
			return b;
		}
	}
}