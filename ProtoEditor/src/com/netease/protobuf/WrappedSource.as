package com.netease.protobuf
{
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.utils.IDataInput;

	public class WrappedSource implements ISource
	{
		private var input:IDataInput
		private var temp:int;
		
		public function WrappedSource(input:IDataInput)
		{
			this.input = input
		}
		public function unread(value:int):void {
			if (temp) {
				throw new IOError("Cannot unread twice!")
			}
			temp = value
		}
		public function read():int {
			if (temp) {
				const result:int = temp
				temp = 0
				return result
			} else {
				try {
					return input.readByte()
				} catch (e: EOFError) {
				}
				return 0
			}
		}
	}
}