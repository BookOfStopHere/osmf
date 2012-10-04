package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	import net.digitalprimates.dash.utils.BaseDescriptorFactory;

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
			parseVersionAndFlags();
			
			var descriptor:Descriptor = descriptorFactory.getInstance(bitStream);
			if (descriptor is ESDescriptor) {
				es = (descriptor as ESDescriptor)
			}
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
