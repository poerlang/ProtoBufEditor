package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class ProtoParser extends EventDispatcher
	{
		public static var PARSE_COMPLETE:String="PARSE_COMPLETE";
		protected static const MORE_TO_PARSE:Boolean=false;
		protected static const PARSING_DONE:Boolean=true;
		private static const COMMENT_TOKEN:String="//";
		private static const COMMENT_TOKEN2:String="/*";
		private static const T_ENUM:String="enum";
		private static const T_MESSAGE:String="message";
		private static const T_PACKAGE:String="package";

		public static function getString(data:*, length:uint=0):String
		{
			var ba:ByteArray;

			length||=uint.MAX_VALUE;

			if (data is File)
			{
				data=FileUtil.File2String(data);
			}

			if (data is String)
				return String(data).substr(0, length);

			ba=toByteArray(data);
			if (ba)
			{
				ba.position=0;
				return ba.readUTFBytes(Math.min(ba.bytesAvailable, length));
			}

			return null;
		}

		public static function toByteArray(data:*):ByteArray
		{
			if (data is Class)
				data=new data();

			if (data is ByteArray)
				return data;
			else
				return null;
		}

		public function ProtoParser()
		{
		}

		protected var _data:*;
		protected var _frameLimit:Number;
		protected var _lastFrameTime:Number;
		private var _charLineIndex:int;
		private var _line:int;
		private var _parseIndex:int;
		private var _parsingComplete:Boolean;
		private var _parsingFailure:Boolean;
		private var _parsingPaused:Boolean;
		private var _reachedEOF:Boolean;
		private var _startedParsing:Boolean;
		private var _textData:String;
		private var _timer:Timer;
		private var _version:int;
		private var arrClass:Array=[];
		private var onComplete:Function;
		private var packageStr:String;
		private var lastComm:String="";

		public function go(data:*, onComplete:Function, frameLimit:Number=30):void
		{
			this.onComplete=onComplete;
			_data=data;
			startParsing(frameLimit);
		}

		protected function finishParsing():void
		{
			if (_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER, onInterval);
				_timer.stop();
			}
			_timer=null;
			_parsingComplete=true;
			dispatchEvent(new Event(PARSE_COMPLETE));
		}

		protected function getTextData():String
		{
			return getString(_data);
		}

		protected function hasTime():Boolean
		{
			return ((getTimer() - _lastFrameTime) < _frameLimit);
		}

		protected function onInterval(event:TimerEvent=null):void
		{
			_lastFrameTime=getTimer();
			if (proceedParsing() && !_parsingFailure)
				finishParsing();
		}

		protected function proceedParsing():Boolean
		{
			var token:String;

			if (!_startedParsing)
			{
				_textData=getTextData();
				_startedParsing=true;
			}

			while (hasTime())
			{
				token=getNextToken();
				switch (token)
				{
					case COMMENT_TOKEN:
						ignoreLine();
						break;
					case T_PACKAGE:
						packageStr=parsePackAge();
						break;
					case T_MESSAGE:
						parseMessage();
						break;
					case T_ENUM:
						parseEnum();
						break;
					default:
						if (!_reachedEOF){
							if(token.indexOf(COMMENT_TOKEN)>=0 || token.indexOf(COMMENT_TOKEN2)>=0 ){
								lastComm = token;
							}else{
								sendUnknownKeywordError(token);
							}
						}
				}

				if (_reachedEOF)
				{
					trace("完成");
					if (onComplete)
					{
						onComplete(arrClass);
					}
					return PARSING_DONE;
				}
			}
			return MORE_TO_PARSE;
		}

		protected function startParsing(frameLimit:Number):void
		{
			_frameLimit=frameLimit;
			_timer=new Timer(_frameLimit, 0);
			_timer.addEventListener(TimerEvent.TIMER, onInterval);
			_timer.start();
		}

		/**解析错误*/
		private function err(expected:String,token:String=""):void
		{
			throw new Error("发现语法错误,  第 " + (_line + 1) + " 行, 第 " + _charLineIndex + " 个字符.  本该是" + expected + ", 却解析到了 " + token +"  当前字符:  "+ _textData.charAt(_parseIndex - 1) + ".");
		}

		/**
		 * 下一个字符(自动跳过换行)
		 */
		private function getNextChar():String
		{
			var ch:String=_textData.charAt(_parseIndex++);

			if (ch == "\n")
			{
				++_line;
				_charLineIndex=0;
			}
			else if (ch != "\r")
				++_charLineIndex;

			if (_parseIndex >= _textData.length)
				_reachedEOF=true;

			return ch;
		}

		/**
		 * 下一个int
		 */
		private function getNextInt():int
		{
			var token:String = getNextToken();
			var i:Number=parseInt(token);
			if (isNaN(i))
				err("int type");
			return i;
		}

		/**
		 * 下一个Number(会自动跳过空白/换行/注释)
		 */
		private function getNextNumber():Number
		{
			var f:Number=parseFloat(getNextToken());
			if (isNaN(f))
				err("float type");
			return f;
		}

		/**
		 * 下一个词组
		 */
		private function getNextToken():String
		{
			var ch:String;
			var token:String="";

			while (!_reachedEOF)
			{
				ch=getNextChar();
				if (ch == " " || ch == "\r" || ch == "\n" || ch == "\t" || ch == ";")
				{
					if (token != COMMENT_TOKEN)
						skipWhiteSpace();
					if (token != "")
						return token;
				}
				else
					token+=ch;

				if (token == COMMENT_TOKEN)
					return token;
			}

			return token;
		}

		/**
		 * 跳过本行余下的字符串
		 */
		private function ignoreLine():void
		{
			var ch:String;
			while (!_reachedEOF && ch != "\n")
				ch=getNextChar();
		}

		private function parseFieldComment():String
		{
			var ch:String;
			var str:String="";
			do
			{
				ch=getNextChar();
				if (ch == "\n")
				{
					break;
				}
				str+=ch;

			} while (ch != "\n");
			return cleanComm(str);
		}
		
		private function cleanComm(str:String):String
		{
			return str.replace("*/", "").replace("/*", "").replace("//", "");
		}
		
		/**
		 * 解析双引号内的字符
		 */
		private function parseLiteralString():String
		{
			skipWhiteSpace();

			var ch:String=getNextChar();
			var str:String="";

			if (ch != "\"")
				err("\"");

			do
			{
				if (_reachedEOF)
					sendEOFError();
				ch=getNextChar();
				if (ch != "\"")
					str+=ch;
			} while (ch != "\"");

			return str;
		}
		
		private function parseEnum():void
		{
			var msg:ItemData=new ItemData();
			var ch:String;
			msg.type1="enum";
			msg.type2=getNextToken();
			msg.isTopType = true;
			parseMsgComm(msg);
			var arrLine:Array=[];
			msg.arr=arrLine;
			msg.isEnum = true;
			arrClass.push(msg);
			var token:String=getNextToken();
			if (token != "{")
				sendUnknownKeywordError(token);
			do
			{
				if (_reachedEOF)
					sendEOFError();
				var ob:ItemData=new ItemData();
				ob.isEnum = true;
				ob.name=getNextToken();
				ob.type1 = "";
				ob.type2 = "int32";
				getNextToken();//跳过=
				ob.num=getNextInt();
				arrLine.push(ob);
				ch=getNextChar();
				if (ch == "/")
				{
					putBack();
					var comm:String=parseFieldComment();
					var params:Array = parseParamInComment(comm);
					ob.comm=params[0];
					if(params[1].lenght==1)ob.type3 = params[1][0];
					ob.params = params[1];
					ch=getNextChar();
				}

				if (ch != "}")
					putBack();
			} while (ch != "}");
			trace("解析一个enum",msg.type2);			
		}
		
		private function parseParamInComment(comm:String):Array
		{
			var m:Array = comm.match(/\[(.*)]/);
			if(m && m.length>0){
				var len:int = String(m[0]).length;
				comm = comm.slice(0,m.index)+comm.slice(m.index+len);
				var param:Array = String(m[1]).split(",");
				return [comm,param];
			}
			return [comm,[]];
		}
		
		private function parseMessage():void
		{
			var msg:ItemData=new ItemData();
			var ch:String;
			parseMsgComm(msg);
			msg.type1="class";
			msg.type2=getNextToken();
			msg.isTopType = true;
			var arrLine:Array=[];
			msg.arr=arrLine;
			arrClass.push(msg);
			var token:String=getNextToken();
			if (token != "{")
				sendUnknownKeywordError(token);
			do
			{
				if (_reachedEOF)
					sendEOFError();
				var ob:ItemData=new ItemData();
				token=getNextToken();
				if (token == "extensions")
				{
					ignoreLine();
					continue;
				}
				if (token == "}")
				{
					break;
				}
				ob.type1=token;
				ob.type2=getNextToken();
				ob.name=getNextToken();
				getNextToken(); //跳过=号
				ob.num=getNextInt();
				arrLine.push(ob);


				ch=getNextChar();

				if (ch == "/")
				{
					putBack();
					var comm:String=parseFieldComment();
					var params:Array = parseParamInComment(comm);
					ob.comm=params[0];
					if(params[1].length==1)ob.type3 = params[1][0];
					ob.params=params[1];
					ch=getNextChar();
				}

				if (ch != "}")
					putBack();
			} while (ch != "}");
			trace("解析一个对象",msg.name);
		}
		
		private function parseMsgComm(msg:ItemData):void
		{
			if(lastComm!=""){
				var comm:String = cleanComm(lastComm);
				var param:Array = parseParamInComment(comm);
				msg.comm = param[0];
				msg.params = param[1];
				lastComm = "";
			}
		}
		
		private function parsePackAge():String
		{
			var ch:String;
			var str:String="";
			do
			{
				ch=getNextChar();
				if (ch == ";")
				{
					break;
				}
				str+=ch;

			} while (ch != ";");
			return str;
		}

		/**
		 * 把最近解析到的一个字符放回去.
		 */
		private function putBack():void
		{
			_parseIndex--;
			_charLineIndex--;
			_reachedEOF=_parseIndex >= _textData.length;
		}

		/**文件尾错误*/
		private function sendEOFError():void
		{
			throw new Error("意料之外的文件结尾");
		}

		/**不支持的关键字*/
		private function sendUnknownKeywordError(token:String):void
		{
			throw new Error("不支持的关键字 " + token + " , 第 " + (_line + 1) + " 行, 第 " + _charLineIndex + " 个字符. ");
		}

		/**
		 * 跳过空白字符(包括\n\r\t)
		 */
		private function skipWhiteSpace():void
		{
			var ch:String;

			do
				ch=getNextChar();
			while (ch == "\n" || ch == " " || ch == "\r" || ch == "\t");

			putBack();
		}
	}
}
