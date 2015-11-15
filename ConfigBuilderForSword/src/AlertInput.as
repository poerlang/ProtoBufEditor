package {
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.setTimeout;

	public class AlertInput extends Window {
		public static var one:AlertInput;
		public static var txt:TextArea;

		private var fun:Function;

		public function AlertInput(parent:DisplayObjectContainer) {
			super(parent, 0, 0, title);
			if (one) {
				throw new Error("单例错误");
			} else {
				one=this;
			}
			this.visible=false;
			setSize(400, 150);
			var body:VBox = new VBox(this);
			hasCloseButton=true;
			addEventListener(Event.CLOSE,function(e):void{
				hide();
			});
			
			txt=new TextArea(body, 3, 3, "");
			new PushButton(body,0,0,"OK",onOK);
			txt.setSize(this.width - 6, this.height - 6 - 50);
		}
		
		private function onOK(e):void
		{
			fun(txt.text);	
			hide();
		}
		
		public static function show(_title:String,fun:Function):void {
			if (one == null)
				throw new Error("未初始化Alert");
			one.fun = fun;
			one.visible=true;
			one.title = _title;
			one.parent.addChild(one);
			txt.text= "";
			center();
		}

		public static function hide():void {
			one.visible=false;
		}

		private static function center():void {
			one.x=(one.parent.stage.stageWidth - one.width) / 2 - 200;
			one.y=(one.parent.stage.stageHeight - one.height) / 2 - 20;
		}
	}
}
