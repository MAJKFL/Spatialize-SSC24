//
//  OnboardingView.swift
//  
//
//  Created by Jakub Florek on 10/02/2024.
//

import SwiftUI

/// Introduction to the features and controls of the app.
struct OnboardingView: View {
    /// Dismisses the sheet.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to\n**AudioFiller**")
                    .font(.largeTitle)
                
                Text("Fill Your World with Dynamic Soundscapes!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 40) {
                    HStack(spacing: 20) {
                        Image(systemName: "person.wave.2.fill")
                            .font(.largeTitle)
                            .scaledToFit()
                            .foregroundStyle(.green)
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("Spatial Mixing")
                                .font(.headline)
                            
                            Text("The app allows you to change positions of speakers around you to create your own, beautiful spatial soundscapes.")
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.largeTitle)
                            .scaledToFit()
                            .foregroundStyle(.red)
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("Setup")
                                .font(.headline)
                            
                            Text("To hear the playback please make sure your device is not silenced.")
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Image(systemName: "headphones")
                            .font(.largeTitle)
                            .scaledToFit()
                            .foregroundStyle(.blue)
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("Output")
                                .font(.headline)
                            
                            Text("For the best results consider using earphones that support spatial audio like e.g. AirPods Pro or AirPods Max. Though, the app will still work as long as your device's speakers support spatial audio.")
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                
                Spacer()
                
                NavigationLink(destination: speakerNodeTutorial) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.vertical, 60)
            .padding(.horizontal, 80)
        }
    }
    
    /// Explains how to use speaker nodes.
    private func speakerNodeTutorial() -> some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Basics")
                                .font(.largeTitle)
                                .bold()
                            
                            Text("How to use the app")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Listener")
                            .font(.title2)
                        
                        Image("OnboardingListener")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("Receives the speaker output. It's represented as the big, green sphere in the center of the editor plane. The green arrow shows the forward direction of the listener. Think of it as yourself hearing speakers floating around.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Importing audio files")
                            .font(.title2)
                        
                        Image("OnboardingImporting")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("Drag and drop audio files you wish to import from the files app onto the timeline. Long press to delete.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Changing speaker position")
                            .font(.title2)
                        
                        Image("OnboardingTransform")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("Drag and drop transforms from the picker onto the timeline. Resize them using handles, edit properties or delete by long pressing.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Let's go!")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.bottom, 60)
        .padding(.horizontal, 80)
    }
}
