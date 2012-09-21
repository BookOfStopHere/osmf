package net.digitalprimates.dash.builders
{
	import net.digitalprimates.dash.parsers.IParser;

	/**
	 * Builds a <code>DashParser</code> to parse a .mpd manifest file.
	 * <p>This is left open as Dash is still an evolving specification.</p>
	 * 
	 * @author Nathan Weber
	 */
	public interface IDashBuilder
	{
		/**
		 * Whether or not this builder knows how to parse a given manifest file.
		 *  
		 * @param resource The contents of a .mpd manifest file.
		 * @return 
		 */		
		function canParse(resource:String):Boolean;
		
		/**
		 * Returns an <code>IParser</code> that is capable of parsing the manifest.
		 *  
		 * @param resource
		 * @return 
		 */		
		function build(resource:String):IParser;
	}
}