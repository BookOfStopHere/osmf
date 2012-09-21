package net.digitalprimates.dash.builders
{
	import net.digitalprimates.dash.parsers.DashParser;
	import net.digitalprimates.dash.parsers.IParser;

	/**
	 * Basic implementation of a dash builder.  Should be expanded later.
	 * 
	 * @author Nathan Weber
	 */
	public class BaseDashBuilder implements IDashBuilder
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		/**
		 * @copy net.digitalprimates.dash.builders.IDashBuilder#canParse() 
		 */		
		public function canParse(resource:String):Boolean {
			// TODO - Utilize @profiles to build specific builders.
			return true;
		}
		
		/**
		 * @copy net.digitalprimates.dash.builders.IDashBuilder#build()
		 */		
		public function build(resource:String):IParser {
			return new DashParser();
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		/**
		 * Constructor. 
		 */		
		public function BaseDashBuilder() {
			
		}
	}
}