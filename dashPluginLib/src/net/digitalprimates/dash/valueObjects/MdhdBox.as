package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MdhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _creationTime:Number;

		public function get creationTime():Number {
			return _creationTime;
		}

		public function set creationTime(value:Number):void {
			_creationTime = value;
		}

		private var _modificationTime:Number;

		public function get modificattionTime():Number {
			return _modificationTime;
		}

		public function set modificationTime(value:Number):void {
			_modificationTime = value;
		}

		private var _timescale:int;

		public function get timescale():int {
			return _timescale;
		}

		public function set timescale(value:int):void {
			_timescale = value;
		}

		private var _duration:Number;

		public function get duration():Number {
			return _duration;
		}

		public function set duration(value:Number):void {
			_duration = value;
		}

		private var _language:String;

		public function get language():String {
			return _language;
		}

		public function set language(value:String):void {
			_language = value;
		}

		private var _reserved:uint;

		public function get reserved():uint {
			return _reserved;
		}

		public function set reserved(value:uint):void {
			_reserved = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			if (version == 1) {
				creationTime = bitStream.readUInt64();
				modificationTime = bitStream.readUInt64();
				timescale = bitStream.readUInt32();
				duration = bitStream.readUInt64();
			}
			else {
				creationTime = bitStream.readUInt32();
				modificationTime = bitStream.readUInt32();
				timescale = bitStream.readUInt32();
				duration = bitStream.readUInt32();
			}

			language = bitStream.readIso639();
			reserved = bitStream.readUInt16();
			
			bitStream.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MdhdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MDHD, data);
		}
	}
}
