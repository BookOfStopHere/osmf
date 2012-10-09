package net.digitalprimates.dash.utils
{
	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TimeUtil
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		public static function convertTimeToSeconds(time:String):Number {
			//PT0H10M0.00S
			//PT1.5S

			if (time == null || time.length == 0) {
				return 0;
			}

			if (time.substr(0, 2) != "PT") {
				return 0;
			}
			
			var t:String = time.substr(2);
			
			var hours:Number = 0;
			var minutes:Number = 0;
			var seconds:Number = 0;
			
			var parts:Array;
			
			parts = t.split("H");
			if (parts.length == 2) {
				hours = Number(parts[0]);
				t = parts[1];
			}
			
			parts = t.split("M");
			if (parts.length == 2) {
				minutes = Number(parts[0]);
				t = parts[1];
			}
			
			parts = t.split("S");
			if (parts.length == 2) {
				seconds = Number(parts[0]);
				t = parts[1];
			}
			
			return (hours * 60 * 60) + (minutes * 60) + seconds;
		}
	}
}
