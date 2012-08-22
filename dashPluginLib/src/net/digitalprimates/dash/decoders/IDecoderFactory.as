package net.digitalprimates.dash.decoders
{
	/**
	 * 
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
		
		function newInstance(mimeType:String, codecs:Array):IDecoder;
	}
}