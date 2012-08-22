package net.digitalprimates.dash.valueObjects
{
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class Representation
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var baseURL:String;
		public var id:String;
		public var mimeType:String;
		public var codecs:Array;
		public var width:Number;
		public var height:Number;
		public var bitrate:Number;
		
		/**
		 * "video" or "audio" 
		 */		
		public var contentType:String;
		
		public var segmentSourceURL:String;
		public var segmentRangeStart:Number;
		public var segmentRangeEnd:Number;
		public var segments:Vector.<Segment>;
		
		public var segmentTimescale:Number;
		public var segmentDuration:Number;
	}
}