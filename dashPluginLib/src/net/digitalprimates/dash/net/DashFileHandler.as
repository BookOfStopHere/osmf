package net.digitalprimates.dash.net
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.getTimer;
	
	import net.digitalprimates.dash.decoders.DefaultDecoderFactory;
	import net.digitalprimates.dash.decoders.IDecoder;
	import net.digitalprimates.dash.decoders.IDecoderFactory;
	import net.digitalprimates.dash.utils.Log;
	
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.utils.OSMFSettings;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashFileHandler extends HTTPStreamingFileHandlerBase
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		private static const BOX_READ_LIMIT:Number = OSMFSettings.hdsBytesProcessingLimit;
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------

		private var _decoderFactory:IDecoderFactory;

		protected function get decoderFactory():IDecoderFactory {
			if (!_decoderFactory) {
				_decoderFactory = new DefaultDecoderFactory();
			}

			return _decoderFactory;
		}

		protected var currentDecoder:IDecoder;

		public var currentMimeType:String;
		public var currentCodecs:Array;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		override public function beginProcessFile(seek:Boolean, seekTime:Number):void {
			initializeProcessing();
			currentDecoder.beginProcessData();
		}

		override public function get inputBytesNeeded():Number {
			return 8; // TODO : How is this used?
					  // Enough for a type + size from box.
		}

		override public function processFileSegment(input:IDataInput):ByteArray {
			return processDataByFormat(input, BOX_READ_LIMIT, false);
		}

		override public function endProcessFile(input:IDataInput):ByteArray {
			var rv:ByteArray = processDataByFormat(input, BOX_READ_LIMIT, false);

			finishProcessing();

			return rv;
		}

		override public function flushFileSegment(input:IDataInput):ByteArray {
			var rv:ByteArray = processDataByFormat(input || new ByteArray(), 0, true);

			finishProcessing();

			return rv;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		private function initializeProcessing():void {
			if (!currentDecoder) {
				currentDecoder = decoderFactory.newInstance(currentMimeType, currentCodecs);
			}
		}

		private function finishProcessing():void {
			
		}

		private function processDataByFormat(input:IDataInput, limit:Number=0, flush:Boolean=false):ByteArray {
			if (!currentDecoder)
				return null;
			
			Log.log("start", getTimer());
			var bytes:ByteArray = currentDecoder.processData(input, limit);
			Log.log("end", getTimer());
			
			return bytes;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashFileHandler() {
			super();
		}
	}
}
