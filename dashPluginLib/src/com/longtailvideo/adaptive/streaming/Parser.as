package com.longtailvideo.adaptive.streaming {
	
	
	import com.longtailvideo.adaptive.Adaptive;
	import com.longtailvideo.adaptive.muxing.*;
	
	import flash.utils.ByteArray;


    /** Class that keeps the buffer filled. **/
    public class Parser {
		
		
		/** Reference to the adaptive controller. **/
		private var _adaptive:Adaptive;
		/** Buffer of unparsed TS data. **/
		private var _parseBuffer:ByteArray;
		/** Buffer for newly added data **/
		private var _newBytes:ByteArray;
		/** Packet number of the last PAT packet scanned **/
		private var _lastPAT:uint = 0;
		/** Payload Unit Start Indicator (stt) value of last packet scanned **/
		private var _stt:uint = 0;
		/** Current PID **/
		private var _pid:uint = 0;
		/** Packet ID of the PAT (is always 0). **/
		private var _patId:Number = 0;
		/** Packet ID of the Program Map Table. **/
		private var _pmtId:Number = -1;
		/** Packet ID of the AAC audio stream. **/
		private var _aacId:Number = -1;
		/** Packet ID of the video stream. **/
		private var _avcId:Number = -1;
		/** Packet ID of the MP3 audio stream. **/
		private var _mp3Id:Number = -1;
		/** Packet number of the last endpoint of an audio packet chunk **/
		private var _breakPointAudio:Number = 0;
		/** Packet number of the last endpoint of a video packet chunk **/
		private var _breakPointVideo:Number = 0;
		/** The packet number of the earlier of the two breakpoints **/
		private var _minBreakPoint:Number = 0;
		/** The packet number of the later of the two breakpoints **/
		private var _maxBreakPoint:Number = 0;
		/** The packet ID number of the later of the two breakpoints **/
		private var _maxBreakPointId:Number = 0;
		/** Vector of PID's of packets in between audio and video breakpoints **/
		private var _packetPIDs:Vector.<Number> = new Vector.<Number>();
		/** Leftover bytes in last audio frame (if stream uses 'optimize' flag) **/
		private var _leftOverFrameBytes:Number = 0;
		/** Number of audio bytes overflowing from a previously read packet **/
		private var _overflowAudio:Number = 0;
		/** The actual bytes from the previous audio packet **/
		private var _overflowAudioBytes:ByteArray;
		/** The length of the parse buffer as of the last time it was scanned **/
		private var _bufferLastLength:uint = 0;
		
		/** Create the parser. **/
		public function Parser(adaptive:Adaptive):void {
			_adaptive = adaptive;
			_parseBuffer = new ByteArray();
			_newBytes = new ByteArray();
		}
		
		
		/** Add another fragment's bytes to buffer **/
		public function appendData(dat:ByteArray):void {
			//var currentPosition:uint = _parseBuffer.position;
			//_parseBuffer.position = _parseBuffer.length;
			//_parseBuffer.writeBytes(dat,0,0);
			//_parseBuffer.position = currentPosition;
			_newBytes.writeBytes(dat,0,0);
		}
		
		
		/** Clear the buffer **/
		public function clearBuffer():void {
			_parseBuffer.clear();
			_newBytes.clear();
			_lastPAT = 0;
			_stt = 0;
			// Clear PID's
			_pmtId = -1;
			_aacId = -1;
			_avcId = -1;
			_mp3Id = -1;
			_breakPointAudio = 0;
			_breakPointVideo = 0;
			_minBreakPoint = 0;
			_maxBreakPoint = 0;
			_maxBreakPointId = 0;
			_packetPIDs = new Vector.<Number>();
			_overflowAudio = 0;
			_overflowAudioBytes = new ByteArray();
			_bufferLastLength = 0;
		}

		
		/** Create a TS object with all currently available data **/
		public function parseData():TS {
			// Append any newly added data into parse buffer
			if( _newBytes.length > 0 ) {
				//trace("in parseData, adding "+_newBytes.length/188+" pkts to _parseBuffer");
				_parseBuffer.position = _parseBuffer.length;
				_parseBuffer.writeBytes(_newBytes,0,0);
				_newBytes.clear();
				//trace("after add, parseBuffer.position = "+_parseBuffer.position/188+", length = "+_parseBuffer.length/188);
			}
			var ts:TS;
			// Find a safe break point in the TS data
			if( _bufferLastLength != _parseBuffer.length ) {
				_scanDataSegment();
			}
			// Make sure the chunk to be parsed is not ridiculously small
			if( _minBreakPoint > 10 ) {
				_parseBuffer.position = 0;
				
				// Data to parse right now
				var tsData:ByteArray = new ByteArray();
				//tsData.writeBytes(_parseBuffer,0,breakPoint*TS.PACKETSIZE);
				tsData.writeBytes(_parseBuffer,0,(_minBreakPoint+1)*TS.PACKETSIZE);
				// Data to remain in buffer
				var remainder:ByteArray = new ByteArray();
				// Split up data in between 2 breakpoints appropriately
				for(var i:Number = 0; i < _maxBreakPoint-_minBreakPoint; i++) {
					// If part of the later breakpoint, amend that packet to the data above to be parsed
					if( _packetPIDs[i] == _maxBreakPointId ) {
						tsData.writeBytes(_parseBuffer, (_minBreakPoint+1+i)*TS.PACKETSIZE, TS.PACKETSIZE);
					}
					else {
						remainder.writeBytes(_parseBuffer, (_minBreakPoint+1+i)*TS.PACKETSIZE, TS.PACKETSIZE);
					}
				}
				// Write rest of buffer to remainer
				//remainder.writeBytes(_parseBuffer, (_maxBreakPoint+1)*TS.PACKETSIZE, ((Math.floor(_parseBuffer.length/TS.PACKETSIZE)-(_maxBreakPoint+1))*TS.PACKETSIZE));
				remainder.writeBytes(_parseBuffer, (_maxBreakPoint+1)*TS.PACKETSIZE);
				
				// Keep remainder
				remainder.position = 0;
				_parseBuffer.clear();
				_parseBuffer.writeBytes(remainder,0,0);
				//trace("A tsData length pkts = "+tsData.length/188+", remainder length pkts = "+remainder.length/188);
				tsData.position = 0;
				ts = new TS(tsData,_pmtId,_aacId,_avcId,_mp3Id,_overflowAudio,_overflowAudioBytes);
				// get possible overflow from ADTS parsing (if 'optimize' flag used)
				_overflowAudio = ts.overflowAudio;
				_overflowAudioBytes = ts.overflowAudioBytes;
				//trace("ts.overflowAudio = "+ts.overflowAudio);
				
			}
			else {
				//trace("creating empty TS()");
				ts = new TS(new ByteArray(),-1,-1,-1,-1,0,new ByteArray());
			}
			
			// Clear break point data
			_breakPointAudio = 0;
			_breakPointVideo = 0;
			_minBreakPoint = 0;
			_maxBreakPoint = 0;
			_maxBreakPointId = 0;
			_packetPIDs = new Vector.<Number>()
			return ts;
		}
		
		
		/** Scan all unparsed data in buffer, parse up to latest discontinuity point **/
		private function _scanData():uint {
			var breakPoint:Number = 0;
			var currentPacket:uint = 0;
			// Track last PAT packet (pid = 0) in the buffer, use as start of new chunk
			while(_parseBuffer.bytesAvailable) {
				_scanPacket(_parseBuffer,currentPacket);
				if( (_stt == 1) && ( (_pid == _aacId) || (_pid == _avcId)  || (_pid == _mp3Id) ) ) {
					// the break point is the # of the last packet before the new chunk begins
					breakPoint = currentPacket-1;
				}
				if( (_stt == 1) && ( (_pid == _aacId) || (_pid == _mp3Id) ) ) {
					_breakPointAudio = currentPacket-1;
				}
				if( (_stt == 1) && (_pid == _avcId) ) {
					_breakPointVideo = currentPacket-1;
				}
				currentPacket++;
			}
			// Look at PID's between the 2 breakpoints
			_minBreakPoint = Math.min(_breakPointAudio,_breakPointVideo);
			_maxBreakPoint = Math.max(_breakPointAudio,_breakPointVideo);
			_maxBreakPointId = _packetPIDs[_maxBreakPoint+1];
			_packetPIDs.splice(0,_minBreakPoint+1);
			//trace("breakpoint audio = "+_breakPointAudio+", breakpoint video = "+_breakPointVideo);
			return breakPoint;
		}
		
		
		/** Scan all unparsed data in buffer, parse up to latest discontinuity point **/
		private function _scanDataSegment():void {
			//trace("in scanDataSegment, _parseBuffer.length pkts = "+_parseBuffer.length/188+", _parseBuffer.position = "+_parseBuffer.position/188);
			// Maximum number of packets to parse at one time
			var maxPackets:Number = 15000;
			var currentPacket:uint = 0;
			// Track last PAT packet (pid = 0) in the buffer, use as start of new chunk
			_parseBuffer.position = 0;
			while( (_parseBuffer.bytesAvailable >= TS.PACKETSIZE) && (currentPacket < maxPackets) ) {
				_scanPacket(_parseBuffer,currentPacket);
				if( (_stt == 1) && ( (_pid == _aacId) || (_pid == _mp3Id) ) ) {
					_breakPointAudio = currentPacket-1;
				}
				if( (_stt == 1) && (_pid == _avcId) ) {
					_breakPointVideo = currentPacket-1;
				}
				currentPacket++;
			}
			// Look at PID's between the 2 breakpoints
			_minBreakPoint = Math.min(_breakPointAudio,_breakPointVideo);
			_maxBreakPoint = Math.max(_breakPointAudio,_breakPointVideo);
			_maxBreakPointId = _packetPIDs[_maxBreakPoint+1];
			_packetPIDs.splice(0,_minBreakPoint+1);
			//trace("breakpoint audio = "+_breakPointAudio+", breakpoint video = "+_breakPointVideo);
			_bufferLastLength = _parseBuffer.length;
		}
		
		
		/** Scan through a TS packet **/
		private function _scanPacket(dat:ByteArray,packetNum:uint):void {
			//trace("dat.length = "+dat.length+", dat.position = "+dat.position);
			// Each packet is 188 bytes.
			var todo:uint = TS.PACKETSIZE;
			// Sync byte.
			if(dat.readByte() != TS.SYNCBYTE) {
				throw new Error("scan packet: Could not parse TS file: sync byte not found.");
			}
			todo--;
			// Payload unit start indicator.
			var stt:uint = (dat.readUnsignedByte() & 64) >> 6;
			// Record current stt value
			_stt = stt;
			dat.position--;
			// Packet ID (last 13 bits of UI16).
			var pid:uint = dat.readUnsignedShort() & 8191;
			_pid = pid;
			// Store list of PIDs
			_packetPIDs.push(pid);
			// Record if this is a PAT packet
			if(pid==0){
				_lastPAT = packetNum;
			}
			// Check for adaptation field.
			todo -=2;
			var atf:uint = (dat.readByte() & 48) >> 4;
			// Read continuity counter
			dat.position--;
			var cc:uint = dat.readUnsignedByte() & 15;
			todo --;
			//trace("# "+packetNum+", stt = "+stt+", cont count = "+cc+", pid = "+pid+", atf = "+atf);
			// Read adaptation field if available.
			if(atf > 1) {
				// Length of adaptation field.
				var len:uint = dat.readUnsignedByte();
				todo--;
				// Random access indicator (keyframe).
				var rai:uint = dat.readUnsignedByte() & 64;
				dat.position += len - 1;
				todo -= len;
				// Return if there's only adaptation field.
				if(atf == 2 || len == 183) {
					dat.position += todo;
				}
			}
			
			var pes:ByteArray = new ByteArray();
			// Parse the PES, split by Packet ID.
			switch (pid) {
				case _patId:
					todo -= _readPAT(dat);
					break;
				case _pmtId:
					todo -= _readPMT(dat);
					break;
				default:
					break;
			}
			
			// Jump to the next packet.
			dat.position += todo;
		};
		
		
		/** Read the Program Association Table. **/
		private function _readPAT(dat:ByteArray):Number {
			// Check the section length for a single PMT.
			dat.position += 3;
			if(dat.readUnsignedByte() > 13) {
				throw new Error("Multiple PMT/NIT entries are not supported.");
			}
			// Grab the PMT ID.
			dat.position += 7;
			_pmtId = dat.readUnsignedShort() & 8191;
			//trace("pmtId = "+_pmtId);
			return 13;
		};
		
		
		/** Read the Program Map Table. **/
		private function _readPMT(dat:ByteArray):Number {
			// Check the section length for a single PMT.
			dat.position += 3;
			var len:uint = dat.readByte();
			var read:uint = 13;
			dat.position += 8;
			var pil:Number = dat.readByte();
			dat.position += pil;
			read += pil;
			// Loop through the streams in the PMT.
			while(read < len) {
				var typ:uint = dat.readByte();
				var sid:uint = dat.readUnsignedShort() & 8191;
				if(typ == 0x0F) {
					_aacId = sid;
					//trace("parser, aacId = "+sid);
				} else if (typ == 0x1B) {
					_avcId = sid;
					//trace("parser, avcId = "+sid);
				} else if (typ == 0x03) {
					_mp3Id = sid;
					//trace("mp3Id = "+sid);
				}
				// Possible section length.
				dat.position++;
				var sel:uint = dat.readByte() & 0x0F;
				dat.position += sel;
				read += sel + 5;
			}
			return len;
		};
		
		
    }


}