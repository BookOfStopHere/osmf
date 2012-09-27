package net.digitalprimates.dash.valueObjects
{
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class SegmentTimeline
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var fragments:Vector.<TimelineFragment>;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function SegmentTimeline(fragments:Vector.<TimelineFragment> = null) {
			this.fragments = fragments;
		}
	}
}