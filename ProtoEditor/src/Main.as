package
{
	import com.bulkLoader.BulkLoader;
	import com.bulkLoader.BulkProgressEvent;
	import com.netease.protobuf.Message;
	import com.netease.protobuf.WireType;
	import com.netease.protobuf.WriteUtils;
	import com.netease.protobuf.WritingBuffer;
	import com.netease.protobuf.fieldDescriptors.FieldDescriptor$TYPE_INT32;
	import com.netease.protobuf.fieldDescriptors.FieldDescriptor$TYPE_MESSAGE;
	import com.netease.protobuf.fieldDescriptors.FieldDescriptor$TYPE_STRING;
	import com.netease.protobuf.fieldDescriptors.RepeatedFieldDescriptor$TYPE_MESSAGE;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.utils.ByteArray;
	
	import parser.Script;

	[SWF(width="1372",height="900")]
	public class Main extends Sprite
	{
		private var loader:BulkLoader;

		private var classTxtUrls:Array;
		public static var ins:Main;
		public function Main()
		{
			ins = this;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var pe:ProtoEditor = ProtoEditor.ins;
			addChild(pe);
			new Alert(this.stage);
			new AlertInput(this.stage);
			
			Script.init(this, "class global{}");
			loader = new BulkLoader("main");
			loader.addEventListener(BulkProgressEvent.COMPLETE,onOK);
		}
		private function fix(code:String):String
		{
			var reg:* = [FieldDescriptor$TYPE_INT32,RepeatedFieldDescriptor$TYPE_MESSAGE,FieldDescriptor$TYPE_MESSAGE,FieldDescriptor$TYPE_STRING,Message,WireType,WriteUtils,WritingBuffer];
			var tmp:String = "import com.netease.protobuf.Message;\n";
			tmp += "import com.netease.protobuf.WireType;\n";
			tmp += "import com.netease.protobuf.WriteUtils;\n";
			tmp += "import com.netease.protobuf.WritingBuffer;\n";
			tmp += "import com.netease.protobuf.fieldDescriptors.FieldDescriptor$TYPE_INT32;\n";
			tmp += "import com.netease.protobuf.fieldDescriptors.FieldDescriptor$TYPE_STRING;\n";
			tmp += "import com.netease.protobuf.fieldDescriptors.RepeatedFieldDescriptor$TYPE_MESSAGE;\n";
			tmp += "import com.netease.protobuf.fieldDescriptors.FieldDescriptor$TYPE_MESSAGE;\n";
			tmp += "import flash.utils.ByteArray;\n";
			tmp += "\n";
			code=code.replace("import com.netease.protobuf.*;","");
			code=code.replace("import com.netease.protobuf.fieldDescriptors.*;",tmp);
			code=code.replace(/use namespace com.netease.protobuf.used_by_generated_code;/g,"");
			code=code.replace(/override public final function/g,"function");
			code=code.replace(/override com.netease.protobuf.used_by_generated_code final function/g,"function");
			code=code.replace(/com.netease.protobuf.used_by_generated_code /g,"");
			code=code.replace(/dynamic /g,"");
			code=code.replace(/\[ArrayElementType(.*)]/g,"");
			code=code.replace(/final /g,"");
			code=code.replace(/public var arr:proto\.(.*);/g,"public var arr:Array=new Array();");
			code=code.replace(/static /g,"");
			code=code.replace(/const /g,"var ");
			code=code.replace(/override /g,"var ");
			code=code.replace("for (var fieldKey:* in this) {","if(false){");
			code=code.replace(/super.writeUnknown(output, fieldKey);/g,";");
			code=code.replace(/extends com.netease.protobuf.Message/,"extends Message");
			code=code.replace(/output:com.netease.protobuf.WritingBuffer/g,"output:WritingBuffer");
			code=code.replace(/input:flash.utils.IDataInput/g,"input:IDataInput");
			code=code.replace(/com.netease.protobuf.WireType\./g,"WireType.");
			code=code.replace(/com.netease.protobuf.WriteUtils\./g,"WriteUtils.");
			code=code.replace(/com.netease.protobuf.ReadUtils\./g,"ReadUtils.");
			code=code.replace(/:flash.utils.ByteArray/g,":ByteArray");
			return code;
		}

		private var onComplete:Function;
		static public function write(msg:*):ByteArray
		{
			var w:WritingBuffer = new WritingBuffer();
			var b:ByteArray = new ByteArray();
			msg.writeToBuffer(w);
			w.toNormal(b);
			b.position = 0;
			return b;
		}
		protected function onOK(e:BulkProgressEvent):void
		{
			for (var i:int = 0; i < classTxtUrls.length; i++){
				var url:String = classTxtUrls[i];
				var txt:String = loader.getText(url);
				txt = fix(txt);
				Script.LoadFromString(txt);
				//var playerinfo:*=Script.New("PlayerInfo");
				//var b:ByteArray = write(playerinfo);
			}
			if(onComplete) onComplete();
		}
		public function loadClassTxts(_arr:Array,_onComplete:Function):void{
			onComplete = _onComplete;
			this.classTxtUrls = _arr;
			for (var i:int = 0; i < classTxtUrls.length; i++){
				loader.add(classTxtUrls[i]);
			}
			loader.start();
		}
	}
}