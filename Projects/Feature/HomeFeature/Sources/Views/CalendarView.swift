import SwiftUI
import AlarmsDomainInterface
import SchedulesDomainInterface
import Localization
import Utility

struct CalendarView: View {
    @Binding var selectedDate: Date
    let schedules: [SchedulesEntity]
    let alarms: [AlarmsEntity]
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 월 선택 헤더
                    monthHeaderView
                    
                    // 요일 헤더
                    weekdayHeaderView
                    
                    // 캘린더 그리드
                    calendarGridView
                        .padding(.vertical, 16)
                    
                    // 선택된 날짜의 일정 목록
                    selectedDateScheduleList
                }
            }
            .navigationTitle("CalendarTitle".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close".localized()) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // 선택된 날짜의 월로 초기화
            currentMonth = selectedDate
        }
    }
    
    private var monthHeaderView: some View {
        HStack {
            Button(action: {
                if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                    currentMonth = previousMonth
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text({
                let locale = Locale(identifier: LocalizationController.shared.languageCode)
                return currentMonth.toString(
                    format: "DateFormatYearMonth".localized(locale: locale),
                    locale: locale
                )
            }())
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            Button(action: {
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                    currentMonth = nextMonth
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
        }
        .padding()
    }
    
    private var weekdayHeaderView: some View {
        let locale = Locale(identifier: LocalizationController.shared.languageCode)
        let weekdays = [
            "WeekdaySun".localized(locale: locale),
            "WeekdayMon".localized(locale: locale),
            "WeekdayTue".localized(locale: locale),
            "WeekdayWed".localized(locale: locale),
            "WeekdayThu".localized(locale: locale),
            "WeekdayFri".localized(locale: locale),
            "WeekdaySat".localized(locale: locale)
        ]
        return HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var calendarGridView: some View {
        let days = generateDaysInMonth()
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    calendarDayView(date: date)
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func calendarDayView(date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let daySchedules = schedulesForDate(date)
        let dayAlarms = alarmsForDate(date)
        let hasItems = !daySchedules.isEmpty || !dayAlarms.isEmpty
        
        return Button(action: {
            selectedDate = date
            // 선택한 날짜의 월로 currentMonth 업데이트
            let selectedMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
            if !calendar.isDate(selectedMonth, inSameDayAs: currentMonth) {
                currentMonth = selectedMonth
            }
        }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                
                if hasItems {
                    HStack(spacing: 2) {
                        if !daySchedules.isEmpty {
                            Circle()
                                .fill(isSelected ? .white : .blue)
                                .frame(width: 4, height: 4)
                        }
                        if !dayAlarms.isEmpty {
                            Circle()
                                .fill(isSelected ? .white : .orange)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var selectedDateScheduleList: some View {
        let locale = Locale(identifier: LocalizationController.shared.languageCode)
        return VStack(alignment: .leading, spacing: 12) {
            Text("\(selectedDate.toString(format: "DateFormatMonthDay".localized(locale: locale),locale: locale))\("ScheduleLabel".localized(locale: locale))")
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal)
                .padding(.top, 16)
            
            let daySchedules = schedulesForDate(selectedDate)
            let dayAlarms = alarmsForDate(selectedDate)
            
            if daySchedules.isEmpty && dayAlarms.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("CalendarScheduleEmpty".localized(locale: locale))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(daySchedules) { schedule in
                        scheduleRow(schedule)
                    }
                    ForEach(dayAlarms) { alarm in
                        alarmRow(alarm)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
    }
    
    private func scheduleRow(_ schedule: SchedulesEntity) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(schedule.title)
                    .font(.system(size: 15, weight: .medium))
                if !schedule.description.isEmpty {
                    Text(schedule.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Text("\(schedule.startTime)\(schedule.endTime.isEmpty ? "" : " - \(schedule.endTime)")")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func alarmRow(_ alarm: AlarmsEntity) -> some View {
        let locale = Locale(identifier: LocalizationController.shared.languageCode)
        return HStack(spacing: 12) {
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alarm.label ?? "HomeAlarmDefaultLabel".localized(locale: locale))
                    .font(.system(size: 15, weight: .medium))
                Text(alarm.time)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        var currentDate = firstDayOfMonth
        while currentDate < monthInterval.end {
            days.append(currentDate)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }
        
        return days
    }
    
    private func schedulesForDate(_ date: Date) -> [SchedulesEntity] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return schedules.filter { schedule in
            let normalizedDate = schedule.date.trimmingCharacters(in: .whitespaces)
                .components(separatedBy: " ").first ?? schedule.date
                .components(separatedBy: "T").first ?? schedule.date
            return normalizedDate == dateString
        }
    }
    
    private func alarmsForDate(_ date: Date) -> [AlarmsEntity] {
        let weekday = calendar.component(.weekday, from: date) - 1
        return alarms.filter { alarm in
            alarm.isEnabled && (alarm.repeatDays.isEmpty || alarm.repeatDays.contains(weekday))
        }
    }
    
}
