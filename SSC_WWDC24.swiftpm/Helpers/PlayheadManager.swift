//
//  PlayheadManager.swift
//  PHASing
//
//  Created by Jakub Florek on 09/12/2023.
//

import SwiftUI
import Combine

@Observable 
class PlayheadManager {
    var project: Project
    
    private(set) var offset: Double = 0
    
    private(set) var isPlaying = false
    
    private var mainTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(project: Project) {
        self.project = project
        
        mainTimer
            .sink(receiveValue: onTimerReceive)
            .store(in: &cancellables)
    }
    
    private func onTimerReceive(_ output: Timer.TimerPublisher.Output) {
        if isPlaying {
            offset += Double(project.bpm) / 6000 * Constants.fullBeatWidth
        }
    }
    
    func toggle() {
        isPlaying.toggle()
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
}
