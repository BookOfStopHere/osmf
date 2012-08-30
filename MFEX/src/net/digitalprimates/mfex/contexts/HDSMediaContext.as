package net.digitalprimates.mfex.contexts
{
	import flash.display.DisplayObjectContainer;
	
	import net.digitalprimates.mfex.Media;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class HDSMediaContext extends DefaultMediaContext
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

		public function HDSMediaContext(contextView:DisplayObjectContainer=null, media:Media=null) {
			super(contextView, media);
		}
	}
}
