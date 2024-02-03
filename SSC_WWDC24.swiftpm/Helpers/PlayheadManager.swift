//
//  PlayheadManager.swift
//  PHASing
//
//  Created by Jakub Florek on 09/12/2023.
//

import SwiftUI

@Observable 
class PlayheadManager {
    var project: Project
    
    private(set) var offset: Double = 0
    
    private(set) var isPlaying = false
    
    private var displayLink: CADisplayLink!
    
    var isAtZero: Bool {
        offset == 0
    }
    
    private var startTimestamp: CFTimeInterval = .zero
    private var startOffset: Double = 0
    
    init(project: Project) {
        self.project = project
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        if isPlaying {
            offset = startOffset + Double(project.bpm) / 60 * Constants.fullBeatWidth * (displayLink.timestamp - startTimestamp)
        }
    }
    
    func toggle() {
        isPlaying.toggle()
        
        if isPlaying {
            startTimestamp = displayLink.timestamp
            startOffset = offset
        }
    }
    
    func pause() {
        isPlaying = false
    }
    
    func revert() {
        offset = 0
    }
    
    func jumpForward() {
        let beatWidth = Constants.singleBeatWidthFor(timeSignature: project.timeSignature)
        offset += beatWidth
        offset -= offset.truncatingRemainder(dividingBy: beatWidth)
    }
    
    func jumpBackward() {
        let beatWidth = Constants.singleBeatWidthFor(timeSignature: project.timeSignature)
        if offset >= beatWidth {
            offset -= beatWidth
        }
        
        offset -= offset.truncatingRemainder(dividingBy: beatWidth)
    }
    
    func jumpTo(_ beatNumber: Int) {
        let beatIndex = beatNumber - project.timeSignature.firstDigit
        offset = Double(beatIndex) * Constants.singleBeatWidthFor(timeSignature: project.timeSignature)
    }
    
    deinit {
        displayLink.remove(from: .main, forMode: .common)
    }
}
