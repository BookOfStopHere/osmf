package net.digitalprimates.dash.net
{
	import net.digitalprimates.dash.valueObjects.Representation;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DashStreamingInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var streamName:String;
		public var bitrate:Number;
		public var media:Representation;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DashStreamingInfo(streamName:String, bitrate:Number, media:Representation) {
			this.streamName = streamName;
			this.bitrate = bitrate;
			this.media = media;
		}
	}
}