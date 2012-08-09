package com.longtailvideo.adaptive.muxing {


    import com.longtailvideo.adaptive.muxing.*;
    import com.longtailvideo.adaptive.utils.Log;
    
    import flash.utils.ByteArray;


    /** Representation of an MPEG transport stream. **/
    public class TS {


        /** TS Sync byte. **/
        public static const SYNCBYTE:uint = 0x47;
        /** TS Packet size in byte. **/
        public static const PACKETSIZE:uint = 188;


        /** Packet ID of the AAC audio stream. **/
        private var _aacId:Number = -1;
        /** List with audio frames. **/
        public var audioTags:Vector.<Tag> = new Vector.<Tag>();
        /** List of packetized elementary streams with AAC. **/
        private var _audioPES:Vector.<PES> = new Vector.<PES>();
        /** Packet ID of the video stream. **/
        private var _avcId:Number = -1;
        /** PES packet that contains the first keyframe. **/
        private var _firstKey:Number = -1;
        /** Packet ID of the MP3 audio stream. **/
        private var _mp3Id:Number = -1;
        /** Packet ID of the PAT (is always 0). **/
        private var _patId:Number = 0;
        /** Packet ID of the Program Map Table. **/
        private var _pmtId:Number = -1;
        /** List with video frames. **/
        public var videoTags:Vector.<Tag> = new Vector.<Tag>();
        /** List of packetized elementary streams with AVC. **/
        private var _videoPES:Vector.<PES> = new Vector.<PES>();
		/** Number of overflow bytes in next audio packet **/
		public var overflowAudio:Number = 0;
		/** Overflow bytes from last audio packet **/
		public var overflowAudioBytes:ByteArray = new ByteArray();
		/** Number of overflow bytes in next video packet **/
		public var overflowVideo:Number = 0;


        /** Transmux the M2TS file into an FLV file. **/
        public function TS(data:ByteArray, pmtId:Number, aacId:Number, avcId:Number, mp3Id:Number, prevOverflowAudio:Number, prevOverflowAudioBytes:ByteArray) {
			overflowAudio = prevOverflowAudio;
			overflowAudioBytes = prevOverflowAudioBytes;
			overflowVideo = 0;
			// Set PID's, if previously learned
			_pmtId = pmtId;
			_aacId = aacId;
			_avcId = avcId;
			_mp3Id = mp3Id;
            // Extract the elementary streams.
            while(data.bytesAvailable) {
                _readPacket(data);
            }
            //if (_videoPES.length == 0 || _audioPES.length == 0 ) {
            //    throw new Error("No AAC audio or AVC video stream found.");
            //}
            // Extract the ADTS or MPEG audio frames.
            if(_aacId > 0) {
                _readADTS();
            } else {
                _readMPEG();
            }
            // Extract the NALU video frames.
            _readNALU();
			//trace("overflow audio = "+overflowAudio+", overflow video = "+overflowVideo);
        };


        /** Get audio configuration data. **/
        public function getADIF():ByteArray {
            if(_aacId > 0) {
                return AAC.getADIF(_audioPES[0].data,_audioPES[0].payload);
            } else { 
                return new ByteArray();
            }
        };


        /** Get video configuration data. **/
        public function getAVCC():ByteArray {
            if(_firstKey == -1) {
                throw new Error("Cannot parse stream: no keyframe found in TS fragment.");
            }
            return AVC.getAVCC(_videoPES[_firstKey].data,_videoPES[_firstKey].payload);
        };


        /** Read ADTS frames from audio PES streams. **/
        private function _readADTS():void {
            var frames:Array;
            var tag:Tag;
            var stamp:Number;
			var currentRate:Number = 0;
            for(var i:Number=0; i<_audioPES.length; i++) {
                // Parse the PES headers.
                _audioPES[i].parse();
                // Correct for Segmenter's "optimize", which cuts frames in half.
                if(overflowAudio > 0) {
					//trace("optimize...");
					if(i > 0) {
						_audioPES[i-1].data.position = _audioPES[i-1].data.length;
						_audioPES[i-1].data.writeBytes(_audioPES[i].data,_audioPES[i].payload,overflowAudio);
						_audioPES[i].payload += overflowAudio;
					}
					else {
						//trace("overflowAudioBytes.position="+overflowAudioBytes.position);
						overflowAudioBytes.writeBytes(_audioPES[i].data,_audioPES[i].payload,_audioPES[i].data.length-_audioPES[i].payload);
						//trace("overflowAudioBytes.length="+overflowAudioBytes.length);
						//trace("_audioPES[i].data.length="+_audioPES[i].data.length);
						_audioPES[i].data.position = _audioPES[i].payload;
						_audioPES[i].data.writeBytes(overflowAudioBytes,0,overflowAudioBytes.length);
						//trace("_audioPES[i].data.length="+_audioPES[i].data.length);
					}
                }
                // Store ADTS frames in array.
                frames = AAC.getFrames(_audioPES[i].data,_audioPES[i].payload);
				//trace("frames.length = "+frames.length);
				// Correct for Segmenter's "optimize", which cuts frames in half.
				overflowAudio = frames[frames.length-1].start +
					frames[frames.length-1].length - _audioPES[i].data.length;
				//trace("overflowAudio = "+overflowAudio);
				for(var j:Number=0; j< frames.length; j++) {
					//trace("frame "+j+": start="+frames[j].start+",end="+(frames[j].start+frames[j].length));
                    // Increment the timestamp of subsequent frames.
					//trace("frames["+j+"].rate "+frames[j].rate+", overflow = "+overflowAudio);
					stamp = Math.round(_audioPES[i].pts + j * 1024 * 1000 / frames[j].rate);
					
					// Add a codecprivate tag if the frame rate has changed
					if( frames[j].rate != currentRate ){
						var adifTag:Tag = new Tag(Tag.AAC_HEADER,stamp,stamp,true);
						var adif:ByteArray = AAC.getADIF(_audioPES[i].data,_audioPES[i].payload);
						adifTag.push(adif,0,2)
						audioTags.push(adifTag);
					}
					currentRate = frames[j].rate;
					
					tag = new Tag(Tag.AAC_RAW, stamp,stamp,false);
                    if(i == _audioPES.length-1 && j == frames.length - 1) {
						// copy beginning of last (overflowing) frame
						if(overflowAudio > 0) {
							overflowAudioBytes = new ByteArray();
							overflowAudioBytes.writeBytes(_audioPES[i].data, frames[j].start-7, 0);
							//trace("overflowAudioBytes.length="+overflowAudioBytes.length+", overflowAudioBytes.position="+overflowAudioBytes.position);
							//trace("last frame length = "+frames[j].length);
						}
						else {
							tag.push(_audioPES[i].data, frames[j].start, _audioPES[i].data.length - frames[j].start);
						}
						
                    } else { 
                        tag.push(_audioPES[i].data, frames[j].start, frames[j].length);
                    }
                    audioTags.push(tag);
                }
            }
        };


        /** Read MPEG data from audio PES streams. **/
        private function _readMPEG():void {
            var tag:Tag;
            for(var i:Number=0; i<_audioPES.length; i++) {
                _audioPES[i].parse();
                tag = new Tag(Tag.MP3_RAW, _audioPES[i].pts,_audioPES[i].dts, false);
				tag.push(_audioPES[i].data, _audioPES[i].payload, _audioPES[i].data.length-_audioPES[i].payload);
                audioTags.push(tag);
            }
        };


        /** Read NALU frames from video PES streams. **/
        private function _readNALU():void {
            var units:Array;
            var last:Number;
            for(var i:Number=0; i<_videoPES.length; i++) {
                // Parse the PES headers and NAL units.
                try { 
                    _videoPES[i].parse();
                } catch (error:Error) {
                    Log.txt(error.message);
                    continue;
                }
                units = AVC.getNALU(_videoPES[i].data,_videoPES[i].payload);
                // If there's no NAL unit, push all data in the previous tag.
                if(!units.length) {
                    videoTags[videoTags.length-1].push(_videoPES[i].data, _videoPES[i].payload,
                        _videoPES[i].data.length - _videoPES[i].payload);
                    continue;
                }
                // If NAL units are offset, push preceding data into the previous tag.
                overflowVideo = units[0].start - units[0].header - _videoPES[i].payload;
                if(overflowVideo && (videoTags.length != 0) ) {
                    videoTags[videoTags.length-1].push(_videoPES[i].data,_videoPES[i].payload,overflowVideo);
                }
                videoTags.push(new Tag(Tag.AVC_NALU,_videoPES[i].pts,_videoPES[i].dts,false));
                // Only push NAL units 1 to 5 into tag.
                for(var j:Number = 0; j < units.length; j++) {
                    if (units[j].type < 6) {
						//trace("units["+j+"] type = "+units[j].type+", header = "+units[j].header);
                        videoTags[videoTags.length-1].push(_videoPES[i].data,units[j].start,units[j].length);
                        // Unit type 5 indicates a keyframe.
                        if(units[j].type == 5) {
                            videoTags[videoTags.length-1].keyframe = true;
                            if(_firstKey == -1) {
                                _firstKey = i;
                            }
                        }
                    }
                }
            }
        };


        /** Read TS packet. **/
        private function _readPacket(dat:ByteArray):void {
            // Each packet is 188 bytes.
            var todo:uint = TS.PACKETSIZE;
            // Sync byte.
            if(dat.readByte() != TS.SYNCBYTE) {
                throw new Error("Could not parse TS file: sync byte not found.");
            }
            todo--;
            // Payload unit start indicator.
            var stt:uint = (dat.readUnsignedByte() & 64) >> 6;
            dat.position--;
            // Packet ID (last 13 bits of UI16).
            var pid:uint = dat.readUnsignedShort() & 8191;
            // Check for adaptation field.
            todo -=2;
            var atf:uint = (dat.readByte() & 48) >> 4;
			// Read continuity counter
			dat.position--;
			var cc:uint = dat.readUnsignedByte() & 15;
            todo --;
			//trace("stt = "+stt+", cont count = "+cc+", pid = "+pid+", atf = "+atf);
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
                    return;
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
                case _aacId:
                case _mp3Id:
                    pes.writeBytes(dat,dat.position,todo);
                    if(stt) {
                        _audioPES.push(new PES(pes,true));
                    } else if (_audioPES.length) {
                        _audioPES[_audioPES.length-1].append(pes);
                    } else {
                        Log.txt("Discarding TS audio packet with id "+pid);
						//trace("Discarding TS audio packet with id "+pid);
                    }
                    break;
                case _avcId:
                    pes.writeBytes(dat,dat.position,todo);
                    if(stt) {
                        _videoPES.push(new PES(pes,false));
                    } else if (_videoPES.length) {
                        _videoPES[_videoPES.length-1].append(pes);
                    } else {
                        Log.txt("Discarding TS video packet with id "+pid);
						//trace("Discarding TS video packet with id "+pid);
                    }
                    break;
                default:
                    // Ignored other packet IDs
                    Log.txt("Discarding unassignable TS packets with id "+pid);
					//trace("Discarding unassignable TS packets with id "+pid);
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
					//trace("aacId = "+sid);
                } else if (typ == 0x1B) {
                    _avcId = sid;
					//trace("avcId = "+sid);
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