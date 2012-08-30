package net.digitalprimates.dash.valueObjects
{
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class NALActions
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		public static const IGNORE:NALActions = new NALActions("nalActionIgnore");
		public static const BUFFER:NALActions = new NALActions("nalActionBuffer");
		public static const STORE:NALActions = new NALActions("nalActionStore");
		public static const END:NALActions = new NALActions("nalActionEnd");
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var type:String;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function NALActions(type:String) {
			this.type = type;
		}
	}
}