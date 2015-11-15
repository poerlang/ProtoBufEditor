package
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class PathConfigWin extends Window
	{
		public function PathConfigWin(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos, "配置路径");
			var me:PathConfigWin = this;
			setSize(900,500);
			hasCloseButton = true;
			addEventListener(Event.CLOSE,function():void{
				if(me.parent)me.parent.removeChild(me);
			});
			
			var body:VBox = new VBox(this);
			
			new Label(body,0,0,"proto文件的路径:");
			var protoPath:InputText = new InputText(body, 0, 0, "" );
			protoPath.width = 888;
			getAndSave(protoPath,SO_Proto_Path,function(str:String):void{
				ProtoListWin.ins.updatePath(str);
			});
			new Label(body,0,0,"");
		}
		static public const SO_Proto_Path:String = "protoPath";
		private function getAndSave(txt:InputText, key:String,onChange:Function=null):void
		{
			txt.addEventListener(Event.CHANGE, function():void {
				SOManager.put(key,txt.text);
				if(txt.onChangeFun)txt.onChangeFun(txt.text);
			});
			txt.onChangeFun = onChange;
			var tmp:* = SOManager.get(key);
			if(tmp){
				txt.text = tmp;
				if(txt.onChangeFun)txt.onChangeFun(txt.text);
			}
		}
	}
}