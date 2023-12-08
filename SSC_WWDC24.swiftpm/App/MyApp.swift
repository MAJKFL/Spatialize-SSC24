import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectListView()
        }
        .modelContainer(for: Project.self)
    }
}
