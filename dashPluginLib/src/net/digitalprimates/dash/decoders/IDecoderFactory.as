package net.digitalprimates.dash.decoders
{
	/**
	 * Builds a decoder to use for a particular type of video/audio data.
	 * 
	 * @author Nathan Weber
	 */
	public interface IDecoderFactory
	{
		//----------------------------------------
		//
		// Methods
		//
		//----------------------------------------
		
		/**
		 * Returns a deocoder to use for the given data type.
		 *  
		 * @param mimeType
		 * @param codecs
		 * @return 
		 */		
		function newInstance(mimeType:String, codecs:Array):IDecoder;
	}
}