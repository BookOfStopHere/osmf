package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class EsdsBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _es:ESDescriptor;

		public function get es():ESDescriptor {
			return _es;
		}

		public function set es(value:ESDescriptor):void {
			_es = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			readFullBox(bitStream, this);
			es = new ESDescriptor(data);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function EsdsBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_ESDS, data);
		}
	}
}
