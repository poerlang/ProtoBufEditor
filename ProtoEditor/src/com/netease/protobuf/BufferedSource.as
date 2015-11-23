package com.netease.protobuf
{
	import flash.utils.ByteArray;
	
	public class BufferedSource extends ByteArray implements ISource 
	{
		public function BufferedSource()
		{
			super();
		}
		
		public function unread(value:int):void {
			if (value == 0 && bytesAvailable == 0) {
				return
			}
			position--
		}
		public function read():int {
			if (bytesAvailable > 0) {
				return readByte()
			} else {
				return 0
			}
		}
	}
}