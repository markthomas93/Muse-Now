//
//  AVAudio+.swift
//  Klio
//
//  Created by warren on 9/6/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import AVFoundation

func Pcm2Data(_ pcm: AVAudioPCMBuffer) -> NSData {
    let channelCount = 1  // given PCMBuffer channel count is 1
    let channels = UnsafeBufferPointer(start: pcm.floatChannelData, count: channelCount)
    let data = NSData(bytes: channels[0], length:Int(pcm.frameCapacity * pcm.format.streamDescription.pointee.mBytesPerFrame))
    return data
}

func Data2Pcm(_ data: NSData) -> AVAudioPCMBuffer {
    let audioFormat = AVAudioFormat(commonFormat:.pcmFormatFloat32, sampleRate: 1024, channels: 1, interleaved: false)  // given NSData audio format
    let capacity = UInt32(data.length) / (audioFormat?.streamDescription.pointee.mBytesPerFrame)!
    let pcm = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: capacity)!
    pcm.frameLength = pcm.frameCapacity
    let channels = UnsafeBufferPointer(start: pcm.floatChannelData, count: Int(pcm.format.channelCount))
    data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
    return pcm
}
