//
//  SpeakerNode.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SceneKit
import PHASE

class SpeakerNode: SCNNode {
    var id: ObjectIdentifier {
        nodeModel.id
    }
    
    var nodeModel: Node!
    var phaseEngine: PHASEEngine!
    var phaseSource: PHASESource!
    var spatialMixerDefinition: PHASESpatialMixerDefinition!
    var listener: PHASEListener!
    
    var positionsOverTime = [SCNVector3]()
    var phasePositionsOverTime = [simd_float4]()
    var sortedTracks = [Track]()
    
    init(nodeModel: Node, phaseEngine: PHASEEngine, phaseSource: PHASESource, spatialMixerDefinition: PHASESpatialMixerDefinition, listener: PHASEListener) {
        super.init()
        self.nodeModel = nodeModel
        self.phaseEngine = phaseEngine
        self.phaseSource = phaseSource
        self.spatialMixerDefinition = spatialMixerDefinition
        self.listener = listener
        
        let sphereGeometry = SCNSphere(radius: 3)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = nodeModel.uiColor
        sphereGeometry.materials = [sphereMaterial]
        
        let spherePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sphereGeometry))
        spherePhysicsBody.isAffectedByGravity = false
        
        self.name = nodeModel.id.uuidString
        self.geometry = sphereGeometry
        self.physicsBody = spherePhysicsBody
        
        self.position = nodeModel.startingPosition
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Changes position using efficient lookup of the positions in the table
    func updatePosition(playheadOffset offset: Double) {
        let offsetIndex = Int(offset)
        
        guard positionsOverTime.count > offsetIndex else { return }
        
        position = positionsOverTime[offsetIndex]
        phaseSource.transform.columns.3 = phasePositionsOverTime[offsetIndex]
        
        if let track = sortedTracks.first, track.start <= offset {
            let id = track.id.uuidString + "-event"
            
            let mixerParameters = PHASEMixerParameters()
            mixerParameters.addSpatialMixerParameters(identifier: spatialMixerDefinition.identifier, source: phaseSource, listener: listener)
            
            let soundEvent = try! PHASESoundEvent(engine: phaseEngine, assetIdentifier: id, mixerParameters: mixerParameters)
            
            soundEvent.start()
            
            sortedTracks.removeFirst()
        }
    }
    
    /// Prepares all positions beforehand for later faster access
    func update(currentPlayheadOffset: Double, maxPlayheadOffset: Double) async {
        positionsOverTime = []
        phasePositionsOverTime = []
        positionsOverTime.reserveCapacity(Int(ceil(maxPlayheadOffset)))
        phasePositionsOverTime.reserveCapacity(Int(ceil(maxPlayheadOffset)))
        
        var newPosition = await getPosition(atOffset: 0, previousPosition: nodeModel.startingPosition)
        positionsOverTime.append(newPosition)
        phasePositionsOverTime.append(simd_make_float4(newPosition.x, newPosition.y, newPosition.z, 1.0))
        
        for offset in stride(from: 1.0, to: ceil(maxPlayheadOffset), by: 1.0) {
            newPosition = await getPosition(atOffset: offset, previousPosition: newPosition)
            positionsOverTime.append(newPosition)
            phasePositionsOverTime.append(simd_make_float4(newPosition.x, newPosition.y, newPosition.z, 1.0))
        }
    }
    
    func updateTracks(currentPlayheadOffset: Double) {
        sortedTracks = []
        
        nodeModel.tracks.filter({ $0.start > currentPlayheadOffset }).sorted(by: { $0.start < $1.start }).forEach { track in
            sortedTracks.append(track)
        }
    }
    
    func updatePrecalculatedPositions(from: Double, to: Double) async {
        guard Int(from) < positionsOverTime.count else { return }
        
        let fromIndex = round(from)
        
        var prevPosition: SCNVector3
        
        if fromIndex > 0 {
            prevPosition = positionsOverTime[Int(fromIndex) - 1]
        } else {
            prevPosition = nodeModel.startingPosition
        }
        
        var newPosition = await getPosition(atOffset: fromIndex, previousPosition: prevPosition)
        positionsOverTime[Int(fromIndex)] = newPosition
        phasePositionsOverTime[Int(fromIndex)] = simd_make_float4(newPosition.x, newPosition.y, newPosition.z, 1.0)
        
        for offset in stride(from: fromIndex + 1, to: ceil(to), by: 1.0) {
            newPosition = await getPosition(atOffset: offset, previousPosition: newPosition)
            positionsOverTime[Int(offset)] = newPosition
            phasePositionsOverTime[Int(offset)] = simd_make_float4(newPosition.x, newPosition.y, newPosition.z, 1.0)
        }
    }
    
    /// Calculates position for specified offset
    private func getPosition(atOffset offset: Double, previousPosition: SCNVector3) async -> SCNVector3 {
        let previousTransform = nodeModel.transforms
            .filter { trans in
                trans.start + trans.length < offset
            }
            .max(by: { $0.start + $0.length < $1.start + $1.length })
        
        if let currentTransform = nodeModel.transforms.first(where: { $0.start <= offset && $0.start + $0.length >= offset }) {
            return currentTransform.getPositionFor(playheadOffset: offset, currentPosition: previousPosition, source: previousTransform?.endPosition ?? nodeModel.startingPosition)
        } else {
            if let previousTransform {
                return previousTransform.endPosition
            } else {
                return nodeModel.startingPosition
            }
        }
    }
}
