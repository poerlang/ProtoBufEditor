package net {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	/**
	 * 简化版Socket客户端，只收发字符串。配合SocketServer使用。使用方法：						<br>
	 *  var c = new SimpleSocketClient();													<br>
	 *		c.addEventListener(SimpleSocketMessageEvent.MESSAGE_RECEIVED, handle);			<br>
	 *		c.s.connect("127.0.0.1", 9999);												<br>
	 * 
	 * 		function handle(e:SimpleSocketMessageEvent):void {								<br>
	 *				trace("收到数据"e.message);										<br>
	 *		}																	<br>
	 */
	public class SimpleSocketClient extends EventDispatcher {
		protected var _message:String;
		public var s:Socket;
		public function SimpleSocketClient(warpSocket:Socket=null) {
			super();
			this._message = "";
			
			s = warpSocket ? warpSocket  :  new Socket();
			
			s.addEventListener(Event.CONNECT, socketConnected);
			s.addEventListener(Event.CLOSE, socketClosed);
			s.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
			s.addEventListener(IOErrorEvent.IO_ERROR, socketError);
			s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketError);
		}
		
		protected function socketData(event:ProgressEvent):void {
			//var str:String = s.readUTFBytes(s.bytesAvailable);
			while (s.bytesAvailable>0) {
				var r:int = s.readByte();
				trace(r);
			}
		}
		
		protected function notifyMessage(value:String):void {
			this.dispatchEvent(new SimpleSocketMessageEvent(SimpleSocketMessageEvent.MESSAGE_RECEIVED, value));
		}
		
		protected function socketConnected(event:Event):void {
			trace("【Clinet】Socket connected");
		}
		
		protected function socketClosed(event:Event):void {
			trace("【Clinet】Connection was closed");
			//TODO: Reconnect if needed
		}
		
		protected function socketError(event:Event):void {
			trace("【Clinet】An error occurred:", event);
		}
		
		public function close():void
		{
			if(s){
				s.close();
				s = null;
			}
		}
		
		public function send(b:ByteArray):void
		{
			b.position = 0;
			var bodyLen:uint = b.bytesAvailable;
//			s.writeUnsignedInt(bodyLen);
//			s.writeShort(bodyLen);
			s.writeBytes(b);
			s.flush();
		}
	}
}