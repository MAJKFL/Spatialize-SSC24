//
//  EditorScene.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SceneKit
import Combine

class EditorScene: SCNScene {
    var viewModel: EditorViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    func create(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        
        background.contents = UIColor.black
        
        createListenerRepresentation()
        createPlane()
        createCamera()
        
        viewModel.$speakerNodes
            .sink { nodes in
                self.updateNodes(nodes)
            }
            .store(in: &cancellables)
    }
    
    private func updateNodes(_ nodes: [SCNNode]) {
        for node in rootNode.childNodes {
            guard let node = node as? SpeakerNode else { continue }
            
            if !nodes.contains(where: { $0.name == node.name }) {
                node.removeFromParentNode()
            }
        }
        
        for node in nodes {
            if !rootNode.childNodes.contains(where: { $0.name == node.name }) {
                rootNode.addChildNode(node)
            }
        }
    }
    
    private func createCamera() {
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3(x: 100, y: 50, z: -70)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(cameraNode)
    }
    
    private func createPlane() {
        let boxGeometry = SCNBox(width: 120, height: 0.5 , length: 120, chamferRadius: 0)
        
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIImage(named: "PlaneTexture")
        boxGeometry.materials = [boxMaterial]
        
        let boxPhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: boxGeometry))
        
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "ground"
        boxNode.position = SCNVector3(0, 0, 0)
        boxNode.physicsBody = boxPhysicsBody
        
        rootNode.addChildNode(boxNode)
    }
    
    private func createListenerRepresentation() {
        let sphereGeometry = SCNSphere(radius: 4)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.green
        sphereGeometry.materials = [sphereMaterial]
        
        let spherePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sphereGeometry))
        spherePhysicsBody.isAffectedByGravity = false
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.name = "listener"
        sphereNode.position = SCNVector3(0, 4.5, 0)
        sphereNode.physicsBody = spherePhysicsBody
        
        rootNode.addChildNode(sphereNode)
    }
}
