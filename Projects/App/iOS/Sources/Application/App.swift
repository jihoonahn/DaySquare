import SwiftUI
import SwiftData
import RootFeatureInterface
import Dependency
import SwiftDataCoreInterface
import SupabaseCoreInterface
import ActivityKit

@main
struct DaySquareApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    @State private var modelContainer: ModelContainer?
    private let rootFactory: RootFactory

    init() {
        AppDependencies.setup()
        self.rootFactory = DIContainer.shared.resolve(RootFactory.self)
    }

    var body: some Scene {
        WindowGroup {
            rootFactory.makeView()
                .preferredColorScheme(.dark)
                .modelContainer(
                    for: [
                        AlarmsModel.self,
                        MemosModel.self,
                        SchedulesModel.self,
                        UserSettingsModel.self
                    ]
                )
                .onOpenURL { url in
                    let supabase = DIContainer.shared.resolve(SupabaseService.self)
                    supabase.client.auth.handle(url)
                }
        }
    }
}
