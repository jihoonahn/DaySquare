import Foundation
import Supabase
import SupabaseCoreInterface
import UsersDomainInterface
import AuthCoreInterface

public final class UsersServiceImpl: UsersService {

    private let client: SupabaseClient
    private let supabaseService: SupabaseService
    private let appleOauthService: AppleOauthService

    public init(
        supabaseService: SupabaseService,
        appleOauthService: AppleOauthService,
    ) {
        self.client = supabaseService.client
        self.supabaseService = supabaseService
        self.appleOauthService = appleOauthService
    }

    public func signInWithGoogle() async throws -> UsersEntity {
        // URL Scheme은 Info.plist의 CFBundleURLSchemes(daysquare)와 동일해야 함
        guard let redirectURL = URL(string: "daysquare://") else {
            throw NSError(domain: "UsersService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URL"])
        }
        let response = try await client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: redirectURL
        )
        let authUser = response.user

        let users: [UsersDTO] = try await client
            .from("users")
            .select()
            .eq("id", value: authUser.id.uuidString)
            .execute()
            .value

        if let existingUser = users.first {
            return existingUser.toEntity()
        }
        let newUser = UsersEntity(
            id: authUser.id,
            provider: "google",
            email: authUser.email ?? authUser.userMetadata["email"]?.rawValue,
            displayName: authUser.userMetadata["full_name"]?.rawValue ?? authUser.userMetadata["name"]?.rawValue,
            createdAt: Date(),
            updatedAt: Date()
        )

        let created: UsersDTO = try await client
            .from("users")
            .insert(newUser)
            .select()
            .single()
            .execute()
            .value

        return created.toEntity()
    }

    public func signInWithApple() async throws -> UsersEntity {
        let appleOauthEntity = try await appleOauthService.signInWithApple()
        
        let openIdConnectCredentials = OpenIDConnectCredentials(
            provider: .apple,
            idToken: appleOauthEntity.identityToken
        )
        let response = try await client.auth.signInWithIdToken(credentials: openIdConnectCredentials)
        let authUser = response.user

        let users: [UsersDTO] = try await client
            .from("users")
            .select()
            .eq("id", value: authUser.id.uuidString)
            .execute()
            .value

        if let existingUser = users.first {
            return existingUser.toEntity()
        }

        let newUser = UsersEntity(
            id: authUser.id,
            provider: "apple",
            email: appleOauthEntity.email ?? authUser.email,
            displayName: appleOauthEntity.displayName ?? authUser.userMetadata["full_name"]?.rawValue,
            createdAt: Date(),
            updatedAt: Date()
        )

        let created: UsersDTO = try await client
            .from("users")
            .insert(newUser)
            .select()
            .single()
            .execute()
            .value

        return created.toEntity()
    }

    public func fetchCurrentUser() async throws -> UsersEntity {
        let session = try await client.auth.session
        
        let userId = session.user.id
        let user: UsersDTO = try await client
            .from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        return user.toEntity()
    }

    public func updateUser(_ user: UsersEntity) async throws {
        let user = UsersDTO(from: user)

        try await client
            .from("users")
            .update(user)
            .eq("id", value: user.id.uuidString)
            .execute()
    }

    public func deleteUser(id: UUID) async throws {
        try await client
            .from("users")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    public func signOut() async throws {
        supabaseService.clearSession()
        try await client.auth.signOut()
    }
}
