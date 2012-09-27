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
		public var id:String;
		
		public var mimeType:String;
		
		/**
		 * "video" or "audio"
		 * <p>Use <code>isVideo()</code> and <code>isAudio()</code> to determine content type.</p> 
		 */		
		public var contentType:String;
		
		/**
		 * The set of bitrate renditions. 
		 */		
		public var medias:Vector.<Representation>;
		
		public function get isVideo():Boolean {
			// check contentType first
			if (contentType != null && contentType.length > 0) {
				return (contentType == CONTENT_TYPE_VIDEO);
			}
			// next check mimeType
			else if (mimeType != null && mimeType.length > 0) {
				return (mimeType.indexOf(CONTENT_TYPE_VIDEO) != -1);
			}
			else {
				return false;
			}
		}
		
		public function get isAudio():Boolean {
			// check contentType first
			if (contentType != null && contentType.length > 0) {
				return (contentType == CONTENT_TYPE_AUDIO);
			}
				// next check mimeType
			else if (mimeType != null && mimeType.length > 0) {
				return (mimeType.indexOf(CONTENT_TYPE_AUDIO) != -1);
			}
			else {
				return false;
			}
		}
	}
}