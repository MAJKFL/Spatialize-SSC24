import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\Project.lastEdited)]) var projects: [Project]
    
    @State private var selectedProject: Project?
    @State private var selectedNode: Node?
    
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
            selectedProject = projects.first
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
}
