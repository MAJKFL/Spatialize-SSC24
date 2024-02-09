//
//  EditorSceneView.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SceneKit

class EditorSceneView: SCNView {
    func setup(viewModel: EditorViewModel) {
        let scene = EditorScene()
        self.scene = scene
        scene.create(viewModel: viewModel)
        self.allowsCameraControl = true
        self.defaultCameraController.maximumVerticalAngle = 90
        self.defaultCameraController.minimumVerticalAngle = -15
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc func pinchGesture(_ sender: UIPinchGestureRecognizer) {}
}
