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
                Text("Welcome to\n**AudioFiller!**")
                    .font(.largeTitle)
                
                Text("Experience spatial mixing easier than ever!")
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
                        Image(systemName: "speaker.slash.fill")
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
                            
                            Text("For the best results consider using earphones that support spatial audio like e.g. AirPods pro. Though, the app will still work as long as your device's speakers support spatial audio.")
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
                            Text("Speakers")
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Represent audio sources in 3d space")
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
                        
                        Text("Receives the speaker output. It's represented as the big, green sphere in the center of the editor plane. The green arrow shows the forward direction of the listener.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Creating/Editing")
                            .font(.title2)
                        
                        Image("OnboardingSpeaker")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("Use timeline's left bar to manage speaker nodes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom)
            }
            
            NavigationLink(destination: trackTutorial) {
                Text("Continue")
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
    
    /// Explains how to manage audio files.
    private func trackTutorial() -> some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Audio files")
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Represent audio on the timeline.")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Importing")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("Drag your audio files onto the timeline part related to the speaker node of your choosing.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Moving/Deleting")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("You can freely drag and drop imported audio files around the timeline. To delete one, long-press it and tap \"delete\".")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom)
            }
            
            NavigationLink(destination: transformTutorial) {
                Text("Continue")
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
    
    /// Explains how to use transforms.
    private func transformTutorial() -> some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Transforms")
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Specify the movement of a speaker node.")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Creating")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("Change editor mode to \"transform\" and drag and drop transform of your choosing onto the timeline.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Editing")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("Tap \"Edit\" button and adjust parameters. You can resize a transform by selecting it with a tap and dragging left or right handles.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Moving/Deleting")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("You can freely drag and drop created transforms around the timeline. To delete a transform, long-press it and tap \"delete\".")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            NavigationLink(destination: playbackTutorial) {
                Text("Continue")
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
    
    /// Explains how to manage playback.
    private func playbackTutorial() -> some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Playback")
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Control and play the project")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Play/Pause")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("Use play and pause buttons to stop and resume the playback.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Skipping")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("You can skip a bit forward/backwards with two-triangle buttons. Additionally you can jump to a specific beat by tapping it.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Time signature and tempo")
                            .font(.title2)
                        
                        // Video
                        Rectangle()
                            .fill(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                        
                        Text("Use buttons in top right corner to adjust time signature and tempo.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Let's go")
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
