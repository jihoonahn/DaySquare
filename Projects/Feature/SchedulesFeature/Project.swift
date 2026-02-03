import ProjectDescription
import ProjectDescriptionHelpers
import TuistUI

let project = SchedulesFeature().module()

struct SchedulesFeature: Module {
    var body: some Module {
        ProjectContainer(
            name: typeName,
            target: .Feature
        ) {
            Sources(
                name: typeName,
                dependencies: [
                    .feature(target: "BaseFeature", type: .sources),
                    .feature(target: typeName, type: .interface),
                    .domain(target: "MemosDomain", type: .interface),
                    .domain(target: "UsersDomain", type: .interface)
                ]
            )
            Interface(
                name: typeName,
                dependencies: [
                    .domain(target: "SchedulesDomain", type: .interface)
                ]
            )
            Example(
                name: typeName,
                dependencies: [
                    .feature(target: typeName),
                    .feature(target: typeName, type: .testing),
                    .feature(target: "BaseFeature", type: .sources),
                    .core(target: "LocalizationCore"),
                    .core(target: "LocalizationCore", type: .interface),
                    .domain(target: "LocalizationDomain", type: .interface)
                ]
            )
            Testing(
                name: typeName,
                dependencies: [
                    .feature(target: typeName, type: .interface),
                    .domain(target: "SchedulesDomain", type: .interface),
                    .domain(target: "UsersDomain", type: .interface),
                    .domain(target: "MemosDomain", type: .interface),
                    .domain(target: "LocalizationDomain", type: .interface)
                ]
            )
            Tests(
                name: typeName,
                dependencies: [
                    .feature(target: typeName),
                    .feature(target: typeName, type: .testing)
                ]
            )
            UITests(
                name: typeName,
                dependencies: [
                    .feature(target: typeName),
                    .feature(target: typeName, type: .testing)
                ]
            )
        }
    }
}
