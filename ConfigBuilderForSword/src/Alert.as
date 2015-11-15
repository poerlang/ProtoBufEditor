package {
	import com.bit101.components.TextArea;
	import com.bit101.components.Window;

	import flash.display.DisplayObjectContainer;
	import flash.utils.setTimeout;

	public class Alert extends Window {
		public static var one:Alert;
		public static var txt:TextArea;

		public function Alert(parent:DisplayObjectContainer) {
			super(parent, 0, 0, "提示");
			if (one) {
				throw new Error("单例错误");
			} else {
				one=this;
			}
			this.visible=false;
			setSize(400, 150);
			txt=new TextArea(this, 3, 3, "");
			txt.setSize(this.width - 6, this.height - 6 - 20);
		}

		public static function show(content:String="内容", delayOutSecond:int=3):void {
			if (one == null)
				throw new Error("未初始化Alert");
			one.visible=true;
			one.parent.addChild(one);
			txt.text=content;
			center();
			setTimeout(hide, delayOutSecond * 1000);
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
