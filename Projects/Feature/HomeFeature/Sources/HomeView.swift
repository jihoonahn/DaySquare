import Foundation
import SwiftUI
import RefineUIIcons
import Rex
import BaseFeature
import HomeFeatureInterface
import MemosFeatureInterface
import Designsystem
import Dependency
import Localization
import MemosDomainInterface
import AlarmsDomainInterface
import SchedulesDomainInterface
import Utility

public struct HomeView: View {
    let interface: HomeInterface
    @State private var state = HomeState()

    public init(interface: HomeInterface) {
        self.interface = interface
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                JColor.background.ignoresSafeArea()
                
                if state.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: JColor.primary))
                } else {
                    GeometryReader { geometry in
                        ZStack(alignment: .top) {
                            ScrollView {
                                currentDayTimelineView(availableHeight: geometry.size.height)
                                    .padding(.horizontal, 20)
                            }
                            
                            headerView
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 16)
                                .background(
                                    ZStack {
                                        Color(.systemBackground).opacity(0.8)
                                    }
                                    .blur(radius: 30)
                                )
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            interface.send(.viewAppear)
        }
        .task {
            for await newState in interface.stateStream {
                await MainActor.run {
                    self.state = newState
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { state.isDatePickerPresented },
            set: { interface.send(.showDatePicker($0)) }
        )) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { state.tempSelectedDate },
                            set: { interface.send(.setTempSelectedDate($0)) }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(JColor.success)
                    Spacer()
                }
                .padding()
                .navigationTitle("HomeSelectDateTitle".localized())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("CommonCancel".localized()) {
                            interface.send(.showDatePicker(false))
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("CommonApply".localized()) {
                            interface.send(.confirmSelectedDate)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: {
                let calendar = Calendar.current
                if let previousDay = calendar.date(byAdding: .day, value: -1, to: state.currentDisplayDate) {
                    interface.send(.setCurrentDisplayDate(previousDay))
                }
            }) {
                Image(refineUIIcon: .chevronLeft24Regular)
                    .foregroundColor(JColor.textPrimary)
                    .frame(width: 40, height: 40)
                    .glassEffect(.clear.interactive(), in: .circle)
            }
            
            Button(action: {
                interface.send(.showDatePicker(true))
            }) {
                VStack(spacing: 6) {
                    Text(state.currentDisplayDate.toString())
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(JColor.textPrimary)
                }
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Button(action: {
                let calendar = Calendar.current
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: state.currentDisplayDate) {
                    interface.send(.setCurrentDisplayDate(nextDay))
                }
            }) {
                Image(refineUIIcon: .chevronRight24Regular)
                    .foregroundColor(JColor.textPrimary)
                    .frame(width: 40, height: 40)
                    .glassEffect(.clear.interactive(), in: .circle)
            }
        }
    }
    
    // MARK: - Constants
    private enum TimelineConstants {
        static let headerTopPadding: CGFloat = 100
    }
    
    // MARK: - Current Day Timeline
    private func currentDayTimelineView(availableHeight: CGFloat) -> some View {
        let items = TimelineHelper.createTimelineItems(
            for: state.currentDisplayDate,
            alarms: state.alarms,
            schedules: state.schedules
        )
        
        var memoCountsDict: [UUID: Int] = [:]
        for item in items {
            let relatedMemos = TimelineHelper.relatedMemos(for: item, allMemos: state.allMemos)
            memoCountsDict[item.id] = relatedMemos.count
        }
        let memoCounts = memoCountsDict
        
        let timelineData = TimelineCalculator.calculateTimelineData(
            for: items,
            memoCounts: memoCounts
        )
        let itemPositions = TimelineCalculator.calculateItemPositions(
            items: items,
            timelineData: timelineData,
            memoCounts: memoCounts
        )
        
        return ZStack(alignment: .topLeading) {
            timelineBackgroundLine(height: timelineData.totalHeight)
            timelinePeriodDividers(timelineData: timelineData)
            
            if items.count == itemPositions.count && !items.isEmpty {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index < itemPositions.count {
                        let position = itemPositions[index]
                        let safeY = position.y.isFinite ? position.y : 0
                        
                        timelineItemView(item: item)
                            .offset(y: safeY)
                    }
                }
            }
        }
        .frame(height: timelineData.totalHeight)
        .frame(maxWidth: .infinity)
        .padding(.top, TimelineConstants.headerTopPadding)
    }
    
    // MARK: - Timeline Background
    private func timelineBackgroundLine(height: CGFloat) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(JColor.textSecondary.opacity(0.2))
                .frame(width: 2, height: height)
                .frame(width: 50)
        }
    }
    
    private func timelinePeriodDividers(timelineData: TimelineCalculator.TimelineData) -> some View {
        return VStack(spacing: 0) {
            Rectangle()
                .fill(Color.clear)
                .frame(height: timelineData.morningHeight)
            
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
            
            Rectangle()
                .fill(Color.clear)
                .frame(height: timelineData.afternoonHeight)
        }
    }
    
    // MARK: - Timeline Item View
    private func timelineItemView(item: TimelineItem) -> some View {
        let relatedMemos = TimelineHelper.relatedMemos(for: item, allMemos: state.allMemos)
        
        return HStack(alignment: .top, spacing: 16) {
            timelineIndicatorView(for: item)
            
            TimelineRow(item: item, relatedMemos: relatedMemos)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Timeline Indicator
    private func timelineIndicatorView(for item: TimelineItem) -> some View {
        VStack(spacing: 0) {
            Circle()
                .frame(width: 15, height: 15)
                .glassEffect()
                .frame(width: 50)
                .padding(.top, 4)
            
            if let endTimeValue = item.endTimeValue {
                timelineDurationLine(
                    startTime: item.timeValue,
                    endTime: min(endTimeValue, 1440)
                )
            } else {
                Spacer()
                    .frame(height: 20)
            }
        }
    }
    
    private func timelineDurationLine(startTime: Int, endTime: Int) -> some View {
        let duration = max(0, endTime - startTime)
        let height = CGFloat(duration) * TimelineCalculator.Constants.pixelsPerMinute
        let safeHeight = max(40, height.isFinite ? height : 40)
        
        return Rectangle()
            .fill(JColor.primary.opacity(0.3))
            .frame(width: 2, height: safeHeight)
            .frame(width: 50)
    }
}
