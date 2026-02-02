import ProjectDescription
import ProjectDescriptionHelpers
import TuistUI

let project = BaseFeature().module()

struct BaseFeature: Module {

    var body: some Module {
        ProjectContainer(name: typeName, target: .Feature) {
            Sources(
                name: typeName,
                product: .framework,
                dependencies: [
                    .shared(target: "Dependency"),
                    .shared(target: "Designsystem"),
                    .shared(target: "Localization"),
                    .shared(target: "Utility"),
                    .external(name: "Rex")
                ]
            )
            Testing(
                name: typeName,
                dependencies: [
                    .feature(target: typeName)
                ]
            )
            Tests(
                name: typeName,
                dependencies: [
                    .feature(target: typeName),
                    .feature(target: typeName, type: .testing)
                ]
            )
        }
    }
}
