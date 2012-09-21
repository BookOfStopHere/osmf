package net.digitalprimates.dash.decoders
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * Decodes fragment data and repackages as FLV video data.
	 * 
	 * @author Nathan Weber
	 */
	public interface IDecoder
	{
		/**
		 * Called before a fragment is going to be processed. 
		 */		
		function beginProcessData():void;
		
		/**
		 * Processes a set of fragment data.
		 * <p>The data should be decoded and then repackaged into FLV video containers.  
		 * <code>NetStream.appendBytes()</code> can only play FLV packages!.</p>
		 * <p>It's important to limit the number of bytes processed per call, otherwise
		 * the processing could bog down performance.  Passing a value of 0 will tell the
		 * decoder to process all available bytes.</p>
		 *  
		 * @param input
		 * @param limit The max number of bytes to process this call.
		 * @return FLV packaged data. 
		 */		
		function processData(input:IDataInput, limit:Number = 0):ByteArray;
	}
}