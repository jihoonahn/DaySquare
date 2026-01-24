import SwiftUI
import RefineUIIcons
import Designsystem
import MemosDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import Localization
import Utility

// MARK: - Simplified Timeline View
struct SimplifiedTimelineView: View {
    let items: [TimelineItem]
    let allMemos: [MemosEntity]
    
    private let pixelsPerHour: CGFloat = 40
    private let defaultHourHeight: CGFloat = 80
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                // 배경: 하나의 긴 타임라인 라인
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(JColor.textSecondary.opacity(0.2))
                            .frame(width: 2)
                            .frame(width: 50)
                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)
                
                // 시간별로 쪼개진 아이템들
                VStack(alignment: .leading, spacing: 0) {
                    // 0-11시 (오전)
                    ForEach(0..<12, id: \.self) { hour in
                        TimelineHourSection(
                            hour: hour,
                            items: itemsForHour(hour),
                            allMemos: allMemos,
                            pixelsPerHour: pixelsPerHour,
                            defaultHourHeight: defaultHourHeight
                        )
                    }
                    
                    // 12:00 구분선
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(JColor.textSecondary.opacity(0.5))
                            .frame(width: 2, height: 1)
                            .frame(width: 50)
                        
                        Text("12:00")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(JColor.textSecondary.opacity(0.7))
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .frame(height: pixelsPerHour / 2)
                    
                    // 12-23시 (오후)
                    ForEach(12..<24, id: \.self) { hour in
                        TimelineHourSection(
                            hour: hour,
                            items: itemsForHour(hour),
                            allMemos: allMemos,
                            pixelsPerHour: pixelsPerHour,
                            defaultHourHeight: defaultHourHeight
                        )
                    }
                }
            }
            
            Spacer(minLength: 40)
        }
        .padding(.top, 100)
    }
    
    // 특정 시간에 해당하는 아이템들 필터링
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
    let hour: Int
    let items: [TimelineItem]
    let allMemos: [MemosEntity]
    let pixelsPerHour: CGFloat
    let defaultHourHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if items.isEmpty {
                // 아이템이 없으면 기본 높이
                VStack(spacing: 0) {}
                    .frame(height: defaultHourHeight)
            } else {
                // 아이템이 있으면 아이템 높이만큼 늘어남
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
            VStack(alignment: .leading, spacing: 12) {
                TimelineRow(item: item, relatedMemos: relatedMemos)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
