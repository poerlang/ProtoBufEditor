package morn.core.components {
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	
	/**对话框*/
	public class MyDialog extends Dialog {
		public var isAirWindow:Boolean;
		private var dragResize:DisplayObject;
		private var dragTarget:DisplayObject;
		public function MyDialog() {
		}
		
		override protected function initialize():void {
			dragTarget = getChildByName("drag");
			dragResize = getChildByName("dragResize");
			if (dragTarget) {
				dragArea = dragTarget.x + "," + dragTarget.y + "," + dragTarget.width + "," + dragTarget.height;
				if(!isAirWindow){
					removeElement(dragTarget);
				}else{
					dragTarget.alpha = 0;
				}
			}
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected override function onMouseDown(e:MouseEvent):void {
			if (_dragArea.contains(mouseX, mouseY)) {
				App.drag.doDrag(this,null,null,null,isAirWindow);
			}
			if (dragTarget && e.target == dragTarget && isAirWindow) {
				if(App.stage["nativeWindow"])App.stage["nativeWindow"].startMove();
			}
			if (dragResize && e.target == dragResize) {
				if(App.stage["nativeWindow"])App.stage["nativeWindow"].startResize();
			}
		}
	}
}
