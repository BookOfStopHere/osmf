package net.digitalprimates.dash
{
	import net.digitalprimates.dash.valueObjects.AdaptationSet;

	/**
	 * The ActionScript representation of a Dash MPD manifest file.
	 * 
	 * @author Nathan Weber
	 */
	public class DashManifest
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		/**
		 * "Live" or "Recorded" 
		 */		
		public var streamType:String;
		public var minBufferTime:Number = 4;
		public var duration:Number;
		public var baseURL:String;
		
		/**
		 * The set of representations of the stream. 
		 * <p>For simple streams there will only be one of these.  More complex streams, such
		 * as when the audio and video tracks are seperate, will have more adaptation sets.</p>
		 */		
		public var adaptations:Vector.<AdaptationSet>;
	}
}