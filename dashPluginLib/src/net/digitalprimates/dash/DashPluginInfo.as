package net.digitalprimates.dash
{
	import net.digitalprimates.dash.elements.DashElement;
	import net.digitalprimates.dash.loaders.DashLoader;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.PluginInfo;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DashPluginInfo extends PluginInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		private var loader:DashLoader;
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		protected function getMediaElement():MediaElement {
			return new DashElement( null, loader );
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DashPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null,
									    mediaElementCreationNotificationFunction:Function=null ) {
			if ( !mediaFactoryItems ) {
				mediaFactoryItems = new Vector.<MediaFactoryItem>();
			}
			
			var item:MediaFactoryItem;
			
			loader = new DashLoader();
			item = new MediaFactoryItem(
				"net.digitalprimates.mpd.dash",
				loader.canHandleResource,
				getMediaElement);
			mediaFactoryItems.push(item);
			
			super( mediaFactoryItems, mediaElementCreationNotificationFunction );
		}
	}
}