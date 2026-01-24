import SwiftUI
import RefineUIIcons
import Designsystem
import MemosDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import Localization
import Utility

// MARK: - Constants
private let defaultHourHeight: CGFloat = 80
private let timelinLineWidth: CGFloat = 2

// MARK: - Simplified Timeline View
struct SimplifiedTimelineView: View {
    let items: [TimelineItem]
    let allMemos: [MemosEntity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Timeline Background Line
                timelineBackgroundLine
                
                // Hours Content
                VStack(alignment: .leading, spacing: 0) {
                    // Morning (0-11시)
                    ForEach(0..<12, id: \.self) { hour in
                        TimelineHourSection(
                            items: itemsForHour(hour),
                            allMemos: allMemos
                        )
                    }
                    
                    // Noon Divider
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(JColor.textSecondary.opacity(0.5))
                            .frame(width: timelinLineWidth, height: 1)
                            .frame(width: 50)
                        
                        Text("12:00")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(JColor.textSecondary.opacity(0.7))
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .frame(height: 20)
                    
                    // Afternoon (12-23시)
                    ForEach(12..<24, id: \.self) { hour in
                        TimelineHourSection(
                            items: itemsForHour(hour),
                            allMemos: allMemos
                        )
                    }
                }
            }
            
            Spacer(minLength: 40)
        }
        .padding(.top, 100)
    }
    
    private var timelineBackgroundLine: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(JColor.textSecondary.opacity(0.2))
                .frame(width: timelinLineWidth)
                .frame(width: 50)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    private func itemsForHour(_ hour: Int) -> [TimelineItem] {
        let hourStartMinutes = hour * 60
        let hourEndMinutes = (hour + 1) * 60
        
        return items.filter { item in
            item.timeValue >= hourStartMinutes && item.timeValue < hourEndMinutes
        }
    }
}

// MARK: - Timeline Hour Section
struct TimelineHourSection: View {
    let items: [TimelineItem]
    let allMemos: [MemosEntity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if items.isEmpty {
                Spacer()
                    .frame(height: defaultHourHeight)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(items, id: \.id) { item in
                        TimelineItemRow(item: item, allMemos: allMemos)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Timeline Item Row
struct TimelineItemRow: View {
    let item: TimelineItem
    let allMemos: [MemosEntity]
    
    var body: some View {
        let relatedMemos = TimelineHelper.relatedMemos(for: item, allMemos: allMemos)
        
        HStack(alignment: .top, spacing: 12) {
            // Timeline Circle Indicator
            Circle()
                .frame(width: 15, height: 15)
                .glassEffect()
                .frame(width: 50)
                .padding(.top, 4)
            
            // Content
            TimelineRow(item: item, relatedMemos: relatedMemos)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
