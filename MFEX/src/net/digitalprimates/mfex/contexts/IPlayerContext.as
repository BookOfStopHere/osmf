package net.digitalprimates.mfex.contexts
{
	import flash.display.DisplayObjectContainer;
	
	import net.digitalprimates.mfex.Media;
	
	import org.robotlegs.core.IContext;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public interface IPlayerContext extends IContext
	{
		function get media():Media;
		function set media(value:Media):void;
		
		function get contextView():DisplayObjectContainer;
		function set contextView(value:DisplayObjectContainer):void;
	}
}