package net.digitalprimates.dash.builders
{
	import net.digitalprimates.dash.parsers.DashParser;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class BaseDashBuilder
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function canParse(resource:String):Boolean
		{
			// TODO - Utilize @profiles to build specific builders.
			return true;
		}
		
		public function build(resource:String):DashParser
		{
			return new DashParser();
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function BaseDashBuilder() {
			
		}
	}
}