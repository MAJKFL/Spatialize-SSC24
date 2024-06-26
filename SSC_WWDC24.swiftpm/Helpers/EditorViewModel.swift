//
//  EditorViewModel.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import Foundation
import PHASE

/// Manges speaker nodes in the editor
class EditorViewModel: ObservableObject {
    /// Speaker nodes visible in the editor.
    @Published var speakerNodes = [SpeakerNode]()
    /// Current playhead manager.
    @Published var playheadManager: PlayheadManager
    
    /// Engine used for playback.
    private let phaseEngine: PHASEEngine
    /// Audio receiver. Used internally by the phaseEngine.
    private let listener: PHASEListener
    /// Spatial mixer definition used for specifying audio profile in 3d space.
    private let spatialMixerDefinition: PHASESpatialMixerDefinition
    
    /// Events registered in the engine.
    private var eventIDs = [String]()
    /// IDs of event's that has already been played.
    private var hasBeenPlayed = [String]()
    
    /// Specifies wheter some tracks should play solo.
    var soloMode = false
    
    /// Initializes a new EditorViewModel with current playheadManager
    init(playheadManager: PlayheadManager) {
        self.playheadManager = playheadManager
        
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
        distanceModelParameters.rolloffFactor = 0.5
        spatialMixerDefinition.distanceModelParameters = distanceModelParameters
        
        try! phaseEngine.start()
    }
    
    /// Updates the speaker nodes currently visible in the editor.
    func setSpeakerNodes(for nodes: [Node]) {
        for speakerNode in speakerNodes {
            if !nodes.contains(where: { $0.id == speakerNode.nodeModel.id }) {
                speakerNodes.removeAll(where: { $0.nodeModel.id == speakerNode.nodeModel.id })
            }
        }
        
        for node in nodes {
            guard !speakerNodes.contains(where: { $0.name == node.id.uuidString }) else { continue }
            
            let source = PHASESource(engine: phaseEngine)
            source.transform = matrix_identity_float4x4
            try! phaseEngine.rootObject.addChild(source)
            let sphereNode = SpeakerNode(nodeModel: node, phaseEngine: phaseEngine, phaseSource: source)
            
            soloMode = soloMode || node.isSolo
            
            speakerNodes.append(sphereNode)
        }
    }
    
    /// Updates speaker node color.
    func onNodeColorChange(_ node: Node) {
        speakerNodes.first(where: { $0.name == node.id.uuidString })?.geometry?.firstMaterial?.diffuse.contents = node.uiColor
    }
    
    /// Updates position of all speaker nodes at given playhead offset.
    func updateSpeakerNodePosition(playheadOffset offset: Double) {
        for speakerNode in speakerNodes {
            speakerNode.updatePosition(playheadOffset: offset, nodePosition: speakerNode.nodeModel.position)
            
            let areOtherSolo = soloMode && !speakerNode.nodeModel.isSolo
            
            speakerNode.phaseSource.gain = speakerNode.nodeModel.isPlaying && !areOtherSolo ? speakerNode.nodeModel.volume : 0
            
            guard playheadManager.isPlaying else { continue }
            
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
    
    /// Registers tracks in the engine.
    func registerTracks(_ tracks: [Track]) {
        for track in tracks {
            guard !eventIDs.contains(track.id.uuidString + "-event") else { continue }
            
            do {
                let url = track.fileURL
                
                let _ = try phaseEngine.assetRegistry.registerSoundAsset(url: url, identifier: track.id.uuidString, assetType: .streamed, channelLayout: .init(layoutTag: kAudioChannelLayoutTag_Stereo), normalizationMode: .dynamic)
                
                let samplerNodeDefinition = PHASESamplerNodeDefinition(soundAssetIdentifier: track.id.uuidString, mixerDefinition: spatialMixerDefinition)
                samplerNodeDefinition.playbackMode = .oneShot
                samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: 0)
                samplerNodeDefinition.cullOption = .sleepWakeAtRealtimeOffset
                
                let id = track.id.uuidString + "-event"
                let _ = try phaseEngine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: id)
                
                eventIDs.append(id)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Starts or resumes the playback depending wheter it should seek the audio events.
    func startOrResumePlayback(atOffset offset: Double, bpm: Int, shouldSeek: Bool) {
        if shouldSeek {
            hasBeenPlayed = [String]()
            
            phaseEngine.soundEvents.forEach { event in
                event.stopAndInvalidate()
            }
            
            for speakerNode in speakerNodes {
                speakerNode.updatePosition(playheadOffset: offset, nodePosition: speakerNode.nodeModel.position)
                
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
        } else {
            phaseEngine.soundEvents.forEach { event in
                event.resume()
            }
        }
    }
    
    /// Pauses all events.
    func pausePlayback() {
        phaseEngine.soundEvents.forEach { event in
            event.pause()
        }
    }
}

extension Double {
    /// Checks if two doubles are equal with given precision.
    func isEqualTo(to b: Double, withPrecision precision: Double) -> Bool {
        return abs(self - b) <= precision
    }
}
