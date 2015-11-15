// vim: tabstop=4 shiftwidth=4

// Copyright (c) 2011 , Yang Bo All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.protobuf.fieldDescriptors {
	import com.netease.protobuf.ReadUtils;
	import com.netease.protobuf.RepeatedFieldDescriptor;
	import com.netease.protobuf.WireType;
	import com.netease.protobuf.WriteUtils;
	import com.netease.protobuf.WritingBuffer;
	
	import flash.utils.IDataInput;
	
	import iflash.method.typeAs;

	/**
	 * @private
	 */
	public final class RepeatedFieldDescriptor$TYPE_MESSAGE extends
			RepeatedFieldDescriptor {
		public var messageUnion:Object
		public function RepeatedFieldDescriptor$TYPE_MESSAGE(
				fullName:String, name:String, tag:uint, messageUnion:Object) {
			this.fullName = fullName
			this._name = name
			this.tag = tag
			this.messageUnion = messageUnion
		}
		override public function get nonPackedWireType():int {
			return WireType.LENGTH_DELIMITED
		}
		override public function get type():Class {
			return Array
		}
		override public function get elementType():Class {
			return (typeAs(messageUnion , Class)) || Class(messageUnion = messageUnion())
		}
		override public function readSingleField(input:IDataInput):* {
			return ReadUtils.read$TYPE_MESSAGE(input, new elementType)
		}
		override public function writeSingleField(output:WritingBuffer,
				value:*):void {
			WriteUtils.write$TYPE_MESSAGE(output, value)
		}
	}
}
