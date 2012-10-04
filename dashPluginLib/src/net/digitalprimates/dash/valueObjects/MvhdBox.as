package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MvhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _creationTime:Number;

		public function get creationTime():Number {
			return _creationTime;
		}

		public function set creationTime(value:Number):void {
			_creationTime = value;
		}

		private var _modificationTime:Number;

		public function get modificationTime():Number {
			return _modificationTime;
		}

		public function set modificationTime(value:Number):void {
			_modificationTime = value;
		}

		private var _timescale:Number;

		public function get timescale():Number {
			return _timescale;
		}

		public function set timescale(value:Number):void {
			_timescale = value;
		}

		private var _duration:Number;

		public function get duration():Number {
			return _duration;
		}

		public function set duration(value:Number):void {
			_duration = value;
		}

		private var _preferredRate:int;

		public function get preferredRate():int {
			return _preferredRate;
		}

		public function set preferredRate(value:int):void {
			_preferredRate = value;
		}

		private var _preferredVolume:int;

		public function get preferredVolume():int {
			return _preferredVolume;
		}

		public function set preferredVolume(value:int):void {
			_preferredVolume = value;
		}

		private var _matrixA:int;

		public function get matrixA():int {
			return _matrixA;
		}

		public function set matrixA(value:int):void {
			_matrixA = value;
		}

		private var _matrixB:int;

		public function get matrixB():int {
			return _matrixB;
		}

		public function set matrixB(value:int):void {
			_matrixB = value;
		}

		private var _matrixU:int;

		public function get matrixU():int {
			return _matrixU;
		}

		public function set matrixU(value:int):void {
			_matrixU = value;
		}

		private var _matrixC:int;

		public function get matrixC():int {
			return _matrixC;
		}

		public function set matrixC(value:int):void {
			_matrixC = value;
		}

		private var _matrixD:int;

		public function get matrixD():int {
			return _matrixD;
		}

		public function set matrixD(value:int):void {
			_matrixD = value;
		}

		private var _matrixV:int;

		public function get matrixV():int {
			return _matrixV;
		}

		public function set matrixV(value:int):void {
			_matrixV = value;
		}

		private var _matrixX:int;

		public function get matrixX():int {
			return _matrixX;
		}

		public function set matrixX(value:int):void {
			_matrixX = value;
		}

		private var _matrixY:int;

		public function get matrixY():int {
			return _matrixY;
		}

		public function set matrixY(value:int):void {
			_matrixY = value;
		}

		private var _matrixW:int;

		public function get matrixW():int {
			return _matrixW;
		}

		public function set matrixW(value:int):void {
			_matrixW = value;
		}

		private var _previewTime:int;

		public function get previewTime():int {
			return _previewTime;
		}

		public function set previewTime(value:int):void {
			_previewTime = value;
		}

		private var _previewDuration:int;

		public function get previewDuration():int {
			return _previewDuration;
		}

		public function set previewDuration(value:int):void {
			_previewDuration = value;
		}

		private var _posterTime:int;

		public function get posterTime():int {
			return _posterTime;
		}

		public function set posterTime(value:int):void {
			_posterTime = value;
		}

		private var _selectionTime:int;

		public function get selectionTime():int {
			return _selectionTime;
		}

		public function set selectionTime(value:int):void {
			_selectionTime = value;
		}

		private var _selectionDuration:int;

		public function get selectionDuration():int {
			return _selectionDuration;
		}

		public function set selectionDuration(value:int):void {
			_selectionDuration = value;
		}

		private var _currentTime:int;

		public function get currentTime():int {
			return _currentTime;
		}

		public function set currentTime(value:int):void {
			_currentTime = value;
		}

		private var _nextTrackID:int;

		public function get nextTrackID():int {
			return _nextTrackID;
		}

		public function set nextTrackID(value:int):void {
			_nextTrackID = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			if (version == 1) {
				creationTime = bitStream.readUInt64();
				modificationTime = bitStream.readUInt64();
				timescale = bitStream.readUInt32();
				duration = bitStream.readUInt64();
			}
			else {
				creationTime = bitStream.readUInt32();
				modificationTime = bitStream.readUInt32();
				timescale = bitStream.readUInt32();
				duration = bitStream.readUInt32();
			}

			preferredRate = bitStream.readUInt32();
			preferredVolume = bitStream.readUInt16();

			bitStream.position += 10; // reserved

			matrixA = bitStream.readUInt32();
			matrixB = bitStream.readUInt32();
			matrixU = bitStream.readUInt32();
			matrixC = bitStream.readUInt32();
			matrixD = bitStream.readUInt32();
			matrixV = bitStream.readUInt32();
			matrixX = bitStream.readUInt32();
			matrixY = bitStream.readUInt32();
			matrixW = bitStream.readUInt32();
			previewTime = bitStream.readUInt32();
			previewDuration = bitStream.readUInt32();
			posterTime = bitStream.readUInt32();
			selectionTime = bitStream.readUInt32();
			selectionDuration = bitStream.readUInt32();
			currentTime = bitStream.readUInt32();
			nextTrackID = bitStream.readUInt32();

			bitStream.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MvhdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MVHD, data);
		}
	}
}
