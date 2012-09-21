package net.digitalprimates.dash.parsers
{
	import flash.events.IEventDispatcher;

	/**
	 * Parses a manifest file.
	 * <p>When parsing is complete a <code>ParseEvent.COMPLETE</code> will be dispatched.</p>
	 * 
	 * @author Nathan Weber
	 */
	public interface IParser extends IEventDispatcher
	{
		/**
		 * Parses a manifest file.
		 * <p>This process is asynchronous.  A <code>ParseEvent.COMPLETE</code> must be dispatched when
		 * parsing is finished.</p>
		 *  
		 * @param value
		 * @param baseURL
		 */		
		function parse(value:String, baseURL:String):void;
	}
}