package net.digitalprimates.dash.valueObjects
{
	/**
	 * A bitrate rendition.
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
		
		public var initialization:String;
		public var segmentRangeStart:Number;
		public var segmentRangeEnd:Number;
		public var segments:Vector.<Segment>;
		public var segmentTemplate:SegmentTemplate;
		
		public var segmentTimescale:Number;
		public var segmentDuration:Number;
	}
}