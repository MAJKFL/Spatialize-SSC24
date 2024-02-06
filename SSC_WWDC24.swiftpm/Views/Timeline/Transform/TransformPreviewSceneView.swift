//
//  TransformPreviewSceneView.swift
//  
//
//  Created by Jakub Florek on 03/02/2024.
//

import SceneKit

class TransformPreviewSceneView: SCNView {
    func setup(previewNode: SCNNode, pathPreviewNodes: [SCNNode], radiusBox: SCNNode) {
        let scene = TransformPreviewScene()
        scene.create(previewNode: previewNode, pathPreviewNodes: pathPreviewNodes, radiusBox: radiusBox)
        self.scene = scene
        self.allowsCameraControl = false
    }
}
