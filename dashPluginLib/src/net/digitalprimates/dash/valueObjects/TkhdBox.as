package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TkhdBox extends BoxInfo
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

		public function get modificationTime():Number {
			return _modificationTime;
		}

		public function set modificationTime(value:Number):void {
			_modificationTime = value;
		}

		private var _trackID:int;

		public function get trackID():int {
			return _trackID;
		}

		public function set trackID(value:int):void {
			_trackID = value;
		}

		private var _reserved1:int;

		public function get reserved1():int {
			return _reserved1;
		}

		public function set reserved1(value:int):void {
			_reserved1 = value;
		}

		private var _duration:Number;

		public function get duration():Number {
			return _duration;
		}

		public function set duration(value:Number):void {
			_duration = value;
		}

		private var _reserved2:Array;

		public function get reserved2():Array {
			return _reserved2;
		}

		public function set reserved2(value:Array):void {
			_reserved2 = value;
		}

		private var _layer:uint;

		public function get layer():uint {
			return _layer;
		}

		public function set layer(value:uint):void {
			_layer = value;
		}

		private var _alternateGroup:uint;

		public function get alternateGroup():uint {
			return _alternateGroup;
		}

		public function set alternateGroup(value:uint):void {
			_alternateGroup = value;
		}

		private var _volume:uint;

		public function get volume():uint {
			return _volume;
		}

		public function set volume(value:uint):void {
			_volume = value;
		}

		private var _reserved3:uint;

		public function get reserved3():uint {
			return _reserved3;
		}

		public function set reserved3(value:uint):void {
			_reserved3 = value;
		}

		private var _matrix:Array;

		public function get matrix():Array {
			return _matrix;
		}

		public function set matrix(value:Array):void {
			_matrix = value;
		}

		private var _width:int;

		public function get width():int {
			return _width;
		}

		public function set width(value:int):void {
			_width = value;
		}

		private var _height:int;

		public function get height():int {
			return _height;
		}

		public function set height(value:int):void {
			_height = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			readFullBox(bitStream, this);

			if (version == 1) {
				creationTime = data.readDouble();
				modificationTime = data.readDouble();
				trackID = data.readUnsignedInt();
				reserved1 = data.readUnsignedInt();
				duration = data.readDouble();
			}
			else {
				creationTime = data.readUnsignedInt();
				modificationTime = data.readUnsignedInt();
				trackID = data.readUnsignedInt();
				reserved1 = data.readUnsignedInt();
				duration = data.readUnsignedInt();
			}

			reserved2 = [];
			reserved2[0] = data.readUnsignedInt();
			reserved2[1] = data.readUnsignedInt();
			layer = data.readUnsignedShort();
			alternateGroup = data.readUnsignedShort();
			volume = data.readUnsignedShort();
			reserved3 = data.readUnsignedShort();
			matrix = [];
			matrix[0] = data.readUnsignedInt();
			matrix[1] = data.readUnsignedInt();
			matrix[2] = data.readUnsignedInt();
			matrix[3] = data.readUnsignedInt();
			matrix[4] = data.readUnsignedInt();
			matrix[5] = data.readUnsignedInt();
			matrix[6] = data.readUnsignedInt();
			matrix[7] = data.readUnsignedInt();
			matrix[8] = data.readUnsignedInt();

			// TODO : These should be data.readUnsignedInt()...
			//		  Doing that causes a wrong value!  It appears that the actual value
			//		  is only the first 16 bits of the 32 bits.  I don't know why!

			width = data.readUnsignedShort();
			data.readUnsignedShort(); //skip

			height = data.readUnsignedShort();
			data.readUnsignedShort(); //skip

			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TkhdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TKHD, data);
		}
	}
}
