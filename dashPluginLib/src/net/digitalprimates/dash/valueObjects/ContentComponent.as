package net.digitalprimates.dash.valueObjects
{
	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class ContentComponent
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _contentType:String;

		public function get contentType():String {
			return _contentType;
		}

		public function set contentType(value:String):void {
			_contentType = value;
		}

		private var _id:String;

		public function get id():String {
			return _id;
		}

		public function set id(value:String):void {
			_id = value;
		}

		private var _lang:String;

		public function get lang():String {
			return _lang;
		}

		public function set lang(value:String):void {
			_lang = value;
		}
	}
}
