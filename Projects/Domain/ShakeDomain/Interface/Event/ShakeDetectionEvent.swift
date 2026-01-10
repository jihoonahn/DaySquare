import Foundation

public struct ShakeDetectionEvent {
    public let alarmId: UUID
    public let count: Int
    public let shakeData: ShakeEntity
    
    public init(alarmId: UUID, count: Int, shakeData: ShakeEntity) {
        self.alarmId = alarmId
        self.count = count
        self.shakeData = shakeData
    }
}
