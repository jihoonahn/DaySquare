import Foundation
import Rex
import ShakeFeatureInterface
import UsersDomainInterface
import AlarmsDomainInterface
import AlarmExecutionsDomainInterface
import ShakeDomainInterface
import Localization
import BaseFeature
import Dependency

public struct ShakeReducer: Reducer {
    private let usersUseCase: UsersUseCase
    private let alarmSchedulesUseCase: AlarmSchedulesUseCase
    private let alarmExecutionsUseCase: AlarmExecutionsUseCase
    private let shakeUseCase: ShakeUseCase
    
    public init(
        usersUseCase: UsersUseCase,
        alarmSchedulesUseCase: AlarmSchedulesUseCase,
        alarmExecutionsUseCase: AlarmExecutionsUseCase,
        shakeUseCase: ShakeUseCase
    ) {
        self.usersUseCase = usersUseCase
        self.alarmSchedulesUseCase = alarmSchedulesUseCase
        self.alarmExecutionsUseCase = alarmExecutionsUseCase
        self.shakeUseCase = shakeUseCase
    }
    
    private func getCurrentUserId() async throws -> UUID {
        guard let user = try await usersUseCase.getCurrentUser() else {
            throw NSError(domain: "ShakeReducer", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user.id
    }
    
    // MARK: - Shake Detection Handling
    
    /// 흔들기 감지 이벤트 처리
    /// - Parameters:
    ///   - count: 현재 감지된 흔들기 카운트
    ///   - shakeData: 감지된 흔들기 원시 데이터 (선택적)
    ///   - state: 현재 상태 (inout)
    /// - Returns: 실행할 Effect 배열
    private func handleShakeDetected(
        count: Int,
        state: inout ShakeState
    ) -> [Effect<ShakeAction>] {
        // 상태 업데이트
        let previousCount = state.shakeCount
        state.shakeCount = count
        print("📊 [ShakeReducer] 흔들기 카운트 업데이트: \(previousCount) -> \(count)/\(state.requiredCount)")
        
        var effects: [Effect<ShakeAction>] = []

        // 2. 필요한 카운트 도달 여부 확인
        if count >= state.requiredCount {
            effects.append(contentsOf: handleShakeCountReached(state: &state))
        } else {
            print("⏳ [ShakeReducer] 아직 카운트 부족: \(count)/\(state.requiredCount)")
        }
        
        return effects
    }
    /// 필요한 흔들기 카운트 도달 시 처리
    /// - Parameter state: 현재 상태 (inout)
    /// - Returns: 실행할 Effect 배열
    private func handleShakeCountReached(state: inout ShakeState) -> [Effect<ShakeAction>] {
        print("🎯 [ShakeReducer] 필요한 카운트 도달: \(state.shakeCount) >= \(state.requiredCount)")
        
        state.isMonitoring = false
        let alarmId = state.alarmId
        print("📊 [ShakeReducer] 상태 업데이트: isMonitoring=false")
        
        guard let alarmId = alarmId else {
            print("⚠️ [ShakeReducer] alarmId가 nil입니다")
            return []
        }
        
        return [
            Effect { [self] continuation in
                print("🛑 [ShakeReducer] 흔들기 감지 완료 - 알람 중지 시작: \(alarmId)")
                do {
                    try await self.alarmSchedulesUseCase.stopAlarm(alarmId)
                } catch {
                    print("Failed to Shake Reducer: stopAlarm(\(alarmId))")
                }
                continuation.send(.alarmStopped(alarmId: alarmId))
            }
        ]
    }
    
    public func reduce(state: inout ShakeState, action: ShakeAction) -> [Effect<ShakeAction>] {
        switch action {
        case .viewAppear:
            return []
            
        case .startMonitoring(let alarmId, let executionId, let requiredCount):
            if state.isMonitoring && state.alarmId == alarmId && state.executionId == executionId {
                print("⏭️ [ShakeReducer] 이미 모니터링 중 - 중복 호출 무시: alarmId=\(alarmId), executionId=\(executionId), 현재 카운트=\(state.shakeCount)")
                return []
            }
            
            // executionId와 alarmId를 동시에 설정
            state.alarmId = alarmId
            state.executionId = executionId
            state.requiredCount = requiredCount
            state.shakeCount = 0
            state.isMonitoring = true
            print("📊 [ShakeReducer] 상태 업데이트: alarmId = \(alarmId), isMonitoring=\(state.isMonitoring), shakeCount=\(state.shakeCount), executionId=\(executionId)")
            
            return [
                Effect { [self, alarmId, executionId, requiredCount] continuation in
                    do {
                        try await self.shakeUseCase.startMonitoring(for: alarmId, executionId: executionId, requiredCount: requiredCount)
                    } catch {
                        continuation.send(.stopMonitoring)
                    }
                }
            ]
            
        case .shakeDetected(let count, _):
            return handleShakeDetected(
                count: count,
                state: &state
            )
        case .stopMonitoring:
            print("🛑 [ShakeReducer] stopMonitoring 액션 수신")
            state.isMonitoring = false
            let alarmId = state.alarmId
            state.shakeCount = 0
            state.alarmId = nil
            state.executionId = nil
            if let alarmId = alarmId {
                print("🛑 [ShakeReducer] 흔들기 모니터링 중지: \(alarmId)")
                shakeUseCase.stopMonitoring(for: alarmId)
            } else {
                print("⚠️ [ShakeReducer] stopMonitoring: alarmId가 nil입니다")
            }
            return []
            
        case .alarmStopped(let alarmId):
            print("🛑 [ShakeReducer] alarmStopped 액션 수신: \(alarmId)")
            state.isMonitoring = false
            state.shakeCount = 0
            state.alarmId = nil
            state.executionId = nil
            print("🛑 [ShakeReducer] 흔들기 모니터링 중지: \(alarmId)")
            shakeUseCase.stopMonitoring(for: alarmId)
            return []
        }
    }
}
