import SwiftUI
import SwiftData

@main
struct MyApp: App {
//    @AppStorage("FirstLaunch") var firstLaunch = true
    @State var firstLaunch = true
    
    var body: some Scene {
        WindowGroup {
            ProjectListView()
                .sheet(isPresented: $firstLaunch) {
                    OnboardingView()
                        .interactiveDismissDisabled()
                }
        }
        .modelContainer(for: Project.self)
    }
}
