//
//  RemoteImageView.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 16/10/2026.
//

import SwiftUI
import UIKit

private enum RemoteImagePhase {
    case idle
    case loading
    case success(Image)
    case failure
}

struct RemoteImageView: View {
    let url: URL?
    @Environment(\.imagePipeline) private var imagePipeline
    @State private var phase: RemoteImagePhase = .idle

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.19, green: 0.22, blue: 0.30),
                            Color(red: 0.41, green: 0.48, blue: 0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            content
        }
        .clipShape(.rect(cornerRadius: 20))
        .task(id: url) {
            await loadImage()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .idle, .loading:
            ProgressView()
                .tint(.white)
        case .success(let image):
            image
                .resizable()
                .scaledToFill()
                .transition(.opacity)
        case .failure:
            VStack(spacing: 10) {
                Image(systemName: "photo.badge.exclamationmark")
                    .font(.system(size: 28))
                Text("Image unavailable")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
        }
    }

    @MainActor
    private func loadImage() async {
        guard let url else {
            phase = .failure
            return
        }

        phase = .loading

        do {
            let data = try await imagePipeline.imageData(for: url)
            try Task.checkCancellation()

            guard let image = UIImage(data: data) else {
                phase = .failure
                return
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                phase = .success(Image(uiImage: image))
            }
        } catch is CancellationError {
            return
        } catch {
            phase = .failure
        }
    }
}
