import Foundation
import Rex

public enum MainAction: ActionType {
    case showSheetFlow(MainState.SheetFlow?)
    case showShake(id: UUID, executionId: UUID?)
    case closeShake(id: UUID)
}
