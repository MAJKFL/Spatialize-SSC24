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
    
    let phaseEngine = PHASEEngine(updateMode: .automatic)
    
    var registeredAssetIDs = [String]()
    var hasBeenPlayed = [String]()
    
    func setSpeakerNodes(for nodes: [Node]) {
        speakerNodes.removeAll(where: { speakerNode in
            !nodes.contains(where: { node in
                node.id.uuidString == speakerNode.name
            })
        })
        
        for node in nodes {
            guard !speakerNodes.contains(where: { $0.name == node.id.uuidString }) else { continue }
            
            let sphereNode = SpeakerNode(nodeModel: node)
            
            speakerNodes.append(sphereNode)
        }
    }
    
    func onNodeColorChange(_ node: Node) {
        speakerNodes.first(where: { $0.name == node.id.uuidString })?.geometry?.firstMaterial?.diffuse.contents = node.uiColor
    }
    
    func updateSpeakerNodePosition(playheadOffset offset: Double) {
        for speakerNode in speakerNodes {
            let position = speakerNode.updatePosition(playheadOffset: offset)
            
            if let currentTrack = speakerNode.nodeModel.tracks.first(where: { $0.start.isEqualTo(to: offset, withPrecision: 2) }) {
                let id = currentTrack.id.uuidString + "-event"
                
                if !hasBeenPlayed.contains(id) {
                    let soundEvent = try! PHASESoundEvent(engine: phaseEngine, assetIdentifier: id)
                    soundEvent.start()
                    hasBeenPlayed.append(id)
                }
            }
        }
    }
    
    /// Registering all audio assets, should be run once when resuming playback
    func registerAudioAssets(playheadOffset offset: Double, bpm: Int, completion: @escaping (Bool) -> ()) {
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
                
                let soundAsset = try phaseEngine.assetRegistry.registerSoundAsset(url: url, identifier: track.id.uuidString, assetType: .streamed, channelLayout: .init(layoutTag: kAudioChannelLayoutTag_Stereo), normalizationMode: .dynamic)
                
                let channelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Stereo)!
                
                let channelMixerDefinition = PHASEChannelMixerDefinition(channelLayout: channelLayout)
                
                let samplerNodeDefinition = PHASESamplerNodeDefinition(soundAssetIdentifier: track.id.uuidString, mixerDefinition: channelMixerDefinition)
                
                samplerNodeDefinition.playbackMode = .oneShot
                
                samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: 0)
                
                let id = track.id.uuidString + "-event"
                let soundEventAsset = try phaseEngine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: id)
                
                registeredAssetIDs.append(track.id.uuidString)
                registeredAssetIDs.append(id)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        completion(true)
    }
    
    func startEngine(atOffset offset: Double, bpm: Int) {
        try! phaseEngine.start()
        
        for speakerNode in speakerNodes {
            let position = speakerNode.updatePosition(playheadOffset: offset)
            
            if let currentTrack = speakerNode.nodeModel.tracks.first(where: { $0.start <= offset && $0.start + Constants.trackWidth($0, bpm: bpm) >= offset }) {
                let id = currentTrack.id.uuidString + "-event"
                
                let soundEvent = try! PHASESoundEvent(engine: phaseEngine, assetIdentifier: id)
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
