package com.bulkLoader.loadingTypes
{
    import com.bulkLoader.BulkLoader;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.ProgressEvent;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.net.URLRequest;
    import flash.utils.getTimer;

    public class VideoItem extends LoadingItem 
    {

        private var nc:NetConnection;
        public var stream:NetStream;
        public var dummyEventTrigger:Sprite;
        public var _checkPolicyFile:Boolean;
        public var pausedAtStart:Boolean = false;
        public var _metaData:Object;
        public var _canBeginStreaming:Boolean = false;

        public function VideoItem(_arg1:URLRequest, _arg2:String, _arg3:String)
        {
            specificAvailableProps = [BulkLoader.CHECK_POLICY_FILE, BulkLoader.PAUSED_AT_START];
            super(_arg1, _arg2, _arg3);
            _bytesTotal = (_bytesLoaded = 0);
        }

        override public function parseOptions(_arg1:Object):Array
        {
            this.pausedAtStart = ((_arg1[BulkLoader.PAUSED_AT_START]) || (false));
            this._checkPolicyFile = ((_arg1[BulkLoader.CHECK_POLICY_FILE]) || (false));
            return (super.parseOptions(_arg1));
        }

        override public function load():void
        {
            super.load();
            this.nc = new NetConnection();
            this.nc.connect(null);
            this.stream = new NetStream(this.nc);
            this.stream.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
            this.stream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatus, false, 0, true);
            this.dummyEventTrigger = new Sprite();
            this.dummyEventTrigger.addEventListener(Event.ENTER_FRAME, this.createNetStreamEvent, false, 0, true);
            var customClient:Object = new Object();
            customClient.onCuePoint = function (... _args):void
            {
            };
            customClient.onMetaData = this.onVideoMetadata;
            customClient.onPlayStatus = function (... _args):void
            {
            };
            this.stream.client = customClient;
            try
            {
                this.stream.play(url.url, this._checkPolicyFile);
            }
            catch(e:SecurityError)
            {
                onSecurityErrorHandler(createErrorEvent(e));
            };
            this.stream.seek(0);
        }

        public function createNetStreamEvent(_arg1:Event):void
        {
            var _local2:Event;
            var _local3:Event;
            var _local4:ProgressEvent;
            var _local5:int;
            var _local6:Number;
            var _local7:Number;
            var _local8:Number;
            if ((((_bytesTotal == _bytesLoaded)) && ((_bytesTotal > 8))))
            {
                if (this.dummyEventTrigger)
                {
                    this.dummyEventTrigger.removeEventListener(Event.ENTER_FRAME, this.createNetStreamEvent, false);
                };
                this.fireCanBeginStreamingEvent();
                _local2 = new Event(Event.COMPLETE);
                this.onCompleteHandler(_local2);
            }
            else
            {
                if ((((((_bytesTotal == 0)) && (this.stream))) && ((this.stream.bytesTotal > 4))))
                {
                    _local3 = new Event(Event.OPEN);
                    this.onStartedHandler(_local3);
                    _bytesLoaded = this.stream.bytesLoaded;
                    _bytesTotal = this.stream.bytesTotal;
                }
                else
                {
                    if (this.stream)
                    {
                        _local4 = new ProgressEvent(ProgressEvent.PROGRESS, false, false, this.stream.bytesLoaded, this.stream.bytesTotal);
                        if (((((this.isVideo()) && (this.metaData))) && (!(this._canBeginStreaming))))
                        {
                            _local5 = (getTimer() - responseTime);
                            if (_local5 > 100)
                            {
                                _local6 = (bytesLoaded / (_local5 / 1000));
                                _bytesRemaining = (_bytesTotal - bytesLoaded);
                                _local7 = (_bytesRemaining / (_local6 * 0.8));
                                _local8 = (this.metaData.duration - this.stream.bufferLength);
                                if (_local8 > _local7)
                                {
                                    this.fireCanBeginStreamingEvent();
                                };
                            };
                        };
                        super.onProgressHandler(_local4);
                    };
                };
            };
        }

        override public function onCompleteHandler(_arg1:Event):void
        {
            _content = this.stream;
            super.onCompleteHandler(_arg1);
        }

        override public function onStartedHandler(_arg1:Event):void
        {
            _content = this.stream;
            if (((this.pausedAtStart) && (this.stream)))
            {
                this.stream.pause();
            };
            super.onStartedHandler(_arg1);
        }

        override public function stop():void
        {
            try
            {
                if (this.stream)
                {
                    this.stream.close();
                };
            }
            catch(e:Error)
            {
            };
            super.stop();
        }

        override public function cleanListeners():void
        {
            if (this.stream)
            {
                this.stream.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
                this.stream.removeEventListener(NetStatusEvent.NET_STATUS, this.onNetStatus, false);
            };
            if (this.dummyEventTrigger)
            {
                this.dummyEventTrigger.removeEventListener(Event.ENTER_FRAME, this.createNetStreamEvent, false);
                this.dummyEventTrigger = null;
            };
        }

        override public function isVideo():Boolean
        {
            return (true);
        }

        override public function isStreamable():Boolean
        {
            return (true);
        }

        override public function destroy():void
        {
            if (this.stream)
            {
            };
            this.stop();
            this.cleanListeners();
            this.stream = null;
            super.destroy();
        }

        private function onNetStatus(_arg1:NetStatusEvent):void
        {
            var _local2:Event;
            if (!this.stream)
            {
                return;
            };
            this.stream.removeEventListener(NetStatusEvent.NET_STATUS, this.onNetStatus, false);
            if (_arg1.info.code == "NetStream.Play.Start")
            {
                _content = this.stream;
                _local2 = new Event(Event.OPEN);
                this.onStartedHandler(_local2);
            }
            else
            {
                if (_arg1.info.code == "NetStream.Play.StreamNotFound")
                {
                    onErrorHandler(createErrorEvent(new Error(("[VideoItem] NetStream not found at " + this.url.url))));
                };
            };
        }

        private function onVideoMetadata(_arg1):void
        {
            this._metaData = _arg1;
        }

        public function get metaData():Object
        {
            return (this._metaData);
        }

        public function get checkPolicyFile():Object
        {
            return (this._checkPolicyFile);
        }

        private function fireCanBeginStreamingEvent():void
        {
            if (this._canBeginStreaming)
            {
                return;
            };
            this._canBeginStreaming = true;
            var _local1:Event = new Event(BulkLoader.CAN_BEGIN_PLAYING);
            dispatchEvent(_local1);
        }

        public function get canBeginStreaming():Boolean
        {
            return (this._canBeginStreaming);
        }


    }
}//package DBX_6498
