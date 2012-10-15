package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class FtypBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var majorBrand:String;
		public var minorBrand:uint;
		public var compatibleBrands:Vector.<String>;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			majorBrand = bitStream.readUTFBytes(4);
			minorBrand = bitStream.readUInt32();
			
			var count:int = (size - SIZE_AND_TYPE_LENGTH - 8)/4;
			compatibleBrands = new Vector.<String>();
			for (var i:int = 0; i < count; i++) {
				compatibleBrands.push(bitStream.readUTFBytes(4));
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function FtypBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_FTYP, data);
		}
	}
}
