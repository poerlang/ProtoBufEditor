package com.bulkLoader.loadingTypes
{
    import com.bulkLoader.BulkLoader;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.media.Sound;
    import flash.net.URLRequest;

    public class SoundItem extends LoadingItem 
    {

        public var loader:Sound;

        public function SoundItem(_arg1:URLRequest, _arg2:String, _arg3:String)
        {
            specificAvailableProps = [BulkLoader.CONTEXT];
            super(_arg1, _arg2, _arg3);
        }

        override public function parseOptions(_arg1:Object):Array
        {
            _context = ((_arg1[BulkLoader.CONTEXT]) || (null));
            return (super.parseOptions(_arg1));
        }

        override public function load():void
        {
            super.load();
            this.loader = new Sound();
            this.loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
            this.loader.addEventListener(Event.COMPLETE, this.onCompleteHandler, false, 0, true);
            this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.onErrorHandler, false, 0, true);
            this.loader.addEventListener(Event.OPEN, this.onStartedHandler, false, 0, true);
            this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityErrorHandler, false, 0, true);
            try
            {
                this.loader.load(url, _context);
            }
            catch(e:SecurityError)
            {
                onSecurityErrorHandler(createErrorEvent(e));
            };
        }

        override public function onStartedHandler(_arg1:Event):void
        {
            _content = this.loader;
            super.onStartedHandler(_arg1);
        }

        override public function onErrorHandler(_arg1:ErrorEvent):void
        {
            super.onErrorHandler(_arg1);
        }

        override public function onCompleteHandler(_arg1:Event):void
        {
            _content = this.loader;
            super.onCompleteHandler(_arg1);
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
                this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityErrorHandler, false);
            };
        }

        override public function isStreamable():Boolean
        {
            return (true);
        }

        override public function isSound():Boolean
        {
            return (true);
        }

        override public function destroy():void
        {
            this.cleanListeners();
            this.stop();
            _content = null;
            this.loader = null;
        }


    }
}//package DBX_6498
