package net.digitalprimates.dash.mp4.descriptors
{
	import net.digitalprimates.dash.valueObjects.BitStream;
	
	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class SLConfigDescriptor extends Descriptor
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var predefined:int;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			super.parse();
			predefined = bitStream.readUInt8();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function SLConfigDescriptor(data:BitStream = null) {
			super(data);
		}
	}
}
