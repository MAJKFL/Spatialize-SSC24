import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\Project.lastEdited)]) var projects: [Project]
    
    @State private var selectedProject: Project?
    @State private var selectedNode: Node?
    
    @AppStorage("FirstLaunch") var firstLaunch = true
    @State var showHelp = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(projects) { project in
                    Button(action: { selectedProject = project }) {
                        ProjectListRow(project: project)
                    }
                }
                .onDelete(perform: deleteProject)
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showHelp = true
                        
//                        selectedProject?.nodes.sorted(by: { $0.position < $1.position }).forEach { node in
//                            
//                            
//                            print("let n\(node.position) = Node(position: \(node.position), name: \"\(node.name)\", color: add)")
//                            
//                            node.tracks.forEach { track in
////                                let t = Track(id: track.id, fileName: track.fileName, ext: track.ext, trackLength: track.trackLength, start: track.start)
//                                print("let track\(node.position) = Track(id: UUID(), fileName: \"\(track.fileName)\", ext: \"\(track.ext)\", trackLength: \(track.trackLength), start: \(track.start))")
//                                print("n\(node.position).tracks.append(track\(node.position))")
//                            }
//                            
//                            node.transforms.forEach { transform in
//                                let transform = TransformModel(start: transform.start, length: transform.length, type: transform.type, doubleFields: transform.doubleFields, booleanFields: transform.booleanFields)
//                                print("let transform\(node.position) = TransformModel(start: \(transform.start), length: \(transform.length), type: .\(transform.type), doubleFields: \(transform.doubleFields), booleanFields: \(transform.booleanFields))")
//                                print("n\(node.position).transforms.append(transform\(node.position))")
//                            }
//                            
//                            print("")
//                        }
                    }, label: {
                        Label("Help", systemImage: "questionmark.circle")
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addNewProject, label: {
                        Label("Add new project", systemImage: "plus")
                    })
                }
            }
            .navigationTitle("Projects")
            
            if let selectedProject {
                ProjectView(project: selectedProject)
            }
        }
        .onAppear {
            if firstLaunch {
                addFirstExampleProject()
                addSecondExampleProject()
                
                showHelp = true
                
                firstLaunch = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.selectedProject = self.projects.first
                }
            } else {
                selectedProject = projects.first
            }
        }
        .sheet(isPresented: $showHelp) {
            OnboardingView()
        }
    }
    
    func addNewProject() {
        let number = projects
            .map { $0.name }
            .filter { $0.contains("New Project") }
            .map { Int($0.replacingOccurrences(of: "New Project ", with: "")) ?? 0 }
            .max() ?? 0
        
        let defaultProjectNameCount = projects
            .map { $0.name }
            .filter { $0.contains("New Project") }
            .count
        
        modelContext.insert(Project(name: "New Project\(defaultProjectNameCount == 0 ? "" : " \(number + 1)")"))
    }
    
    func deleteProject(_ offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(projects[index])
        }
    }
    
    func addFirstExampleProject() {
        let exampleProject = Project(name: "Example Project")
        exampleProject.timeSignature = .ts44
        exampleProject.bpm = 73
        
        modelContext.insert(exampleProject)
        
        let n0 = Node(position: 0, name: "Saxophone", color: UIColor(#colorLiteral(red: 0, green: 0.631, blue: 0.847, alpha: 1)))
        n0.volume = 0.3
        let track0 = Track(id: UUID(), fileName: "Saxophone", ext: "mp3", trackLength: 29.58902494331066, start: 0.0, usesBundledAudio: true)
        n0.tracks.append(track0)
        let transform0 = TransformModel(start: 60.0, length: 2100.0, type: .spiral, doubleFields: ["hEnd": 32.0, "rev": 5.0, "rBase": 37.0, "hStart": 0.0], booleanFields: [:])
        n0.transforms.append(transform0)
        
        let n1 = Node(position: 1, name: "Bass", color: UIColor(#colorLiteral(red: 0.004, green: 0.38, blue: 0.996, alpha: 1)))
        let track1 = Track(id: UUID(), fileName: "Bass", ext: "mp3", trackLength: 39.45204081632653, start: 0.0, usesBundledAudio: true)
        n1.tracks.append(track1)
        let transform1 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["x": 27.0, "z": 50.0, "y": 7.0], booleanFields: ["interp": false])
        n1.transforms.append(transform1)
        
        let n2 = Node(position: 2, name: "Drums", color: UIColor(#colorLiteral(red: 0.298, green: 0.133, blue: 0.698, alpha: 1)))
        let track2 = Track(id: UUID(), fileName: "Drums", ext: "mp3", trackLength: 36.16437641723356, start: 0.0, usesBundledAudio: true)
        n2.tracks.append(track2)
        let transform2 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["y": 7.0, "z": 50.0, "x": -27.0], booleanFields: ["interp": false])
        n2.transforms.append(transform2)
        
        let n3 = Node(position: 3, name: "Piano", color: UIColor(#colorLiteral(red: 0.596, green: 0.165, blue: 0.741, alpha: 1)))
        n3.volume = 0.2
        let track3 = Track(id: UUID(), fileName: "Piano", ext: "mp3", trackLength: 39.45204081632653, start: 0.0, usesBundledAudio: true)
        n3.tracks.append(track3)
        let transform3 = TransformModel(start: 0.0, length: 2160.0, type: .random, doubleFields: ["frequency": 10.0, "radius": 24.0], booleanFields: [:])
        n3.transforms.append(transform3)
        
        let n4 = Node(position: 4, name: "Organ1", color: UIColor(#colorLiteral(red: 0.725, green: 0.176, blue: 0.365, alpha: 1)))
        let track4 = Track(id: UUID(), fileName: "Organ1", ext: "mp3", trackLength: 39.45204081632653, start: 0.0, usesBundledAudio: true)
        n4.tracks.append(track4)
        let transform4 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["y": 10.0, "z": -50.0, "x": -40.0], booleanFields: ["interp": false])
        n4.transforms.append(transform4)
        
        let n5 = Node(position: 5, name: "Organ2", color: UIColor(#colorLiteral(red: 1, green: 0.251, blue: 0.078, alpha: 1)))
        let track5 = Track(id: UUID(), fileName: "Organ2", ext: "mp3", trackLength: 32.87671201814059, start: 0.0, usesBundledAudio: true)
        n5.tracks.append(track5)
        let transform5 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["x": 40.0, "z": -50.0, "y": 10.0], booleanFields: ["interp": false])
        n5.transforms.append(transform5)
        
        let n6 = Node(position: 6, name: "Rhythm", color: UIColor(#colorLiteral(red: 1, green: 0.416, blue: 0, alpha: 1)))
        let track6 = Track(id: UUID(), fileName: "Rhythm", ext: "mp3", trackLength: 39.45204081632653, start: 0.0, usesBundledAudio: true)
        n6.tracks.append(track6)
        let transform60 = TransformModel(start: 0.0, length: 960.0, type: .orbit, doubleFields: ["rev": 1.0, "height": 30.0, "radius": 30, "hMod": 5], booleanFields: [:])
        let transform61 = TransformModel(start: 1920.0, length: 960.0, type: .orbit, doubleFields: ["rev": 1.0, "height": 30.0, "radius": 30.0, "hMod": 5.0], booleanFields: [:])
        let transform62 = TransformModel(start: 960.0, length: 960.0, type: .orbit, doubleFields: ["rev": 1.0, "height": 30.0, "radius": 30.0, "hMod": 5.0], booleanFields: [:])
        n6.transforms = [transform60, transform61, transform62]
        
        exampleProject.nodes = [n0, n1, n2, n3, n4, n5, n6]
    }
    
    func addSecondExampleProject() {
        
    }
}
