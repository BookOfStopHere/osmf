package net.digitalprimates.dash.mp4.descriptors
{
	import net.digitalprimates.dash.valueObjects.BitStream;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class AudioSpecificInfo extends Descriptor
	{
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function AudioSpecificInfo(data:BitStream = null) {
			super(data);
		}
	}
}
