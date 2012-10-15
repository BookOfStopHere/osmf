package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;
	
	import net.digitalprimates.dash.mp4.descriptors.Descriptor;
	import net.digitalprimates.dash.mp4.descriptors.ESDescriptor;

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

		public var es:ESDescriptor;

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

		public function EsdsBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_ESDS, data);
		}
	}
}
