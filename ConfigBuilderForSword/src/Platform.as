package
{
	import com.netease.protobuf.BaseFieldDescriptor;
	import com.netease.protobuf.Message;
	import com.netease.protobuf.PrintSetting;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.LocalConnection;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.IDataOutput;
	import flash.utils.describeType;
	
	import morn.core.components.IconBoxBase;
	
	import tc.debug.DebugTextWin;
	import tc.debug.PreLoadManager;

	public class Platform
	{
		/**
		 * 不同平台的不兼容功能实现 
		 * 
		 */		
		public function Platform()
		{
		}
		
		public static function printEnum(output:IDataOutput, value:int, enumType:Class, allEnumValues:Dictionary):void
		{
			var enumValues:Array
			if (enumType in allEnumValues) {
				enumValues = allEnumValues[enumType]
			} else {
				const enumTypeDescription:XML = describeType(enumType)
				// Not enumTypeDescription.*.@name,
				// because haXe will replace all constants to variables, WTF!
				const xmlNames:XMLList = enumTypeDescription.*.@name
				enumValues = []
				for each(var name:String in xmlNames) {
					enumValues[enumType[name]] = name
				}
				allEnumValues[enumType] = enumValues
			}
			if (value in enumValues) {
				output.writeUTFBytes(enumValues[value])
			} else {
				throw new IOError(value + " is invalid for " +
					enumTypeDescription.@name)
			}
		}
		
		public static function printMessageFields(output:IDataOutput, message:Message, printSetting:PrintSetting, currentIndent:String = "", allMessageFields:Dictionary=null, tf:com.netease.protobuf.TextFormat=null):void 
		{
			var isFirst:Boolean = true
			const type:Class = Object(message).constructor
			var messageFields:XMLList
			if (type in allMessageFields) {
				// Fetch in cache
				messageFields = allMessageFields[type]
			} else {
				var description:XML = describeType(type)
				// Not description.constant,
				// because haXe will replace constant to variable, WTF!
				messageFields = description.*.
					(
						0 == String(@type).search(
							/^com.netease.protobuf.fieldDescriptors::(Repeated)?FieldDescriptor\$/) &&
						// Not extension
						BaseFieldDescriptor(type[@name]).name.search(/\//) == -1
					).@name
				allMessageFields[type] = messageFields
			}
			
			for each (var fieldDescriptorName:String in messageFields) {
				const fieldDescriptor:BaseFieldDescriptor =
					type[fieldDescriptorName]
				const shortName:String = fieldDescriptor.fullName.substring(
					fieldDescriptor.fullName.lastIndexOf('.') + 1)
				if (fieldDescriptor.type == Array) {
					const fieldValues:Array = message[fieldDescriptor.name]
					if (fieldValues) {
						for (var i:int = 0; i < fieldValues.length; i++) {
							if (isFirst) {
								isFirst = false
							} else {
								output.writeByte(printSetting.newLine)
							}
							output.writeUTFBytes(currentIndent)
							output.writeUTFBytes(shortName)
							com.netease.protobuf.TextFormat.printValue(output, fieldDescriptor, fieldValues[i],
								printSetting, currentIndent)
						}
					}
				} else {
					const m:Array = fieldDescriptor.name.match(/^(__)?(.)(.*)$/)
					m[0] = ""
					m[1] = "has"
					m[2] = m[2].toUpperCase()
					const hasField:String = m.join("")
					try {
						// optional and does not have that field.
						if (false === message[hasField]) {
							continue
						}
					} catch (e:ReferenceError) {
						// required
					}
					if (isFirst) {
						isFirst = false
					} else {
						output.writeByte(printSetting.newLine)
					}
					output.writeUTFBytes(currentIndent)
					output.writeUTFBytes(shortName)
					com.netease.protobuf.TextFormat.printValue(output, fieldDescriptor,
						message[fieldDescriptor.name], printSetting,
						currentIndent)
				}
			}
			for (var key:String in message) {
				var extension:BaseFieldDescriptor
				try {
					extension = BaseFieldDescriptor.getExtensionByName(key)
				} catch (e:ReferenceError) {
					if (key.search(/^[0-9]+$/) == 0) {
						// unknown field
						if (isFirst) {
							isFirst = false
						} else {
							output.writeByte(printSetting.newLine)
						}
						com.netease.protobuf.TextFormat.printUnknownField(output, uint(key), message[key],
							printSetting, currentIndent)
					} else {
						throw new IOError("Bad unknown field " + key)
					}
					continue
				}
				if (extension.type == Array) {
					const extensionFieldValues:Array = message[key]
					for (var j:int = 0; j < extensionFieldValues.length; j++) {
						if (isFirst) {
							isFirst = false
						} else {
							output.writeByte(printSetting.newLine)
						}
						output.writeUTFBytes(currentIndent)
						output.writeUTFBytes("[")
						output.writeUTFBytes(extension.fullName)
						output.writeUTFBytes("]")
						com.netease.protobuf.TextFormat.printValue(output, extension,
							extensionFieldValues[j], printSetting,
							currentIndent)
					}
				} else {
					if (isFirst) {
						isFirst = false
					} else {
						output.writeByte(printSetting.newLine)
					}
					output.writeUTFBytes(currentIndent)
					output.writeUTFBytes("[")
					output.writeUTFBytes(extension.fullName)
					output.writeUTFBytes("]")
					com.netease.protobuf.TextFormat.printValue(output, extension, message[key], printSetting,
						currentIndent)
				}
			}
		}
		
		
		public static function createCdCache():void
		{
			//IconBoxBase.createCdCache();
		}
		
		public static function copyChannel(bmd:BitmapData, W:Number, H:Number):void
		{
			bmd.copyChannel(bmd, new Rectangle(0,0,W,H), new Point(0,0), BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
			bmd.copyChannel(bmd, new Rectangle(0,0,W,H), new Point(0,0), BitmapDataChannel.RED, BitmapDataChannel.BLUE);
		}
		
		public static function setPixel32(bmd:BitmapData, x:int, y:int, color:uint):void
		{
			bmd.setPixel32(x, y, color);
		}
		
		public static function getPixel32(bmd:BitmapData, x:int, y:int):uint
		{
			return bmd.getPixel32(x,y);
		}
		
		public static function applyFilter(filterBmd:BitmapData,sourceBMD:BitmapData, sourceRect:Rectangle, _drawPoint:Point, filter:BitmapFilter):void
		{
			filterBmd.applyFilter(sourceBMD, sourceRect, _drawPoint, filter);
		}
		
		public function parseCSS(cssText:String):void
		{
			
		}
		
		public static function garbageCollect():void
		{
			var hlcp:LocalConnection;
			var hlcs:LocalConnection;
			try
			{
				hlcp = new LocalConnection();
				hlcs = new LocalConnection();
				hlcp.connect("name");
				hlcs.connect("name");
			}
			catch(e:Error)
			{
				System.gc();
				System.gc();
			}
		}
		
		public static function saveTxtFile(file:FileReference, data:String, fileName):void
		{
			file.save(data, fileName)
		}
	}
}