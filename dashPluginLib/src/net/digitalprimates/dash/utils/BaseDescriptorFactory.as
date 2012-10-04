package net.digitalprimates.dash.utils
{
	import net.digitalprimates.dash.valueObjects.AudioSpecificInfo;
	import net.digitalprimates.dash.valueObjects.BitStream;
	import net.digitalprimates.dash.valueObjects.DecoderConfigDescriptor;
	import net.digitalprimates.dash.valueObjects.DecoderSpecificInfo;
	import net.digitalprimates.dash.valueObjects.Descriptor;
	import net.digitalprimates.dash.valueObjects.ESDescriptor;
	import net.digitalprimates.dash.valueObjects.SLConfigDescriptor;

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
		
		public function getInstance(bs:BitStream, objectTypeIndication:uint = 0):Descriptor {
			var tag:uint = bs.readUInt8();
			
			switch (tag) {
				case 0:
					return new Descriptor(bs);
					break;
				
				case 3:
					return new ESDescriptor(bs);
					break;
				
				case 4:
					return new DecoderConfigDescriptor(bs);
					break;
				
				case 5:
					if (objectTypeIndication == 64) {
						return new DecoderSpecificInfo(bs);
					}
					else if (objectTypeIndication == 40) {
						return new AudioSpecificInfo(bs);
					}
					break;
				
				case 6:
					return new SLConfigDescriptor(bs);
					break;
				
				case 13:
					//return new ExtensionProfileLevelDescriptor();
					break;
				
				case 14:
					//return new ProfileLevelIndicationDescriptor();
					break;
			}
			
			return null;
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