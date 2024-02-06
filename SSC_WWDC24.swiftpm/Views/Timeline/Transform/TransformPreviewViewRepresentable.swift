//
//  TransformPreviewViewRepresentable.swift
//
//
//  Created by Jakub Florek on 03/02/2024.
//

import SwiftUI
import SceneKit

struct TransformPreviewViewRepresentable: UIViewRepresentable {
    let previewNode: SCNNode
    let pathPreviewNodes: [SCNNode]
    let radiusBox: SCNNode
    
    func makeUIView(context: Context) -> SCNView {
        let view = TransformPreviewSceneView()
        view.setup(previewNode: previewNode, pathPreviewNodes: pathPreviewNodes, radiusBox: radiusBox)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
    }
}
