//
//  ImagePipelineEnvironment.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 18/10/2026.
//

import SwiftUI

struct ImagePipelineEnvironment: EnvironmentKey {
    static let defaultValue = FeedImagePipeline()
}

extension EnvironmentValues {
    var imagePipeline: FeedImagePipeline {
        get { self[ImagePipelineEnvironment.self] }
        set { self[ImagePipelineEnvironment.self] = newValue }
    }
}
