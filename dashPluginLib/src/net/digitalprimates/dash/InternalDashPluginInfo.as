package net.digitalprimates.dash
{
	import net.digitalprimates.dash.loaders.DashNetLoader;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.PluginInfo;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class InternalDashPluginInfo extends PluginInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		private var loader:DashNetLoader;
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		protected function getMediaElement():MediaElement {
			return new VideoElement( null, loader );
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function InternalDashPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null,
												mediaElementCreationNotificationFunction:Function=null ) {
			if ( !mediaFactoryItems ) {
				mediaFactoryItems = new Vector.<MediaFactoryItem>();
			}
			
			var item:MediaFactoryItem;
			
			loader = new DashNetLoader();
			item = new MediaFactoryItem(
				"net.digitalprimates.dash",
				loader.canHandleResource,
				getMediaElement);
			mediaFactoryItems.push(item);
			
			super( mediaFactoryItems, mediaElementCreationNotificationFunction );
		}
	}
}