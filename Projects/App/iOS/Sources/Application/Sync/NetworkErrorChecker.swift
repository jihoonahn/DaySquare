import Foundation

/// 네트워크 오류 여부 확인 (오프라인 폴백 판단용)
enum NetworkErrorChecker {
    /// 오프라인/네트워크 오류이면 true (SwiftData 폴백 대상)
    static func isNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut,
                 .internationalRoamingOff, .dataNotAllowed, .cannotConnectToHost,
                 .cannotFindHost, .dnsLookupFailed:
                return true
            default:
                break
            }
        }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return true
        }
        return false
    }
}
