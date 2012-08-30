package net.digitalprimates.dash.decoders
{
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DefaultDecoderFactory implements IDecoderFactory
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		private static const VIDEO_MP2T:String = "video/mp2t";
		private static const VIDEO_MP4:String = "video/mp4";
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function newInstance(mimeType:String, codecs:Array):IDecoder {
			// TODO : Ignore codecs for now.. figure out how to use them.
			
			var decoder:IDecoder;
			
			switch (mimeType) {
				case VIDEO_MP2T:
					decoder = new MP2TDecoder();
					break;
				
				case VIDEO_MP4:
					decoder = new MP4Decoder();
					break;
			}
			
			return decoder;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DefaultDecoderFactory() {
			
		}
	}
}