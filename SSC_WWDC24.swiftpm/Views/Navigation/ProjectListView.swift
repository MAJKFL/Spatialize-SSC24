import SwiftUI
import SwiftData

/// Shows all projects of a user and manages navigation.
struct ProjectListView: View {
    /// Swift Data context.
    @Environment(\.modelContext) var modelContext
    /// Projects of the user.
    @Query(sort: [SortDescriptor(\Project.dateCreated)]) var projects: [Project]
    
    /// Project currently showed on the screen.
    @State private var selectedProject: Project?
    /// Node currently edited by the user.
    @State private var selectedNode: Node?
    
    /// Determines whether this is the first launch of the app.
    @AppStorage("FirstLaunch") private var firstLaunch = true
    /// Shows the app manual.
    @State private var showHelp = false

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
    
    /// Creates new project.
    private func addNewProject() {
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
    
    /// Deletes project with swipe to delete.
    private func deleteProject(_ offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(projects[index])
        }
    }
    
    /// Adds first example project on the first launch.
    private func addFirstExampleProject() {
        let exampleProject = Project(name: "Example Project 1")
        exampleProject.timeSignature = .ts44
        exampleProject.bpm = 73
        
        modelContext.insert(exampleProject)
        
        let n0 = Node(position: 0, name: "Saxophone", color: UIColor(#colorLiteral(red: 0, green: 0.631, blue: 0.847, alpha: 1)))
        n0.volume = 0.3
        let track0 = Track(id: copyBundleFile(named: "Saxophone"), fileName: "Saxophone", ext: "mp3", trackLength: 29.58902494331066, start: 0.0)
        n0.tracks.append(track0)
        let transform0 = TransformModel(start: 60.0, length: 2100.0, type: .spiral, doubleFields: ["hEnd": 32.0, "rev": 5.0, "rBase": 37.0, "hStart": 0.0], booleanFields: [:])
        n0.transforms.append(transform0)
        
        let n1 = Node(position: 1, name: "Bass", color: UIColor(#colorLiteral(red: 0.004, green: 0.38, blue: 0.996, alpha: 1)))
        let track1 = Track(id: copyBundleFile(named: "Bass"), fileName: "Bass", ext: "mp3", trackLength: 39.45204081632653, start: 0.0)
        n1.tracks.append(track1)
        let transform1 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["x": 27.0, "z": 50.0, "y": 7.0], booleanFields: ["interp": false])
        n1.transforms.append(transform1)
        
        let n2 = Node(position: 2, name: "Drums", color: UIColor(#colorLiteral(red: 0.298, green: 0.133, blue: 0.698, alpha: 1)))
        let track2 = Track(id: copyBundleFile(named: "Drums"), fileName: "Drums", ext: "mp3", trackLength: 36.16437641723356, start: 0.0)
        n2.tracks.append(track2)
        let transform2 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["y": 7.0, "z": 50.0, "x": -27.0], booleanFields: ["interp": false])
        n2.transforms.append(transform2)
        
        let n3 = Node(position: 3, name: "Piano", color: UIColor(#colorLiteral(red: 0.596, green: 0.165, blue: 0.741, alpha: 1)))
        n3.volume = 0.2
        let track3 = Track(id: copyBundleFile(named: "Piano"), fileName: "Piano", ext: "mp3", trackLength: 39.45204081632653, start: 0.0)
        n3.tracks.append(track3)
        let transform3 = TransformModel(start: 0.0, length: 2160.0, type: .random, doubleFields: ["frequency": 10.0, "radius": 24.0], booleanFields: [:])
        n3.transforms.append(transform3)
        
        let n4 = Node(position: 4, name: "Organ1", color: UIColor(#colorLiteral(red: 0.725, green: 0.176, blue: 0.365, alpha: 1)))
        let track4 = Track(id: copyBundleFile(named: "Organ1"), fileName: "Organ1", ext: "mp3", trackLength: 39.45204081632653, start: 0.0)
        n4.tracks.append(track4)
        let transform4 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["y": 10.0, "z": -50.0, "x": -40.0], booleanFields: ["interp": false])
        n4.transforms.append(transform4)
        
        let n5 = Node(position: 5, name: "Organ2", color: UIColor(#colorLiteral(red: 1, green: 0.251, blue: 0.078, alpha: 1)))
        let track5 = Track(id: copyBundleFile(named: "Organ2"), fileName: "Organ2", ext: "mp3", trackLength: 32.87671201814059, start: 0.0)
        n5.tracks.append(track5)
        let transform5 = TransformModel(start: 0.0, length: 240.0, type: .move, doubleFields: ["x": 40.0, "z": -50.0, "y": 10.0], booleanFields: ["interp": false])
        n5.transforms.append(transform5)
        
        let n6 = Node(position: 6, name: "Rhythm", color: UIColor(#colorLiteral(red: 1, green: 0.416, blue: 0, alpha: 1)))
        let track6 = Track(id: copyBundleFile(named: "Rhythm"), fileName: "Rhythm", ext: "mp3", trackLength: 39.45204081632653, start: 0.0)
        n6.tracks.append(track6)
        let transform60 = TransformModel(start: 0.0, length: 960.0, type: .orbit, doubleFields: ["rev": 1.0, "height": 30.0, "radius": 30, "hMod": 5], booleanFields: [:])
        let transform61 = TransformModel(start: 1920.0, length: 960.0, type: .orbit, doubleFields: ["rev": 1.0, "height": 30.0, "radius": 30.0, "hMod": 5.0], booleanFields: [:])
        let transform62 = TransformModel(start: 960.0, length: 960.0, type: .orbit, doubleFields: ["rev": 1.0, "height": 30.0, "radius": 30.0, "hMod": 5.0], booleanFields: [:])
        n6.transforms = [transform60, transform61, transform62]
        
        exampleProject.nodes = [n0, n1, n2, n3, n4, n5, n6]
    }
    
    /// Adds second example project on the first launch.
    private func addSecondExampleProject() {
        let exampleProject = Project(name: "Example Project 2")
        exampleProject.timeSignature = .ts44
        exampleProject.bpm = 134
        
        modelContext.insert(exampleProject)
        
        let n = Node(position: 0, name: "Guitar", color: UIColor(#colorLiteral(red: 0, green: 0.631, blue: 0.847, alpha: 1)))
        let track = Track(id: copyBundleFile(named: "Simple-Guitar"), fileName: "Simple-Guitar", ext: "mp3", trackLength: 37.61195011337868, start: 0.0)
        n.tracks.append(track)
        let transform1 = TransformModel(start: 0.0, length: 720.0, type: .move, doubleFields: ["z": -27.0, "x": -43.0, "y": 33.0], booleanFields: ["interp": true])
        let transform2 = TransformModel(start: 960.0, length: 1050.0, type: .orbit, doubleFields: ["radius": 40.0, "height": 18.342776596546173, "rev": 2.0, "hMod": 8.0], booleanFields: [:])
        let transform3 = TransformModel(start: 2160.0, length: 960.0, type: .random, doubleFields: ["radius": 38.0, "frequency": 8.0], booleanFields: [:])
        let transform4 = TransformModel(start: 3360.0, length: 960.0, type: .spiral, doubleFields: ["hEnd": 40.0, "rev": 3.0, "hStart": 1.0, "rBase": 40.0], booleanFields: [:])
        
        n.transforms = [transform1, transform2, transform3, transform4]
        
        exampleProject.nodes.append(n)
    }
    
    /// Copies files of the example projects.
    private func copyBundleFile(named name: String) -> UUID {
        let url = Bundle.main.url(forResource: name, withExtension: "mp3")!
        
        let id = UUID()
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: id.uuidString).appendingPathExtension(url.pathExtension)
        
        try! FileManager.default.copyItem(at: url, to: directory)
        
        return id
    }
}
