//
//  TransformPreviewSceneView.swift
//  
//
//  Created by Jakub Florek on 03/02/2024.
//

import SceneKit

class TransformPreviewSceneView: SCNView {
    func setup(previewNode: SCNNode, pathPreviewNodes: [SCNNode]) {
        let scene = TransformPreviewScene()
        scene.create(previewNode: previewNode, pathPreviewNodes: pathPreviewNodes)
        self.scene = scene
        self.allowsCameraControl = false
    }
}
