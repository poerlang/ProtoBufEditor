package com.netease.protobuf
{
	public class PrintSetting
	{
		public var newLine:uint
		public var indentChars:String
		public var simpleFieldSeperator:String
		
		public function PrintSetting($newLine:uint, $indentChars:String, $simpleFieldSeperator:String)
		{
			newLine = $newLine;
			indentChars = $indentChars;
			simpleFieldSeperator = $simpleFieldSeperator;
		}
	}
}