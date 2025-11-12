import SwiftUI
import CoreData

@main
struct NewCourseProjectApp: App {
    @AppStorage("didOnboard") private var didOnboardStorage: Bool = false
    @AppStorage("didRegister") private var didRegister: Bool = false

    @StateObject var authManager = AuthManager()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if !didOnboardStorage {
                    OnBoardingView(hasCompletedBoarding: $didOnboardStorage)
                } else if !didRegister || !authManager.isLoggedIn {
                    LoginView()
                        .environmentObject(authManager)
                        .onChange(of: authManager.isLoggedIn) { logged in
                            if logged {
                                didRegister = true
                            }
                        }
                } else {
                    MainView()
                        .environmentObject(authManager)
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
