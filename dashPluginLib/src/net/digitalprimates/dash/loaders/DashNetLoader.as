package net.digitalprimates.dash.loaders
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import net.digitalprimates.dash.DashMetadataNamespaces;
	import net.digitalprimates.dash.net.DashHTTPNetStream;
	import net.digitalprimates.dash.net.DashStreamingFactory;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashNetLoader extends HTTPStreamingNetLoader
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		override public function canHandleResource(resource:MediaResourceBase):Boolean {
			var metadata:Object = resource.getMetadataValue(DashMetadataNamespaces.PLAYABLE_RESOURCE_METADATA);

			if (metadata != null && metadata == true) {
				return true;
			}

			return false;
		}

		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream {
			var factory:HTTPStreamingFactory = new DashStreamingFactory();
			var httpNetStream:HTTPNetStream = new DashHTTPNetStream(connection, factory, resource);

			return httpNetStream;
		}
	}
}
