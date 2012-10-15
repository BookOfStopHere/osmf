package net.digitalprimates.dash.mp4.descriptors
{
	import flash.utils.ByteArray;
	
	import net.digitalprimates.dash.mp4.BaseDescriptorFactory;
	import net.digitalprimates.dash.mp4.IDescriptorFactory;
	import net.digitalprimates.dash.valueObjects.BitStream;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class Descriptor
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------

		protected var sizeOfInstance:int;
		protected var sizeBytes:int;

		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var tag:uint;
		public var type:String;
		
		private var _data:BitStream;
		
		protected function get bitStream():BitStream {
			return _data;
		}
		
		public function set data(value:BitStream):void {
			if (_data == value)
				return;
			
			_data = value;
			parse();
		}
		
		public function get size():int {
			return sizeOfInstance + 1 + sizeBytes;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		private var _descriptorFactory:IDescriptorFactory;

		protected function get descriptorFactory():IDescriptorFactory {
			if (!_descriptorFactory) {
				_descriptorFactory = new BaseDescriptorFactory();
			}

			return _descriptorFactory;
		}

		protected function parseChildrenDescriptors(objectTypeIndication:uint = 0):void {
			var descriptor:Descriptor;
			while (bitStream.bytesAvailable > 2) {
				descriptor = descriptorFactory.getInstance(bitStream, objectTypeIndication);
				setChildDescriptor(descriptor);
			}
		}

		protected function setChildDescriptor(descriptor:Descriptor):void {
			
		}

		protected function parse():void {
			if (bitStream && bitStream.bytesAvailable > 0) {
				var i:int = 0;
				var tmp:int = bitStream.readUInt8();
				i++;
				sizeOfInstance = tmp & 0x7f;
				while (tmp >>> 7 == 1) {
					tmp = bitStream.readUInt8();
					i++;
					sizeOfInstance = sizeOfInstance << 7 | tmp & 0x7f;
				}
				sizeBytes = i;
				
				// We only want to continue parsing our data.
				// Slice off the portion that we care about.
				var localData:ByteArray = new ByteArray();
				bitStream.readBytes(localData, 0, sizeOfInstance);
				
				_data = new BitStream(localData);
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Descriptor(data:BitStream = null) {
			this.data = data;
		}
	}
}
