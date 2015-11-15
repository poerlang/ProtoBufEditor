package
{
	import com.bit101.components.HBox;
	import com.bit101.components.Label;
	
	public class ProtoListFile extends HBox
	{
		public var ob:Object;
		public var item:Item;
		public function ProtoListFile(p,a_name:String,ob:ItemData)
		{
			super(p);
			this.ob = ob;
			new Label(this,0,0,a_name);
			bgColor = COLOR_NOM;
			item = new Item();
			item.ob = ob;
		}
	}
}