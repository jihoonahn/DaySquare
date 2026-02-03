import ProjectDescription
import ProjectDescriptionHelpers
import TuistUI

let project = MainFeature().module()

struct MainFeature: Module {
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
                    .external(name: "RefineUIIcons")
                ]
            )
            Interface(
                name: typeName,
                dependencies: [
                    .feature(target: "HomeFeature", type: .interface),
                    .feature(target: "AlarmsFeature", type: .interface),
                    .feature(target: "SchedulesFeature", type: .interface),
                    .feature(target: "SettingsFeature", type: .interface)
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
                    .feature(target: "HomeFeature", type: .interface),
                    .feature(target: "SettingsFeature", type: .interface)
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
