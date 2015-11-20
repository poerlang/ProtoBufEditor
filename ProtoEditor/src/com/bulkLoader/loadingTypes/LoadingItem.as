package com.bulkLoader.loadingTypes
{
    import com.bulkLoader.BulkLoader;
    import com.bulkLoader.utils.SmartURL;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.net.URLRequest;
    import flash.utils.getTimer;

    public class LoadingItem extends EventDispatcher 
    {

        public static const STATUS_STOPPED:String = "stopped";
        public static const STATUS_STARTED:String = "started";
        public static const STATUS_FINISHED:String = "finished";
        public static const STATUS_ERROR:String = "error";

        public var _type:String;
        public var url:URLRequest;
        public var _id:String;
        public var _uid:String;
        public var _additionIndex:int;
        public var _priority:int = 0;
        public var _isLoaded:Boolean;
        public var _isLoading:Boolean;
        public var status:String;
        public var maxTries:int = 3;
        public var numTries:int = 0;
        public var weight:int = 1;
        public var preventCache:Boolean;
        public var _bytesTotal:int = -1;
        public var _bytesLoaded:int = 0;
        public var _bytesRemaining:int = 10000000;
        public var _percentLoaded:Number;
        public var _weightPercentLoaded:Number;
        public var _addedTime:int;
        public var _startTime:int;
        public var _responseTime:Number;
        public var _latency:Number;
        public var _totalTime:int;
        public var _timeToDownload:Number;
        public var _speed:Number;
		public var _content : *;
        public var _httpStatus:int = -1;
		public var _context : * = null;
        public var _parsedURL:SmartURL;
        public var specificAvailableProps:Array;
        public var propertyParsingErrors:Array;
        public var errorEvent:ErrorEvent;

        public function LoadingItem(_arg1:URLRequest, _arg2:String, _arg3:String)
        {
            this._type = _arg2;
            this.url = _arg1;
            this._parsedURL = new SmartURL(_arg1.url);
            if (!this.specificAvailableProps)
            {
                this.specificAvailableProps = [];
            };
            this._uid = _arg3;
        }

        public function parseOptions(props:Object):Array
        {
			preventCache = props[BulkLoader.PREVENT_CACHING];
			_id = props[BulkLoader.ID];
			_priority = int(props[BulkLoader.PRIORITY]) || 0;
			maxTries = props[BulkLoader.MAX_TRIES] || 3;
			weight = int(props[BulkLoader.WEIGHT]) || 1;
			
			// checks that we are not adding any inexistent props, aka, typos on props :
			var allowedProps : Array = BulkLoader.GENERAL_AVAILABLE_PROPS.concat(specificAvailableProps);
			propertyParsingErrors = [];
			for (var propName :String in props){
				
				if (allowedProps.indexOf(propName) == -1){
					propertyParsingErrors.push(this + ": got a wrong property name: " + propName + ", with value:" + props[propName]);
				}
			}
			return propertyParsingErrors;
        }

        public function get content():*
        {
            return (this._content);
        }

        public function load():void
        {
            var _local1:String;
            if (this.preventCache)
            {
                _local1 = ((("BulkLoaderNoCache=" + this._uid) + "_") + int(((Math.random() * 100) * getTimer())));
                if (this.url.url.indexOf("?") == -1)
                {
                    this.url.url = (this.url.url + ("?" + _local1));
                }
                else
                {
                    this.url.url = (this.url.url + ("&" + _local1));
                };
            };
            this._isLoading = true;
            this._startTime = getTimer();
        }

        public function onHttpStatusHandler(_arg1:HTTPStatusEvent):void
        {
            this._httpStatus = _arg1.status;
            dispatchEvent(_arg1);
        }

        public function onProgressHandler(_arg1):void
        {
            this._bytesLoaded = _arg1.bytesLoaded;
            this._bytesTotal = _arg1.bytesTotal;
            this._bytesRemaining = (this._bytesTotal - this.bytesLoaded);
            this._percentLoaded = (this._bytesLoaded / this._bytesTotal);
            this._weightPercentLoaded = (this._percentLoaded * this.weight);
            dispatchEvent(_arg1);
        }

        public function onCompleteHandler(_arg1:Event):void
        {
            this._totalTime = getTimer();
            this._timeToDownload = ((this._totalTime - this._responseTime) / 1000);
            if (this._timeToDownload == 0)
            {
                this._timeToDownload = 0.1;
            };
            this._speed = BulkLoader.truncateNumber(((this.bytesTotal / 0x0400) / this._timeToDownload));
            this.status = STATUS_FINISHED;
            this._isLoaded = true;
            dispatchEvent(_arg1);
            _arg1.stopPropagation();
        }

        public function onErrorHandler(_arg1:ErrorEvent):void
        {
            this.numTries++;
            _arg1.stopPropagation();
            if (this.numTries < this.maxTries)
            {
                this.status = null;
                this.load();
            }
            else
            {
                this.status = STATUS_ERROR;
                this.errorEvent = _arg1;
                this.dispatchErrorEvent(this.errorEvent);
            };
        }

        public function dispatchErrorEvent(e:ErrorEvent):void
        {
            this.status = STATUS_ERROR;
            dispatchEvent(new ErrorEvent(BulkLoader.ERROR, true, false, e.text));
        }

        public function createErrorEvent(_arg1:Error):ErrorEvent
        {
            return (new ErrorEvent(BulkLoader.ERROR, false, false, _arg1.message));
        }

        public function onSecurityErrorHandler(_arg1:ErrorEvent):void
        {
            this.status = STATUS_ERROR;
            this.errorEvent = (_arg1 as ErrorEvent);
            _arg1.stopPropagation();
            this.dispatchErrorEvent(this.errorEvent);
        }

        public function onStartedHandler(_arg1:Event):void
        {
            this._responseTime = getTimer();
            this._latency = BulkLoader.truncateNumber(((this._responseTime - this._startTime) / 1000));
            this.status = STATUS_STARTED;
            dispatchEvent(_arg1);
        }

        override public function toString():String
        {
            return (((((("LoadingItem url: " + this.url.url) + ", type:") + this._type) + ", status: ") + this.status));
        }

        public function stop():void
        {
            if (this._isLoaded)
            {
                return;
            };
            this.status = STATUS_STOPPED;
            this._isLoading = false;
        }

        public function cleanListeners():void
        {
        }

        public function isVideo():Boolean
        {
            return (false);
        }

        public function isSound():Boolean
        {
            return (false);
        }

        public function isText():Boolean
        {
            return (false);
        }

        public function isXML():Boolean
        {
            return (false);
        }

        public function isImage():Boolean
        {
            return (false);
        }

        public function isSWF():Boolean
        {
            return (false);
        }

        public function isLoader():Boolean
        {
            return (false);
        }

        public function isStreamable():Boolean
        {
            return (false);
        }

        public function destroy():void
        {
            this._content = null;
        }

        public function get bytesTotal():int
        {
            return (this._bytesTotal);
        }

        public function get bytesLoaded():int
        {
            return (this._bytesLoaded);
        }

        public function get bytesRemaining():int
        {
            return (this._bytesRemaining);
        }

        public function get percentLoaded():Number
        {
            return (this._percentLoaded);
        }

        public function get weightPercentLoaded():Number
        {
            return (this._weightPercentLoaded);
        }

        public function get priority():int
        {
            return (this._priority);
        }

        public function get type():String
        {
            return (this._type);
        }

        public function get isLoaded():Boolean
        {
            return (this._isLoaded);
        }

        public function get addedTime():int
        {
            return (this._addedTime);
        }

        public function get startTime():int
        {
            return (this._startTime);
        }

        public function get responseTime():Number
        {
            return (this._responseTime);
        }

        public function get latency():Number
        {
            return (this._latency);
        }

        public function get totalTime():int
        {
            return (this._totalTime);
        }

        public function get timeToDownload():int
        {
            return (this._timeToDownload);
        }

        public function get speed():Number
        {
            return (this._speed);
        }

        public function get httpStatus():int
        {
            return (this._httpStatus);
        }

        public function get id():String
        {
            return (this._id);
        }

        public function get hostName():String
        {
            return (this._parsedURL.host);
        }

        public function get humanFiriendlySize():String
        {
            var _local1:Number = (this._bytesTotal / 0x0400);
            if (_local1 < 0x0400)
            {
                return ((int(_local1) + " kb"));
            };
            return (((_local1 / 0x0400).toPrecision(3) + " mb"));
        }

        public function getStats():String
        {
            return (((((((((((("Item url: " + this.url.url) + "(s), total time: ") + (this._totalTime / 1000).toPrecision(3)) + "(s), download time: ") + this._timeToDownload.toPrecision(3)) + "(s), latency:") + this._latency) + "(s), speed: ") + this._speed) + " kb/s, size: ") + this.humanFiriendlySize));
        }


    }
}//package DBX_6498
