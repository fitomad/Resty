import Foundation

public struct NetworkResponse {
    // MARK: - Properties
    /// Data returned by HTTP Server
    public private(set) var data: Data?
    /// HTTP headers returned by server
    public private(set) var headers: [AnyHashable : Any]?
    /// HTTP code response for this operation
    public private(set) var httpCodeResponse: Int
    
    // MARK: - Initializer
    /**
     Create a new ApiResponse based on server response
     
     - Parameters:
     - httpCode:
     - data:
     - headers:
     */
    public init(withCode httpCode: Int, results data: Data? = nil, headers: [AnyHashable : Any]? = nil) {
        self.httpCodeResponse = httpCode
        self.data = data
        self.headers = headers
    }
}
