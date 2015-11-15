package
{
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.DisplayObjectContainer;
	import flash.filesystem.File;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;
	
	import org.osflash.signals.Signal;
	
	public class ProtoListWin extends Window
	{
		public static var ins:ProtoListWin;
		private var path:String;
		private var body:VBox;
		private function onSaveHander():void
		{
			if(setTimeout2>0)clearInterval(setTimeout2);
			setTimeout2 = setTimeout(function():void{
				save();
			},1000);
		}
		
		private function save():void
		{
			if(!ProtoEditor.ins.rootItem){
				return;
			}
			ProtoEditor.ins.rootItem.saveSubs();
			var out:String = "";
			for (var i:int = 0; i < arr.length; i++){
				var e:ItemData = arr[i] as ItemData;
				out += e.toString();
			}
			
			out = ("package pb.gamesvr.proto;\n\n"+out);
			FileUtil.saveByKey(PathConfigWin.SO_Proto_Path,out);
		}
		public var onSave:Signal = new Signal();
		public function ProtoListWin(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="列表")
		{
			ins = this;
			onSave.add(onSaveHander);
			super(parent, xpos, ypos, title);
			var html:VBox = new VBox(this);
			var menu:HBox = new HBox(html);
			var btn:PushButton;
			var btnW:int = 40;
			btn = new PushButton(menu,0,0,"新建",function(e):void{
				AlertInput.show("输入文件名",function(str):void{
					var data:ItemData = new ItemData();
					data.name = "";
					data.type1 = "class";
					data.isTopType = true;
					data.type2 = str;
					arr.push(data);
					var fileitem:ProtoListFile = add(data);
					onSelFunction(fileitem);
				});
			});btn.width=btnW;
			btn = new PushButton(menu,0,0,"刷新",function(e):void{
				ins.updatePath(path);
			});btn.width=btnW;
			btn = new PushButton(menu,0,0,"删除",function(e):void{
				if(now){
					var index:int = arr.indexOf(now.item.ob);
					arr.removeAt(index);
					if(now.parent){
						now.parent.removeChild(now);
					}
					if(now.item.parent){
						now.item.parent.removeChild(now.item);
					}
					if(classDic[now.item.ob.type2]){
						delete classDic[now.item.ob.type2];
					}
					if(ProtoEditor.ins.rootItem==now.item){
						ProtoEditor.ins.rootItem = null;
					}
					now = null;
				}
			});btn.width=btnW;
			btn = new PushButton(menu,0,0,"保存 proto",function(e):void{
				save();
			});btn.width=btnW+30;
			body = new VBox(html);
		}
		public var now:ProtoListFile;
		public var classDic:Array = [];

		private var setTimeout2:uint;

		private var arr:Array;
		public function updatePath(path:String):void
		{
			if(!path){
				Alert.show("目录尚未设定,请 [设置路径]");
				return;
			}
			now = null;
			body.removeChildren();
			this.path = path;
			var f:File = new File(path);
			if(f.exists){
				if(f.isDirectory){
					return;
				}
				if(f.extension.toLowerCase()!="proto"){
					return;
				}
				var p:ProtoParser = new ProtoParser();
				classDic = ["int32","string","bytes"];
				p.go(f,function(arr:Array):void{
					ins.arr = arr;
					for (var i:int = 0; i < arr.length; i++){
						var ob:* = arr[i];
						add(ob);
					}
				});
			}
		}
		
		public function add(ob:ItemData):ProtoListFile
		{
			if(!ob.isEnum){
				classDic.push(ob.type2);
			}
			var msg:ProtoListFile = new ProtoListFile(body,ob.type2,ob);
			msg.onSel = onSelFunction;
			return msg;
		}
		
		protected function onSelFunction(msg:ProtoListFile):void
		{
			// TODO Auto Generated method stub
			if(now && now!=msg){
				now.isSel = false;
			}
			msg.isSel = true;
			now = msg;
			ProtoEditor.ins.show(now);
		}
	}
}