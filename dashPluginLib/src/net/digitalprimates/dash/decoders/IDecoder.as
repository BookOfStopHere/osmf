package net.digitalprimates.dash.decoders
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public interface IDecoder
	{
		//----------------------------------------
		//
		// Methods
		//
		//----------------------------------------
		
		function processData(input:IDataInput, limit:Number = 0):ByteArray;
	}
}