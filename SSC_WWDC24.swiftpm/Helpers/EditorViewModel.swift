//
//  EditorViewModel.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import Foundation
import PHASE

class EditorViewModel: ObservableObject {
    @Published var speakerNodes = [SpeakerNode]()
    
    let phaseEngine: PHASEEngine
    let listener: PHASEListener
    let spatialMixerDefinition: PHASESpatialMixerDefinition
    
    var registeredAssetIDs = [String]()
    var hasBeenPlayed = [String]()
    
    init() {
        phaseEngine = PHASEEngine(updateMode: .automatic)
        phaseEngine.defaultReverbPreset = .largeRoom
        
        listener = PHASEListener(engine: phaseEngine)
        listener.transform = matrix_identity_float4x4;
        listener.transform.columns.3 = simd_make_float4(0, 4.5, 0, 1)
        try? phaseEngine.rootObject.addChild(listener)
        
        let spatialPipelineOptions: PHASESpatialPipeline.Flags = [.directPathTransmission, .lateReverb]
        let spatialPipeline = PHASESpatialPipeline(flags: spatialPipelineOptions)!
        spatialPipeline.entries[PHASESpatialCategory.lateReverb]!.sendLevel = 0.1
        
        spatialMixerDefinition = PHASESpatialMixerDefinition(spatialPipeline: spatialPipeline)
        
        let distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
        distanceModelParameters.fadeOutParameters = PHASEDistanceModelFadeOutParameters(cullDistance: 80)
        distanceModelParameters.rolloffFactor = 0.8
        spatialMixerDefinition.distanceModelParameters = distanceModelParameters
    }
    
    func setSpeakerNodes(for nodes: [Node]) {
        speakerNodes.removeAll(where: { speakerNode in
            !nodes.contains(where: { node in
                node.id.uuidString == speakerNode.name
            })
        })
        
        for node in nodes {
            guard !speakerNodes.contains(where: { $0.name == node.id.uuidString }) else { continue }
            
            let source = PHASESource(engine: phaseEngine)
            source.transform = matrix_identity_float4x4
            try! phaseEngine.rootObject.addChild(source)
            let sphereNode = SpeakerNode(nodeModel: node, phaseEngine: phaseEngine, phaseSource: source)
            
            speakerNodes.append(sphereNode)
        }
    }
    
    func onNodeColorChange(_ node: Node) {
        speakerNodes.first(where: { $0.name == node.id.uuidString })?.geometry?.firstMaterial?.diffuse.contents = node.uiColor
    }
    
    func updateSpeakerNodePosition(playheadOffset offset: Double) {
        for speakerNode in speakerNodes {
            speakerNode.updatePosition(playheadOffset: offset)
            
            if let currentTrack = speakerNode.nodeModel.tracks.first(where: { $0.start.isEqualTo(to: offset, withPrecision: 2) }) {
                let id = currentTrack.id.uuidString + "-event"
                
                if !hasBeenPlayed.contains(id) {
                    let mixerParameters = PHASEMixerParameters()
                    mixerParameters.addSpatialMixerParameters(identifier: spatialMixerDefinition.identifier, source: speakerNode.phaseSource, listener: listener)
                    
                    let soundEvent = try! PHASESoundEvent(engine: phaseEngine, assetIdentifier: id, mixerParameters: mixerParameters)
                    
                    soundEvent.start()
                    hasBeenPlayed.append(id)
                }
            }
        }
    }
    
    /// Registering all audio assets, should be run once when resuming playback
    func registerAudioAssets(playheadOffset offset: Double, bpm: Int) {
        for id in registeredAssetIDs {
            if id.contains("event") {
                let soundEvent = try? PHASESoundEvent(engine: phaseEngine, assetIdentifier: id)
                soundEvent?.stopAndInvalidate()
            }
            
            phaseEngine.assetRegistry.unregisterAsset(identifier: id, completion: nil)
        }
        
        registeredAssetIDs = [String]()
        hasBeenPlayed = [String]()
        
        let tracks = speakerNodes.flatMap({ $0.nodeModel.tracks })
        
        for track in tracks {
            let width = Constants.trackWidth(track, bpm: bpm)
            guard offset <= track.start + width else { continue }
            
            do {
                let url = track.fileURL
                
                let _ = try phaseEngine.assetRegistry.registerSoundAsset(url: url, identifier: track.id.uuidString, assetType: .streamed, channelLayout: .init(layoutTag: kAudioChannelLayoutTag_Stereo), normalizationMode: .dynamic)
                
                let samplerNodeDefinition = PHASESamplerNodeDefinition(soundAssetIdentifier: track.id.uuidString, mixerDefinition: spatialMixerDefinition)
                samplerNodeDefinition.playbackMode = .oneShot
                samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: 0)
                samplerNodeDefinition.cullOption = .sleepWakeAtRealtimeOffset
                
                let id = track.id.uuidString + "-event"
                let _ = try phaseEngine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: id)
                
                registeredAssetIDs.append(track.id.uuidString)
                registeredAssetIDs.append(id)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func startEngine(atOffset offset: Double, bpm: Int) {
        try! phaseEngine.start()
        
        for speakerNode in speakerNodes {
            speakerNode.updatePosition(playheadOffset: offset)
            
            if let currentTrack = speakerNode.nodeModel.tracks.first(where: { $0.start <= offset && $0.start + Constants.trackWidth($0, bpm: bpm) >= offset }) {
                let id = currentTrack.id.uuidString + "-event"
                
                let mixerParameters = PHASEMixerParameters()
                mixerParameters.addSpatialMixerParameters(identifier: spatialMixerDefinition.identifier, source: speakerNode.phaseSource, listener: listener)
                
                let soundEvent = try! PHASESoundEvent(engine: phaseEngine, assetIdentifier: id, mixerParameters: mixerParameters)
                soundEvent.seek(to: currentTrack.trackLength * ((offset - currentTrack.start) / Constants.trackWidth(currentTrack, bpm: bpm)))
                soundEvent.start()
                hasBeenPlayed.append(id)
            }
        }
    }
    
    func stopEngine() {
        phaseEngine.stop()
    }
}

extension Double {
    func isEqualTo(to b: Double, withPrecision precision: Double) -> Bool {
        return abs(self - b) <= precision
    }
}
