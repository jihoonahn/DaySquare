import Rex
import RefineUIIcons
import Foundation

public struct MainState: StateType {
    public enum SheetFlow: Sendable, Codable, CaseIterable, Identifiable {
        case alarm
        case schedule
        case settings
    
        public var id: Self { self }
    
        public var icon: RefineUIIcons {
            switch self {
            case .alarm:
                return .clockAlarm32Regular
            case .schedule:
                return .calendar32Regular
            case .settings:
                return .settings32Regular
            }
        }
    }
    
    public var sheetFlow: MainState.SheetFlow? = nil
    public var isShowingShake = false
    public var shakeAlarmId: UUID?
    public var shakeExecutionId: UUID?

    public init() {}
}
