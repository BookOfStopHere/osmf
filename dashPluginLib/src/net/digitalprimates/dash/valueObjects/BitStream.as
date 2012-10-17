package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class BitStream implements IDataInput
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public function get length():uint {
			if (data)
				return data.length;
			
			return 0;
		}
		
		public function get position():uint {
			return (data != null) ? data.position : 0;
		}
		
		public function set position(value:uint):void {
			if (data)
				data.position = value;
		}
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		protected var data:ByteArray;
		
		//----------------------------------------
		//
		// IDataInput
		//
		//----------------------------------------
		
		public function get bytesAvailable():uint {
			if (data)
				return data.bytesAvailable;
			return 0;
		}
		
		public function get endian():String {
			if (data)
				return data.endian;
			return null;
		}
		
		public function set endian(value:String):void {
			if (data)
				data.endian = value;
		}
		
		public function get objectEncoding():uint {
			if (data)
				return data.objectEncoding;
			return 0;
		}
		
		public function set objectEncoding(version:uint):void {
			if (data)
				data.objectEncoding = version;
		}
		
		public function readBoolean():Boolean {
			if (data)
				return data.readBoolean();
			return false;
		}
		
		public function readByte():int {
			if (data)
				return data.readByte();
			return 0;
		}
		
		public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void {
			if (data)
				return data.readBytes(bytes, offset, length);
		}
		
		public function readDouble():Number {
			if (data)
				return data.readDouble();
			return 0;
		}
		
		public function readFloat():Number {
			if (data)
				return data.readFloat();
			return 0;
		}
		
		public function readInt():int {
			if (data)
				return data.readInt();
			return 0;
		}
		
		public function readMultiByte(length:uint, charSet:String):String {
			if (data)
				return data.readMultiByte(length, charSet);
			return null;
		}
		
		public function readObject():* {
			if (data)
				return data.readObject();
			return null;
		}
		
		public function readShort():int {
			if (data)
				return data.readShort();
			return 0;
		}
		
		public function readUnsignedByte():uint {
			if (data)
				return data.readUnsignedByte();
			return 0;
		}
		
		public function readUnsignedInt():uint {
			if (data)
				return data.readUnsignedInt();
			return 0;
		}
		
		public function readUnsignedShort():uint {
			if (data)
				return data.readUnsignedShort();
			return 0;
		}
		
		public function readUTF():String {
			if (data)
				return data.readUTF();
			return null;
		}
		
		public function readUTFBytes(length:uint):String {
			if (data)
				return data.readUTFBytes(length);
			return null;
		}
		
		//----------------------------------------
		//
		// Methods ported from mp4parser
		// http://code.google.com/p/mp4parser/
		// com.coremedia.iso.IsoTypeReader.java
		//
		//----------------------------------------
		
		public function readUInt32():uint {
			return data.readUnsignedInt();
		}
		
		public function readUInt24():uint {
			var result:uint = data.readUnsignedShort() << 8;
			result |= data.readUnsignedByte();
			return result;
		}
		
		public function readUInt16():uint {
			return data.readUnsignedShort();
		}
		
		public function readUInt8():uint {
			return data.readUnsignedByte();
		}
		
		public function readUInt64():Number {
			var result:Number = (data.readUnsignedInt() << 32);
			result |= data.readUnsignedInt();
			return result;
		}
		
		public function readFixedPoint1616():Number {
			// TODO : Consider when 31st bit is set.
			return (data.readUnsignedInt() >>> 16);
		}
		
		public function readFixedPoint88():Number {
			return (data.readUnsignedShort() >>> 8);
		}
		
		public function readIso639():String {
			var bits:int = data.readUnsignedShort();
			
			var b1:uint = ((bits >> 10) & 0x1f) + 0x60;
			var b2:uint = ((bits >> 5) & 0x1f) + 0x60;
			var b3:uint = (bits & 0x1f) + 0x60;
			
			return String.fromCharCode(b1, b2, b3);
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function BitStream(data:ByteArray) {
			this.data = data;
		}
	}
}