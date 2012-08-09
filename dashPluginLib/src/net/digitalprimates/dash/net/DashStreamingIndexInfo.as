package net.digitalprimates.dash.net
{
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashStreamingIndexInfo extends HTTPStreamingIndexInfoBase
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var url:String;
		public var streamInfos:Vector.<DashStreamingInfo>;

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashStreamingIndexInfo(url:String, streamInfos:Vector.<DashStreamingInfo>) {
			this.url = url;
			this.streamInfos = streamInfos;
		}
	}
}
