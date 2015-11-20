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
    import flash.net.URLRequest;

    public class XMLItem extends LoadingItem 
    {

        public var loader:URLLoader;

        public function XMLItem(_arg1:URLRequest, _arg2:String, _arg3:String)
        {
            super(_arg1, _arg2, _arg3);
        }

        override public function parseOptions(_arg1:Object):Array
        {
            return (super.parseOptions(_arg1));
        }

        override public function load():void
        {
            super.load();
            this.loader = new URLLoader();
            this.loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
            this.loader.addEventListener(Event.COMPLETE, this.onCompleteHandler, false, 0, true);
            this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.onErrorHandler, false, 0, true);
            this.loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHttpStatusHandler, false, 0, true);
            this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityErrorHandler, false, 0, true);
            this.loader.addEventListener(Event.OPEN, this.onStartedHandler, false, 0, true);
            try
            {
                this.loader.load(url);
            }
            catch(e:SecurityError)
            {
                onSecurityErrorHandler(createErrorEvent(e));
            };
        }

        override public function onErrorHandler(_arg1:ErrorEvent):void
        {
            super.onErrorHandler(_arg1);
        }

        override public function onStartedHandler(_arg1:Event):void
        {
            super.onStartedHandler(_arg1);
        }

        override public function onCompleteHandler(evt:Event):void
        {
            try
            {
                _content = new XML(this.loader.data);
            }
            catch(e:Error)
            {
                _content = null;
                status = STATUS_ERROR;
                dispatchEvent(createErrorEvent(e));
            };
            super.onCompleteHandler(evt);
        }

        override public function stop():void
        {
            try
            {
                if (this.loader)
                {
                    this.loader.close();
                };
            }
            catch(e:Error)
            {
            };
            super.stop();
        }

        override public function cleanListeners():void
        {
            if (this.loader)
            {
                this.loader.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler, false);
                this.loader.removeEventListener(Event.COMPLETE, this.onCompleteHandler, false);
                this.loader.removeEventListener(IOErrorEvent.IO_ERROR, this.onErrorHandler, false);
                this.loader.removeEventListener(BulkLoader.OPEN, this.onStartedHandler, false);
                this.loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHttpStatusHandler, false);
                this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityErrorHandler, false);
            };
        }

        override public function isText():Boolean
        {
            return (true);
        }

        override public function destroy():void
        {
            this.stop();
            this.cleanListeners();
            _content = null;
            this.loader = null;
        }


    }
}//package DBX_6498
