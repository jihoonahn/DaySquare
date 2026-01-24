import Rex
import RefineUIIcons
import Foundation

public struct MainState: StateType {
    public enum Tab: String, Sendable, Codable, CaseIterable, Identifiable {
        case home
        case settings
    
        public var id: Self { self }
        
        public var title: String {
            switch self {
            case .home:
                return "홈"
            case .settings:
                return "설정"
            }
        }
    }

    public var selectedTab: Tab = .home

    public init() {}
}
