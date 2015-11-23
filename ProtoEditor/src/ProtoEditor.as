package {
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**编辑器UI*/
	public class ProtoEditor extends Sprite {
		public var ui:Window;
		private static var _instance:ProtoEditor;
		public function ProtoEditor() {
			if(_instance){
				throw new Error("ProtoEditor单例错误");
			}
			mouseEnabled = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public var cur:Number=0;
		public var target:Number=1;

		private var to:TweenLite;

		public static function get ins():ProtoEditor
		{
			if(_instance==null){
				_instance = new ProtoEditor();
			}
			return _instance;
		}

		private function showMe():void {
			if(!ui){
				init();
			}
			addChild(ui);
			onResize();
		}
		private var body:VBox;
		private var histroyWin:Window;
		private var protoPath:InputText;
		private var pathConfigWin:PathConfigWin;

		private var protoListWin:ProtoListWin;

		public var rootItem:Item;
		private function init():void
		{
			SOManager.NAME = "ProtoEditorSO";
			Style.embedFonts = false;
			Style.fontSize = 12;
			Style.fontName = "Verdana";
			ui = new Window(null,0,0,"ProtoEditor");
			ui.hasCloseButton = true;
			ui.hasMinimizeButton = true;
			ui.addEventListener(Event.CLOSE,function(e:*):void{
				hide();
			});
			protoListWin = new ProtoListWin(ui);
			pathConfigWin = new PathConfigWin(null);
			
			var html:VBox = new VBox(ui);
			var menu:HBox = new HBox(html);
			body = new VBox(html);
			
			new PushButton(menu,0,0,"导出xls",function():void{
				export();
			});
			new PushButton(menu,0,0,"导出cfg",function():void{
				export2();
			});
			new PushButton(menu,0,0,"发送",function():void{
				export3();
			});
			new PushButton(menu,0,0,"配置路径",function():void{
				if(pathConfigWin.parent==null){
					ins.addChild(pathConfigWin);
					center(pathConfigWin,52);
				}else{
					ins.removeChild(pathConfigWin);
				}
			});
		}
		
		private function export():void
		{
			protoListWin.export();
		}
		private function export2():void
		{
			protoListWin.export2();
		}
		private function export3():void
		{
			protoListWin.export3();
		}
		public function show(f:ProtoListFile):void {
			body.removeChildren();
			rootItem = f.item;
			body.addChild(rootItem);
		}
		public function hide():void {
			if(ui && contains(ui)) removeChild(ui);
		}
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RESIZE, onResize);
			showMe();
			onResize(null);
		}
		private function onResize(e:Event=null):void {
			if(ui){
				center(ui);
				ui.setSize(stage.stageWidth-4,stage.stageHeight-4);
				var histroyW:int = 300;
				protoListWin.x = ui.width-histroyW-5;
				protoListWin.y = 3;
				protoListWin.setSize(histroyW,ui.height-30)
			}
		}
		private function center(ui:Window,yy:int=0):void
		{
			ui.x = (stage.stageWidth - ui.width) * 0.5;
			ui.y = yy;
		}
	}
}