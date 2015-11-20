package com.bulkLoader.loadingTypes
{
	import com.bulkLoader.BulkLoader;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/** @private */
	public class BinaryItem extends LoadingItem {
		public var loader : URLLoader;
		
		public function BinaryItem(url : URLRequest, type : String, uid : String){
			super(url, type, uid);
		}
		
		override public function parseOptions(props : Object)  : Array{
			return super.parseOptions(props);
		}
		
		override public function load() : void{
			super.load();
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
			loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHttpStatusHandler, false, 0, true);
			loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityErrorHandler, false, 0, true);
			try{
				// TODO: test for security error thown.
				loader.load(url);
			}catch( e : SecurityError){
				onSecurityErrorHandler(createErrorEvent(e));
				
			}
		};
		
		override public function onErrorHandler(evt : ErrorEvent) : void {
			super.onErrorHandler(evt);
		}
		
		override public function onStartedHandler(evt : Event) : void{
			super.onStartedHandler(evt);
		};
		
		override public function onCompleteHandler(evt : Event) : void {
			// _content = new ByteArray(loader.data);
			_content = evt.target.data;
			super.onCompleteHandler(evt);
		};
		
		override public function stop() : void{
			try{
				if(loader){
					loader.close();
				}
			}catch(e : Error){
				
			}
			super.stop();
		};
		
		override public function cleanListeners() : void {
			if(loader){
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler, false);
				loader.removeEventListener(Event.COMPLETE, onCompleteHandler, false);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
				loader.removeEventListener(BulkLoader.OPEN, onStartedHandler, false);
				loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHttpStatusHandler, false);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityErrorHandler, false);
			}
		}
		
		override public function destroy() : void{
			stop();
			cleanListeners();
			_content = null;
			loader = null;
		}   
	}	
}