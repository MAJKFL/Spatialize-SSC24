//
//  PlayheadManager.swift
//  PHASing
//
//  Created by Jakub Florek on 09/12/2023.
//

import SwiftUI

/// Represents playhead on the timeline.
@Observable
class PlayheadManager {
    /// Current opened project.
    var project: Project
    
    /// Playhead offset.
    private(set) var offset: Double = 0
    
    /// Specifies whether the playhead is moving.
    private(set) var isPlaying = false
    
    /// Display link used to update the offset.
    private var displayLink: CADisplayLink!
    
    /// Is playhead at the origin.
    var isAtZero: Bool {
        offset == 0
    }
    
    /// Timestamp current playback started at.
    private var startTimestamp: CFTimeInterval = .zero
    /// Offset current playback started at.
    private var startOffset: Double = 0
    
    /// Initialize a new playhead manager for given project.
    init(project: Project) {
        self.project = project
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    /// Updates offset. Invoked by the display link.
    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        if isPlaying {
            offset = startOffset + Double(project.bpm) / 60 * Constants.fullBeatWidth * (displayLink.timestamp - startTimestamp)
        }
    }
    
    /// Toggles playhead updates.
    func toggle() {
        isPlaying.toggle()
        
        if isPlaying {
            startTimestamp = displayLink.timestamp
            startOffset = offset
        }
    }
    
    /// Pauses playhead updates.
    func pause() {
        isPlaying = false
    }
    
    /// Moves playhead to it's origin.
    func revert() {
        offset = 0
    }
    
    /// Moves playhead one beat forward.
    func jumpForward() {
        let beatWidth = Constants.fullBeatWidth
        offset += beatWidth
        offset -= offset.truncatingRemainder(dividingBy: beatWidth)
    }
    
    /// Moves playhead one beat before.
    func jumpBackward() {
        let beatWidth = Constants.fullBeatWidth
        if offset >= beatWidth {
            offset -= beatWidth
        }
        
        offset -= offset.truncatingRemainder(dividingBy: beatWidth)
    }
    
    /// Moves playhead to the specified beat.
    func jumpTo(_ beatNumber: Int) {
        let beatIndex = beatNumber - project.timeSignature.firstDigit
        offset = Double(beatIndex) * Constants.fullBeatWidth
    }
    
    /// Removes display link.
    deinit {
        displayLink.remove(from: .main, forMode: .common)
    }
}
