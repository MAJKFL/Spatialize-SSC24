//
//  TransformPreviewViewRepresentable.swift
//
//
//  Created by Jakub Florek on 03/02/2024.
//

import SwiftUI
import SceneKit

/// SwiftUI 3D editor preview view representable.
struct TransformPreviewViewRepresentable: UIViewRepresentable {
    /// Node used in the 3D preview.
    let previewNode: SCNNode
    /// Nodes that create the path that describes the transform movement.
    let pathPreviewNodes: [SCNNode]
    /// Box that represents the radius of the random transform.
    let radiusBox: SCNNode
    
    /// Creates a new SceneKit view with specified previews.
    func makeUIView(context: Context) -> SCNView {
        let view = TransformPreviewSceneView()
        view.setup(previewNode: previewNode, pathPreviewNodes: pathPreviewNodes, radiusBox: radiusBox)
        return view
    }

    /// Updates the view.
    func updateUIView(_ uiView: SCNView, context: Context) {
    }
}
