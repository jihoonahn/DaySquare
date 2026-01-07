import ActivityKit
import AlarmKit
import AlarmSchedulesCoreInterface
import AppIntents
import WidgetKit
import SwiftUI

struct AlarmWidget: Widget {
    var body: some WidgetConfiguration {
        return ActivityConfiguration(for: AlarmAttributes<AlarmScheduleAttributes>.self) { context in
            LockScreenView(attributes: context.attributes, state: context.state)
        } dynamicIsland: { context in
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    LogoView(style: .basic)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.leading, 12)
                }
                DynamicIslandExpandedRegion(.center) {
                    WakeUpView(attributes: context.attributes)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } compactLeading: {
                LogoView(style: .compact)
            } compactTrailing: {}
            minimal: {
                LogoView(style: .minimal)
            }
            .keylineTint(.white)
        }
    }
}
