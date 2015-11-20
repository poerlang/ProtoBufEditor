package proto {
	import com.netease.protobuf.*;
	use namespace com.netease.protobuf.used_by_generated_code;
	import com.netease.protobuf.fieldDescriptors.*;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.errors.IOError;
	import proto.Equip;
	// @@protoc_insertion_point(imports)

	// @@protoc_insertion_point(class_metadata)
	public dynamic final class EquipList extends com.netease.protobuf.Message {
		/**
		 *  @private
		 */
		public static const ARR:FieldDescriptor$TYPE_MESSAGE = new FieldDescriptor$TYPE_MESSAGE("proto.EquipList.arr", "arr", (1 << 3) | com.netease.protobuf.WireType.LENGTH_DELIMITED, function():Class { return proto.Equip; });

		public var arr:proto.Equip;

		/**
		 *  @private
		 */
		override com.netease.protobuf.used_by_generated_code final function writeToBuffer(output:com.netease.protobuf.WritingBuffer):void {
			com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.LENGTH_DELIMITED, 1);
			com.netease.protobuf.WriteUtils.write$TYPE_MESSAGE(output, this.arr);
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		/**
		 *  @private
		 */
		override com.netease.protobuf.used_by_generated_code final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var arr$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.netease.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (arr$count != 0) {
						throw new flash.errors.IOError('Bad data format: EquipList.arr cannot be set twice.');
					}
					++arr$count;
					this.arr = new proto.Equip();
					com.netease.protobuf.ReadUtils.read$TYPE_MESSAGE(input, this.arr);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
