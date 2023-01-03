import Foundation

// MARK: ApiError enum
public enum NetworkError: Error {
    case malformedRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverInternal
    case internalError
    case notImplemented
    case serviceUnavailable
    case jsonDecode
    case backendError(code: Int)
}
