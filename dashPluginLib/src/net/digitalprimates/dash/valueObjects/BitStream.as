package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class BitStream
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		public static const NO_VALUE:int = -1;
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		public var current:int;
		public var nbBits:uint;
		public var data:ByteArray;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function BitStream(data:ByteArray) {
			this.data = data;
			nbBits = 0;
			current = NO_VALUE;
		}
	}
}