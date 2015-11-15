package com.netease.protobuf
{
	public interface ISource
	{
		function read():int
		function unread(b:int):void
	}
}