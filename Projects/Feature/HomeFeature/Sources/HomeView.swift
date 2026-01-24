import Foundation
import SwiftUI
import RefineUIIcons
import Rex
import BaseFeature
import AlarmsFeatureInterface
import SchedulesFeatureInterface
import HomeFeatureInterface
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

    private let alarmFactory: AlarmFactory
    private let scheduleFactory: SchedulesFactory

    public init(interface: HomeInterface) {
        self.interface = interface
        self.alarmFactory = DIContainer.shared.resolve(AlarmFactory.self)
        self.scheduleFactory = DIContainer.shared.resolve(SchedulesFactory.self)
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
        .environment(\.locale, Locale(identifier: LocalizationController.shared.languageCode))
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
            get: { state.showAlarmSheet },
            set: { interface.send(.showAlarmSheet($0))}
        )) {
            alarmFactory.makeView()
        }
        .sheet(isPresented: Binding(
            get: { state.showScheduleSheet },
            set: { interface.send(.showScheduleSheet($0)) }
        )) {
            scheduleFactory.makeView()
        }
        .sheet(isPresented: Binding(
            get: { state.showCalendarSheet },
            set: { interface.send(.showCalendarView($0)) }
        )) {
            CalendarView(
                selectedDate: Binding(
                    get: { state.currentDisplayDate },
                    set: { interface.send(.setCurrentDisplayDate($0)) }
                ),
                schedules: state.schedules,
                alarms: state.alarms
            )
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: {
                interface.send(.showCalendarView(true))
            }) {
                let locale = Locale(identifier: LocalizationController.shared.languageCode)
                VStack(spacing: 2) {
                    Text(state.currentDisplayDate.toString(
                        format: "DateFormatMonthDay".localized(locale: locale),
                        locale: locale
                    ))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(JColor.textPrimary)
                    Text(state.currentDisplayDate.toString(
                        format: "DateFormatWeekday".localized(locale: locale),
                        locale: locale
                    ))
                        .font(.system(size: 20))
                        .foregroundStyle(JColor.textSecondary)
                }
            }
            Spacer()
            Button {
                interface.send(.showAlarmSheet(true))
            } label: {
                Image(refineUIIcon: .clock28Regular)
                    .tint(.white)
                    .padding(6)
                    .glassEffect()
            }
            Button {
                interface.send(.showScheduleSheet(true))
            } label: {
                Image(refineUIIcon: .calendar28Regular)
                    .tint(.white)
                    .padding(6)
                    .glassEffect()
            }
        }
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
        .padding(.top, 100)
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
