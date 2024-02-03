//
//  TransformPreviewScene.swift
//  
//
//  Created by Jakub Florek on 03/02/2024.
//

import SceneKit

class TransformPreviewScene: SCNScene {
    var mainNode: SCNNode!
    
    func create(previewNode: SCNNode, pathPreviewNodes: [SCNNode]) {
        background.contents = UIColor.black
        
        mainNode = SCNNode()
        rootNode.addChildNode(mainNode)
        
        mainNode.addChildNode(previewNode)
        
        for node in pathPreviewNodes {
            mainNode.addChildNode(node)
        }
        
        createListenerRepresentation()
        createPlane()
        createCamera()
        createDirectionIndicator()
        
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 7))
        
        mainNode.runAction(action)
    }
    
    private func createCamera() {
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3(x: 75, y: 50, z: 85)
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
        
        mainNode.addChildNode(boxNode)
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
        
        mainNode.addChildNode(sphereNode)
    }
    
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

        mainNode.addChildNode(coneNode)
        mainNode.addChildNode(cylinderNode)
    }
}
