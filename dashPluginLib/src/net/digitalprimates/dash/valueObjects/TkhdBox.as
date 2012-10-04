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

		private var _trackId:int;

		public function get trackId():int {
			return _trackId;
		}

		public function set trackId(value:int):void {
			_trackId = value;
		}

		private var _duration:Number;

		public function get duration():Number {
			return _duration;
		}

		public function set duration(value:Number):void {
			_duration = value;
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

		private var _matrix:Array;

		public function get matrix():Array {
			return _matrix;
		}

		public function set matrix(value:Array):void {
			_matrix = value;
		}

		private var _width:Number;

		public function get width():Number {
			return _width;
		}

		public function set width(value:Number):void {
			_width = value;
		}

		private var _height:Number;

		public function get height():Number {
			return _height;
		}

		public function set height(value:Number):void {
			_height = value;
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
				trackId = bitStream.readUInt32();
				bitStream.readUInt32();
				duration = bitStream.readUInt64();
			}
			else {
				creationTime = bitStream.readUInt32();
				modificationTime = bitStream.readUInt32();
				trackId = bitStream.readUInt32();
				bitStream.readUInt32();
				duration = bitStream.readUInt32();
			}
			
			bitStream.readUInt32();
			bitStream.readUInt32();
			layer = bitStream.readUInt16();
			alternateGroup = bitStream.readUInt16();
			volume = bitStream.readFixedPoint88();
			bitStream.readUInt16();
			
			matrix = [];
			for (var i:int = 0; i < 9; i++) {
				matrix[i] = bitStream.readUInt32();
			}
			
			width = bitStream.readFixedPoint1616();
			height = bitStream.readFixedPoint1616();
			
			/*
			// These should be bitStream.readUInt32()...
			// Doing that causes a wrong value!  It appears that the actual value
			// is only the first 16 bits of the 32 bits.  I don't know why!
			width = bitStream.readUInt16();
			bitStream.readUInt16(); //skip
			height = bitStream.readUInt16();
			bitStream.readUInt16(); //skip
			*/
			
			bitStream.position = 0;
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
