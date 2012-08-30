package net.digitalprimates.dash.elements
{
	import net.digitalprimates.dash.loaders.DashLoader;

	import org.osmf.elements.LoadFromDocumentElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashElement extends LoadFromDocumentElement
	{
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashElement(resource:MediaResourceBase = null, loader:DashLoader = null) {
			if (loader == null) {
				loader = new DashLoader();
			}
			super(resource, loader);
		}
	}
}
