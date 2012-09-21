package net.digitalprimates.dash.valueObjects
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

		private var _majorBrand:String;

		public function get majorBrand():String {
			return _majorBrand;
		}

		public function set majorBrand(value:String):void {
			_majorBrand = value;
		}

		private var _minorBrand:uint;

		public function get minorBrand():uint {
			return _minorBrand;
		}

		public function set minorBrand(value:uint):void {
			_minorBrand = value;
		}

		private var _compatibleBrands:Vector.<String>;

		public function get compatibleBrands():Vector.<String> {
			return _compatibleBrands;
		}

		public function set compatibleBrands(value:Vector.<String>):void {
			_compatibleBrands = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			majorBrand = data.readUTFBytes(4);
			minorBrand = data.readUnsignedInt();
			
			compatibleBrands = new Vector.<String>();
			while (data.bytesAvailable > 0) {
				compatibleBrands.push(data.readUTFBytes(4));
			}

			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function FtypBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_FTYP, data);
		}
	}
}
