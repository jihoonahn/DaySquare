import Testing
import Foundation
import NotificationCore
import NotificationCoreTesting
import NotificationDomainInterface
import AlarmsDomainInterface

struct NotificationCoreTests {

    @Test("NotificationUseCaseImpl loadPreference 호출 시 repository에 전달")
    func useCaseLoadPreferenceDelegatesToRepository() async throws {
        let mock = MockNotificationRepository()
        mock.loadPreferenceResult = NotificationCoreTesting.makeNotificationEntity()
        let useCase = NotificationUseCaseImpl(repository: mock)
        let result = try await useCase.loadPreference(userId: UUID())
        #expect(result?.isEnabled == true)
    }

    @Test("NotificationUseCaseImpl updatePreference 호출 시 repository에 전달")
    func useCaseUpdatePreferenceDelegatesToRepository() async throws {
        let mock = MockNotificationRepository()
        let useCase = NotificationUseCaseImpl(repository: mock)
        try await useCase.updatePreference(userId: UUID(), isEnabled: false)
        #expect(mock.upsertPreferenceCalled == true)
    }

    @Test("NotificationUseCaseImpl scheduleFallbackNotifications 호출 시 repository에 전달")
    func useCaseScheduleFallbackDelegatesToRepository() async throws {
        let mock = MockNotificationRepository()
        let useCase = NotificationUseCaseImpl(repository: mock)
        await useCase.scheduleFallbackNotifications(for: [])
        #expect(mock.scheduleFallbackNotificationsCalled == true)
    }

    @Test("NotificationUseCaseImpl clearFallbackNotifications 호출 시 repository에 전달")
    func useCaseClearFallbackDelegatesToRepository() async throws {
        let mock = MockNotificationRepository()
        let useCase = NotificationUseCaseImpl(repository: mock)
        await useCase.clearFallbackNotifications()
        #expect(mock.clearFallbackNotificationsCalled == true)
    }
}
