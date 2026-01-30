import ProjectDescription
import TuistUI

public struct Sources: TargetConvertable {
    let env = AppEnvironment()
    let name: String
    let destinations: Destinations
    let product: Product
    let bundleId: String?
    let infoPlist: InfoPlist
    let entitlements: Entitlements?
    let sources: SourceFilesList
    let resources: ResourceFileElements
    let target: AppConfiguration.XCConfigTarget
    let dependencies: [TargetDependency]
    let provisioningProfileSpecifier: String?

    public init(
        name: String,
        product: Product = .staticLibrary,
        bundleId: String? = nil,
        infoPlist: InfoPlist = .default,
        entitlements: Entitlements? = nil,
        sources: SourceFilesList = .sources,
        resources: ResourceFileElements = [],
        configuration target: AppConfiguration.XCConfigTarget = .Shared,
        dependencies: [TargetDependency] = [],
        provisioningProfileSpecifier: String? = nil
    ) {
        self.name = name
        self.destinations = env.destinations
        self.product = product
        self.bundleId = bundleId
        self.infoPlist = infoPlist
        self.entitlements = entitlements
        self.sources = sources
        self.resources = resources
        self.target = target
        self.dependencies = dependencies
        self.provisioningProfileSpecifier = provisioningProfileSpecifier
    }

    public init(
        name: String,
        destinations: Destinations,
        product: Product = .staticLibrary,
        bundleId: String? = nil,
        infoPlist: InfoPlist = .default,
        entitlements: Entitlements? = nil,
        sources: SourceFilesList = .sources,
        resources: ResourceFileElements = [],
        configuration target: AppConfiguration.XCConfigTarget = .Shared,
        dependencies: [TargetDependency] = [],
        provisioningProfileSpecifier: String? = nil
    ) {
        self.name = name
        self.destinations = destinations
        self.product = product
        self.bundleId = bundleId
        self.infoPlist = infoPlist
        self.entitlements = entitlements
        self.sources = sources
        self.resources = resources
        self.target = target
        self.dependencies = dependencies
        self.provisioningProfileSpecifier = provisioningProfileSpecifier
    }

    private var targetBaseSettings: SettingsDictionary {
        var base = env.baseSettings
        if let spec = provisioningProfileSpecifier {
            base["PROVISIONING_PROFILE_SPECIFIER"] = .string(spec)
            base["CODE_SIGN_STYLE"] = .string("Manual")
            base["CODE_SIGN_IDENTITY"] = .string("Apple Distribution")
        } else {
            base["CODE_SIGN_STYLE"] = .string("Manual")
            base["CODE_SIGN_IDENTITY"] = .string("")
        }
        return base
    }

    public func build() -> ProjectDescription.Target {
        return Target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleId ?? "\(env.organizationName).\(name)",
            deploymentTargets: env.deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: .settings(
                base: targetBaseSettings,
                configurations: env.configuration.configure(into: target),
                defaultSettings: .recommended
            )
        ).build()
    }
}
