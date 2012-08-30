package net.digitalprimates.mfex.contexts
{
	import flash.display.DisplayObjectContainer;
	
	import net.digitalprimates.mfex.Media;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashMediaContext extends DefaultMediaContext
	{
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function mapVideoPlayerInternals():void {
			super.mapVideoPlayerInternals();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashMediaContext(contextView:DisplayObjectContainer=null, media:Media=null) {
			super(contextView, media);
		}
	}
}
