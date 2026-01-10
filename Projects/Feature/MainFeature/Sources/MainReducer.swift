import Rex
import MainFeatureInterface
import BaseFeature
import Utility

public struct MainReducer: Reducer {
    public init() {}
    
    public func reduce(state: inout MainState, action: MainAction) -> [Effect<MainAction>] {
        switch action {
        case .showSheetFlow(let flow):
            state.sheetFlow = flow
            return []
        case let .showShake(id, executionId):
            state.isShowingShake = true
            state.shakeAlarmId = id
            state.shakeExecutionId = executionId
            return []
        case .closeShake(let id):
            state.isShowingShake = false
            state.shakeAlarmId = nil
            state.shakeExecutionId = nil
            return []
        }
    }
}
