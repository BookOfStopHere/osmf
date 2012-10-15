package net.digitalprimates.dash.mp4.descriptors
{
	import flash.utils.ByteArray;
	
	import net.digitalprimates.dash.valueObjects.BitStream;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DecoderSpecificInfo extends Descriptor
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var configData:ByteArray;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			super.parse();
			configData = new ByteArray();
			bitStream.readBytes(configData, 0, sizeOfInstance);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DecoderSpecificInfo(data:BitStream = null) {
			super(data);
		}
	}
}
