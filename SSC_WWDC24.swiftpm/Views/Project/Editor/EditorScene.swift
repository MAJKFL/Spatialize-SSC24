//
//  EditorScene.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SceneKit
import Combine

/// 3D speaker node visualiser scene.
class EditorScene: SCNScene {
    /// View model of the 3D editor.
    var viewModel: EditorViewModel!
    
    /// Cancellables used by combine listeners.
    private var cancellables = Set<AnyCancellable>()
    
    /// Creates a new scene for specified view model.
    func create(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        
        background.contents = UIColor.black
        
        createListenerRepresentation()
        createPlane()
        createCamera()
        createDirectionIndicator()
        
        viewModel.$speakerNodes
            .sink { nodes in
                self.updateNodes(nodes)
            }
            .store(in: &cancellables)
    }
    
    /// Updates speaker nodes visible on the screen.
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
    
    /// Creates orbiting camera.
    private func createCamera() {
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3(x: 90, y: 50, z: 100)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(cameraNode)
    }
    
    /// Creates checked plane.
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
    
    /// Creates spherical listener representation at the center.
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
    
    /// Creates the listener direction arrow.
    private func createDirectionIndicator() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        let cone = SCNCone()
        cone.materials = [material]
        
        let conePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: cone))
        conePhysicsBody.isAffectedByGravity = false
        
        let coneNode = SCNNode(geometry: cone)
        coneNode.physicsBody = conePhysicsBody
        coneNode.position = SCNVector3(0, 0, -35)
        coneNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, -Double.pi / 2)
        coneNode.scale = SCNVector3(10, 7.5, 10)
        
        let cylinder = SCNCylinder()
        cylinder.materials = [material]
        
        let cylinderPhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: cylinder))
        cylinderPhysicsBody.isAffectedByGravity = false
        
        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.physicsBody = cylinderPhysicsBody
        cylinderNode.position = SCNVector3(0, 0, -30)
        cylinderNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, -Double.pi / 2)
        cylinderNode.scale = SCNVector3(4, 12, 4)

        rootNode.addChildNode(coneNode)
        rootNode.addChildNode(cylinderNode)
    }
}
