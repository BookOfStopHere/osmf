package net.digitalprimates.dash.mp4
{
	import net.digitalprimates.dash.mp4.descriptors.AudioSpecificInfo;
	import net.digitalprimates.dash.mp4.descriptors.DecoderConfigDescriptor;
	import net.digitalprimates.dash.mp4.descriptors.DecoderSpecificInfo;
	import net.digitalprimates.dash.mp4.descriptors.Descriptor;
	import net.digitalprimates.dash.mp4.descriptors.ESDescriptor;
	import net.digitalprimates.dash.mp4.descriptors.SLConfigDescriptor;
	import net.digitalprimates.dash.valueObjects.BitStream;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class BaseDescriptorFactory implements IDescriptorFactory
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function getInstance(data:BitStream, objectTypeIndication:uint = 0):Descriptor {
			var tag:uint = data.readUInt8();
			var descriptor:Descriptor;
			
			switch (tag) {
				case 3:
					descriptor = new ESDescriptor(data);
					break;
				
				case 4:
					descriptor = new DecoderConfigDescriptor(data);
					break;
				
				case 5:
					if (objectTypeIndication == 64) {
						descriptor = new DecoderSpecificInfo(data);
					}
					else if (objectTypeIndication == 40) {
						descriptor = new AudioSpecificInfo(data);
					}
					break;
				
				case 6:
					descriptor = new SLConfigDescriptor(data);
					break;
				
				case 0:
				default:
					descriptor = new Descriptor();
					break;
			}
			
			return descriptor;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function BaseDescriptorFactory() {
			super();
		}
	}
}