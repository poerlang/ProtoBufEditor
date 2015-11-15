package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	[SWF(width="1322",height="900")]
	public class ConfigBuilderForSword extends Sprite
	{
		public function ConfigBuilderForSword()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var ins:ProtoEditor = ProtoEditor.ins;
			addChild(ins);
			new Alert(this.stage);
			new AlertInput(this.stage);
		}
	}
}