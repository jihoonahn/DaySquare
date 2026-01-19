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
        }
    }
}
