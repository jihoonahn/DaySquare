import Foundation
import UIKit
import AuthenticationServices
import AuthCoreInterface
import AuthDomainInterface

public final class AppleOauthServiceImpl: AppleOauthService {
    
    // Delegate를 강한 참조로 유지하여 메모리에서 해제되지 않도록 함
    private var currentDelegate: AppleSignInDelegate?
    
    public init() {}
    
    public func signInWithApple() async throws -> AppleOauthEntity {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        let authorization = try await withCheckedThrowingContinuation { continuation in
            let delegate = AppleSignInDelegate { [weak self] result in
                self?.currentDelegate = nil
                continuation.resume(with: result)
            }
            self.currentDelegate = delegate
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            // iPad 포함 모든 기기에서 시트가 올바르게 표시되도록 메인 스레드에서 수행
            DispatchQueue.main.async {
                authorizationController.performRequests()
            }
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
        // iPad(멀티 윈도우 등)에서 활성 창을 사용하도록 key window 우선 사용
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        guard let windowScene = scene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return UIWindow(frame: UIScreen.main.bounds)
        }
        let window = windowScene.windows.first { $0.isKeyWindow }
            ?? windowScene.windows.first
        return window ?? UIWindow(frame: UIScreen.main.bounds)
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
