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
		public var segmentTemplate:SegmentTemplate;
		public var segmentTimescale:Number;
		public var segmentDuration:Number;

		private var _segments:Vector.<Segment>;

		public function get segments():Vector.<Segment> {
			// use the segments from the template if they exist
			if (segmentTemplate && segmentTemplate.segments) {
				return segmentTemplate.segments;
			}
			
			return _segments;
		}

		public function set segments(value:Vector.<Segment>):void {
			_segments = value;
		}
	}
}
