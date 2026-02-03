import Testing
@testable import BaseFeature

struct BaseFeatureTests {

    @Test("logger 레이블 검증")
    func loggerLabel() throws {
        #expect(logger.label == "com.jihoon.DaySquareFeature")
    }

    @Test("GlobalEventBus shared 인스턴스 존재")
    func globalEventBusShared() throws {
        let bus = GlobalEventBus.shared
        #expect(bus != nil)
    }
}
