package net.digitalprimates.mfex.utils
{
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class URL
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var source:String;
		
		public var isHTTP:Boolean = false;
		public var isSecure:Boolean = false;
		public var isRTMP:Boolean = false;
		public var isAbsolute:Boolean = false;
		
		public var host:String = null;
		public var path:String = null;
		public var extension:String = null;
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function parse():void {
			if (!source)
				throw new Error("No URL provided.");
			
			isHTTP = (source.indexOf("http://") == 0 || source.indexOf("https://") == 0);
			isRTMP = (source.indexOf("rtmp://") == 0 || source.indexOf("rtmpe://") == 0);
			isSecure = (isHTTP && source.indexOf("https://") == 0) || (isRTMP && source.indexOf("rtmpe://") == 0);
			isAbsolute = (isHTTP || isRTMP);
			
			if (isAbsolute) {
				var start:int = source.indexOf("://");
				var end:int = source.indexOf("/", start+3);
				if (end == -1) end = int.MAX_VALUE;
				host = source.substring(start, end);
				path = source.substr(end);
			}
			else {
				path = source;
			}
			
			var lastSlash:int = source.lastIndexOf("/");
			var lastDot:int = source.lastIndexOf(".");
			
			if (lastDot > lastSlash) {
				extension = source.substr(lastDot);
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function URL(source:String) {
			this.source = source;
			parse();
		}
	}
}