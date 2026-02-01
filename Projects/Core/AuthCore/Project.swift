import ProjectDescription
import ProjectDescriptionHelpers
import TuistUI

let project = AuthCore().module()

struct AuthCore: Module {
    var body: some Module {
        ProjectContainer(
            name: typeName,
            target: .Core
        ) {
            Sources(
                name: typeName,
                dependencies: [
                    .core(target: typeName, type: .interface),
                    .sdk(name: "AuthenticationServices", type: .framework)
                ]
            )
            Interface(
                name: typeName,
                dependencies: [
                    .domain(target: "AuthDomain", type: .interface)
                ]
            )
            Testing(
                name: typeName,
                dependencies: [
                    .core(target: typeName, type: .interface),
                    .domain(target: "AuthDomain", type: .interface)
                ]
            )
            Tests(
                name: typeName,
                dependencies: [
                    .core(target: typeName),
                    .core(target: typeName, type: .testing)
                ]
            )
        }
    }
}
