import Combine
import Foundation

public final class GluonNetwork {
    // URL manager...
    public private(set) var httpSession: URLSession!
    /// ...his operation queue...
    public private(set) var httpQueue = OperationQueue()
    /// ...and his configuración
    public private(set) var httpConfiguration: URLSessionConfiguration!
    
    public init(settings: Settings) {
        self.httpConfiguration = URLSessionConfiguration.default
        self.httpConfiguration.httpMaximumConnectionsPerHost = settings.maximumConnectionsPerHost
        
        self.httpQueue.maxConcurrentOperationCount = settings.maximumConcurrentOperationCount
        
        self.httpSession = URLSession(configuration:self.httpConfiguration,
                                      delegate:nil,
                                      delegateQueue:httpQueue)
    }
    
    public convenience init() {
        let defaultSettings = Settings()
        self.init(settings: defaultSettings)
    }
    
    /// Cancels all network operations
    public func cancel()  {
        self.httpQueue.cancelAllOperations()
    }
    
    //
    // MARK: - HTTP Methods
    //
    
    /**
        URL request operation
     
        - Parameters:
            - request: `URLRequest` requested
            - completionHandler: HTTP operation result
    */
    internal func processRequest(_ request: URLRequest) -> AnyPublisher<NetworkResponse, NetworkError> {
         self.httpSession.dataTaskPublisher(for: request)
             .tryMap { (data, response) -> (Data, HTTPURLResponse) in
                 guard let httpResponse = response as? HTTPURLResponse else {
                     throw NetworkError.badRequest
                 }
    
                 return (data, httpResponse)
             }
             .tryMap { (data, httpResponse) -> NetworkResponse in
                 let apiResponse = try self.processResponse(httpResponse, data: data)
                 
                 return apiResponse
             }
             .mapError { error in
                 if let NetworkError = error as? NetworkError {
                     return NetworkError
                 }
                 
                 return NetworkError.serverInternal
             }
             .eraseToAnyPublisher()
    }
    
    internal func processRequest(_ request: URLRequest) async throws -> NetworkResponse {
        let (data, response) = try await self.httpSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badRequest
        }
        
        let apiResponse = try processResponse(httpResponse, data: data)
        
        return apiResponse
    }
    
    private func processResponse(_ httpResponse: HTTPURLResponse, data: Data) throws -> NetworkResponse {
        switch httpResponse.statusCode {
            case 400:
                throw NetworkError.badRequest
            case 401:
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            case 405...499:
                throw NetworkError.backendError(code: httpResponse.statusCode)
            case 500:
                throw NetworkError.internalError
            case 501:
                throw NetworkError.notImplemented
            case 503:
                throw NetworkError.serviceUnavailable
            case 504...599:
                throw NetworkError.backendError(code: httpResponse.statusCode)
            default:
                let apiResponse = NetworkResponse(withCode: httpResponse.statusCode,
                                              results: data,
                                              headers: httpResponse.allHeaderFields)
                
                return apiResponse
        }
    }
}
