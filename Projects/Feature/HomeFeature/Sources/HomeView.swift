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
        
        return SimplifiedTimelineView(items: items, allMemos: state.allMemos) { item in
            switch item.type {
            case .alarm:
                interface.send(.showAlarmSheet(true))
            case .schedule:
                interface.send(.showScheduleSheet(true))
            }
        }
    }
}
