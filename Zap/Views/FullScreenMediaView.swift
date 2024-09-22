//
//  FullScreenMediaView.swift
//  Zap
//
//  Created by Zigao Wang on 9/22/24.
//

import SwiftUI
import AVKit

struct FullScreenMediaView: View {
    let note: NoteItem
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            switch note.type {
            case .photo(let url):
                PhotoFullScreenView(url: url)
            case .video(let url, _):
                VideoFullScreenView(url: url)
            default:
                EmptyView()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct PhotoFullScreenView: View {
    let url: URL
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(uiImage: UIImage(contentsOfFile: url.path) ?? UIImage())
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = value.magnitude
                    }
            )
    }
}

struct VideoFullScreenView: View {
    let url: URL

    var body: some View {
        VideoPlayer(player: AVPlayer(url: url))
    }
}

struct FullScreenMediaView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenMediaView(note: NoteItem(id: UUID(), timestamp: Date(), type: .photo(URL(fileURLWithPath: ""))), isPresented: .constant(true))
    }
}