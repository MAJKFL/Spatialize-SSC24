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
    var offset: Double = 0
    
    private(set) var isPlaying = false
    
    private var mainTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        mainTimer
            .sink(receiveValue: onTimerReceive)
            .store(in: &cancellables)
    }
    
    private func onTimerReceive(_ output: Timer.TimerPublisher.Output) {
        if isPlaying {
            offset += 1
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
}
