import Testing
@testable import SchedulesFeature
@testable import SchedulesFeatureTesting
import SchedulesDomainInterface

struct SchedulesFeatureTests {

    // MARK: - SchedulesState (Interface)

    @Test("schedulesByDate 날짜별 그룹화 검증")
    func stateSchedulesByDate() throws {
        var state = SchedulesState()
        let s1 = SchedulesFeatureTesting.makeSchedule(date: "2025-01-15", title: "A")
        let s2 = SchedulesFeatureTesting.makeSchedule(date: "2025-01-15", title: "B")
        let s3 = SchedulesFeatureTesting.makeSchedule(date: "2025-01-16", title: "C")
        state.schedules = [s1, s2, s3]
        let byDate = state.schedulesByDate
        #expect(byDate["2025-01-15"]?.count == 2)
        #expect(byDate["2025-01-16"]?.count == 1)
    }

    @Test("sortedDates 날짜 순 정렬 검증")
    func stateSortedDates() throws {
        var state = SchedulesState()
        let s1 = SchedulesFeatureTesting.makeSchedule(date: "2025-01-17")
        let s2 = SchedulesFeatureTesting.makeSchedule(date: "2025-01-15")
        state.schedules = [s1, s2]
        let sorted = state.sortedDates
        #expect(sorted.first == "2025-01-15")
        #expect(sorted.last == "2025-01-17")
    }

    @Test("schedules(for:) 특정 날짜 스케줄 반환 및 startTime 정렬")
    func stateSchedulesForDate() throws {
        var state = SchedulesState()
        let s1 = SchedulesFeatureTesting.makeSchedule(date: "2025-01-15", startTime: "10:00", title: "Later")
        let s2 = SchedulesFeatureTesting.makeSchedule(date: "2025-01-15", startTime: "09:00", title: "Earlier")
        state.schedules = [s1, s2]
        let forDate = state.schedules(for: "2025-01-15")
        #expect(forDate.count == 2)
        #expect(forDate[0].startTime == "09:00")
        #expect(forDate[1].startTime == "10:00")
    }

    // MARK: - SchedulesReducer (Sources)

    @Test("setSchedules 액션 시 state 업데이트")
    func reducerSetSchedules() throws {
        let schedules = [SchedulesFeatureTesting.makeSchedule(title: "Meeting")]
        let reducer = SchedulesReducer(
            schedulesUseCase: MockSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForFeature(),
            memosUseCase: MockMemosUseCaseForFeature()
        )
        var state = SchedulesState()
        state.isLoading = true
        _ = reducer.reduce(state: &state, action: .setSchedules(schedules))
        #expect(state.schedules.count == 1)
        #expect(state.schedules[0].title == "Meeting")
        #expect(state.isLoading == false)
    }

    @Test("clearError 액션 시 errorMessage nil")
    func reducerClearError() throws {
        let reducer = SchedulesReducer(
            schedulesUseCase: MockSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForFeature(),
            memosUseCase: MockMemosUseCaseForFeature()
        )
        var state = SchedulesState()
        state.errorMessage = "Some error"
        _ = reducer.reduce(state: &state, action: .clearError)
        #expect(state.errorMessage == nil)
    }

    @Test("titleTextFieldDidChange 액션 시 title 업데이트")
    func reducerTitleChange() throws {
        let reducer = SchedulesReducer(
            schedulesUseCase: MockSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForFeature(),
            memosUseCase: MockMemosUseCaseForFeature()
        )
        var state = SchedulesState()
        _ = reducer.reduce(state: &state, action: .titleTextFieldDidChange("New Title"))
        #expect(state.title == "New Title")
    }

    @Test("showingAddSchedule 액션 시 state 초기화")
    func reducerShowingAddSchedule() throws {
        let reducer = SchedulesReducer(
            schedulesUseCase: MockSchedulesUseCaseForFeature(),
            usersUseCase: MockUsersUseCaseForFeature(),
            memosUseCase: MockMemosUseCaseForFeature()
        )
        var state = SchedulesState()
        state.title = "Old"
        state.description = "Desc"
        _ = reducer.reduce(state: &state, action: .showingAddSchedule(true))
        #expect(state.showingAddSchedule == true)
        #expect(state.title == "")
        #expect(state.description == "")
    }
}
