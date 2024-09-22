//
//  AudioNoteView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct AudioNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioFilename: URL?
    
    var body: some View {
        VStack {
            if isRecording {
                Text("正在录音...")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("录音")
                    .foregroundColor(.green)
                    .padding()
            }
            
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(isRecording ? .red : .green)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("新录音笔记")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
            
            let documentsDirectory = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            )[0]
            let filename = UUID().uuidString + ".m4a"
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            audioFilename = fileURL
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
        } catch {
            print("录音失败: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        if let url = audioFilename {
            // 获取持续时间
            let asset = AVURLAsset(url: url)
            let duration = CMTimeGetSeconds(asset.duration)
            viewModel.addAudioNote(url: url, duration: duration)
        }
        audioRecorder = nil
        audioFilename = nil
        presentationMode.wrappedValue.dismiss()
    }
}

struct AudioNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AudioNoteView()
            .environmentObject(NotesViewModel())
    }
}