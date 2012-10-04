package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

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
		
		public function readUInt32BE():Number {
			var ch1:Number = readUInt8();
			var ch2:Number = readUInt8();
			var ch3:Number = readUInt8();
			var ch4:Number = readUInt8();
			
			return ((ch4 << 24) + (ch3 << 16) + (ch2 << 8) + (ch1 << 0));
		}
		
		public function readUInt32():Number {
			var i:Number = data.readInt();
			if (i < 0) {
				i += 11<<32;
			}
			return i;
		}
		
		public function readUInt24():int {
			var result:int = 0;
			result += readUInt16() << 8;
			result += byte2int(data.readByte());
			return result;
		}
		
		public function readUInt16():int {
			var result:int = 0;
			result += byte2int(data.readByte()) << 8;
			result += byte2int(data.readByte());
			return result;
		}
		
		public function readUInt16BE():int {
			var result:int = 0;
			result += byte2int(data.readByte());
			result += byte2int(data.readByte()) << 8;
			return result;
		}
		
		public function readUInt8():int {
			return byte2int(data.readByte());
		}
		
		public function byte2int(b:int):int {
			return b < 0 ? b + 256 : b;
		}
		
		public function readUInt64():Number {
			var result:Number = 0;
			result += readUInt32() << 32;
			if (result < 0) {
				throw new Error("I don't know how to deal with UInt64! long is not sufficient and I don't want to use BigInt");
			}
			result += readUInt32();
			
			return result;
		}
		
		public function readFixedPoint1616():Number {
			var bytes:ByteArray = new ByteArray();
			data.readBytes(bytes, 0, 4);
			
			var result:Number = 0;
			result |= ((bytes[0] << 24) & 0xFF000000);
			result |= ((bytes[1] << 16) & 0xFF0000);
			result |= ((bytes[2] << 8) & 0xFF00);
			result |= ((bytes[3]) & 0xFF);
			return result / 65536;
		}
		
		public function readFixedPoint88():Number {
			var bytes:ByteArray = new ByteArray();
			data.readBytes(bytes, 0, 2);
			
			var result:Number = 0;
			result |= ((bytes[0] << 8) & 0xFF00);
			result |= ((bytes[1]) & 0xFF);
			return result / 256;
		}
		
		public function readIso639():String {
			var bits:int = readUInt16();
			
			var result:String = "";
			for (var i:int = 0; i < 3; i++) {
				var c:int = (bits >> (2 - i) * 5) & 0x1f;
				result += String.fromCharCode(c + 0x60);
			}
			
			return result;
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