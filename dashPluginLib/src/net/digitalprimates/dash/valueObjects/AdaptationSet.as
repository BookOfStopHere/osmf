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
			return (contentType == CONTENT_TYPE_VIDEO);
		}
		
		public function get isAudio():Boolean {
			return (contentType == CONTENT_TYPE_AUDIO);
		}
	}
}