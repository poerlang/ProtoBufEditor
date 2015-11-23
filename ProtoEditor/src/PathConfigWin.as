package
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
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
			
			new Label(body,0,0,"proto文件的路径/文件名:");
			var protoPath:InputText = new InputText(body, 0, 0, "" );
			protoPath.width = 888;
			
			new Label(body,0,0,"xls文件的目录:");
			var xlsPath:InputText = new InputText(body, 0, 0, "" );
			xlsPath.width = 888;
			
			getAndSave(protoPath,SO_Proto_Path,function(str:String):void{
				ProtoListWin.ins.updatePath(str);
			});
			getAndSave(xlsPath,SO_Xls_Path,function(str:String):void{
				
			});
			new Label(body,0,0,"");
		}
		static public const SO_Proto_Path:String = "protoPath";
		static public const SO_Xls_Path:String = "xlsPath";
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