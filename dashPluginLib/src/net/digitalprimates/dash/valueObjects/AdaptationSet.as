package net.digitalprimates.dash.valueObjects
{
	/**
	 * A representation of a stream.
	 * 
	 * @author Nathan Weber
	 */
	public class AdaptationSet
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		private static const CONTENT_TYPE_VIDEO:String = "video";
		private static const CONTENT_TYPE_AUDIO:String = "audio";
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var baseURL:String;
		public var mimeType:String;
		public var contentComponents:Vector.<ContentComponent>;
		
		/**
		 * The set of bitrate renditions. 
		 */		
		public var medias:Vector.<Representation>;
		
		public function get isVideo():Boolean {
			if (contentComponents) {
				for each (var cc:ContentComponent in contentComponents) {
					if (cc.contentType == CONTENT_TYPE_VIDEO) {
						return true;
					}
				}
			}
			
			if (mimeType != null && mimeType.length > 0) {
				return (mimeType.indexOf(CONTENT_TYPE_VIDEO) != -1);
			}
			
			return false;
		}
		
		public function get isAudio():Boolean {
			// if the stream also has video, we'll use it as the video track
			// the audio will be baked in
			if (isVideo)
				return false;
			
			if (contentComponents) {
				for each (var cc:ContentComponent in contentComponents) {
					if (cc.contentType == CONTENT_TYPE_AUDIO) {
						return true;
					}
				}
			}
			
			if (mimeType != null && mimeType.length > 0) {
				return (mimeType.indexOf(CONTENT_TYPE_AUDIO) != -1);
			}
			
			return false;
		}
	}
}