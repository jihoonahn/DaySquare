import Foundation
import UIKit
import AuthenticationServices
import AuthCoreInterface
import AuthDomainInterface

public final class AppleOauthServiceImpl: AppleOauthService {
    
    // Delegate를 강한 참조로 유지하여 메모리에서 해제되지 않도록 함
    private var currentDelegate: AppleSignInDelegate?
    
    public init() {
    }
    
    public func signInWithApple() async throws -> AppleOauthEntity {
        #if targetEnvironment(simulator)
        throw AuthError.simulatorNotSupported
        #endif
        
        // Apple Sign In Native SDK 사용
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        // Async/await를 위한 continuation 사용
        let authorization = try await withCheckedThrowingContinuation { continuation in
            let delegate = AppleSignInDelegate { [weak self] result in
                // 완료 후 delegate 해제
                self?.currentDelegate = nil
                continuation.resume(with: result)
            }
            
            // Delegate를 인스턴스 변수로 유지하여 메모리에서 해제되지 않도록 함
            self.currentDelegate = delegate
            
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
        }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }
        
        guard let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            throw AuthError.missingIdentityToken
        }
        
        // Authorization Code가 있으면 저장
        let authorizationCode: String?
        if let authCodeData = appleIDCredential.authorizationCode,
           let authCode = String(data: authCodeData, encoding: .utf8) {
            authorizationCode = authCode
        } else {
            authorizationCode = nil
        }
        
        // Full Name 포맷팅
        var displayName: String?
        if let fullName = appleIDCredential.fullName {
            var nameComponents: [String] = []
            if let givenName = fullName.givenName {
                nameComponents.append(givenName)
            }
            if let familyName = fullName.familyName {
                nameComponents.append(familyName)
            }
            displayName = nameComponents.isEmpty ? nil : nameComponents.joined(separator: " ")
        }

        return AppleOauthEntity(
            email: appleIDCredential.email,
            displayName: displayName,
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            createdAt: Date()
        )
    }
    
    public func signOut() async throws {
        // Native SDK 로그아웃은 필요 없음 (Supabase 로그아웃은 SupabaseCore에서 처리)
    }
}

// MARK: - Apple Sign In Delegate
private final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let completion: (Result<ASAuthorization, Error>) -> Void
    
    init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        completion(.success(authorization))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow(frame: UIScreen.main.bounds)
        }
        return window
    }
}

// MARK: - Auth Errors
private enum AuthError: LocalizedError {
    case invalidCredential
    case missingIdentityToken
    case simulatorNotSupported
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid Apple credential"
        case .missingIdentityToken:
            return "Missing identity token from Apple"
        case .simulatorNotSupported:
            return "Apple Sign In은 시뮬레이터에서 지원되지 않습니다. 실제 디바이스에서 테스트해주세요."
        }
    }
}
