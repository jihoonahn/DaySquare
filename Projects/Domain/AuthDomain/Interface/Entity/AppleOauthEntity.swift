import Foundation

public struct AppleOauthEntity: Sendable, Codable, Equatable {
    public let email: String?
    public let displayName: String?
    public let identityToken: String
    public let authorizationCode: String?
    public let createdAt: Date
    
    public init(
        email: String? = nil,
        displayName: String? = nil,
        identityToken: String,
        authorizationCode: String? = nil,
        createdAt: Date = Date()
    ) {
        self.email = email
        self.displayName = displayName
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.createdAt = createdAt
    }
}
