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

			const HOUR_PATTERN:RegExp = /[0-9]+H/g;
			const MINUTE_PATTERN:RegExp = /[0-9]+M/g;
			const SECOND_PATTERN:RegExp = /[0-9]+\.[0-9]+S/g;
			const SECOND_PATTERN2:RegExp = /[0-9]+S/g;

			var hours:Number = extractNumber(time, HOUR_PATTERN);
			var minutes:Number = extractNumber(time, MINUTE_PATTERN);
			
			var seconds:Number = extractNumber(time, SECOND_PATTERN);
			seconds = extractNumber(time, SECOND_PATTERN2); // TODO : Multiple formats, how to know?!?!

			return (hours * 60 * 60) + (minutes * 60) + seconds;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private static function extractNumber(time:String, pattern:RegExp):Number {
			var values:Array = time.match(pattern);
			var num:Number = 0;

			if (values && values.length > 0) {
				var str:String = values[0];
				str = str.substr(0, str.length - 1);
				num = Number(str);
			}

			return num;
		}
	}
}
