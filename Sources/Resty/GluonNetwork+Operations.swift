import Combine
import Foundation

public extension GluonNetwork {
    // MARK: - Fetch functions
    
    /**
     Performs a basic HTTP request
     
     - Parameters:
     - endpoint: URI resource that will be requested
     - closure: Function where data will be returned.
     */
    func fetch(endpoint: Endpoint) async throws -> NetworkResponse {
        let parameters = NetworkRequest(httpMethod: .get)
        return try await self.fetch(endpoint: endpoint, withParameters: parameters)
    }
    
    /**
     Performs an HTTP request
     
     - Parameters:
     - endpoint: URI resource that will be requested
     - parameter: HTTP associated parameters.
     - closure: Function where data will be returned.
     */
    func fetch(endpoint: Endpoint, withParameters parameter: NetworkRequest) async throws -> NetworkResponse {
        guard let request = parameter.makeURLRequest(for: endpoint) else {
            throw NetworkError.malformedRequest
        }
        
        let response = try await self.processRequest(request)
        
        return response
    }
    
    func publisher(for endpoint: Endpoint) -> AnyPublisher<NetworkResponse, NetworkError> {
        let parameters = NetworkRequest(httpMethod: .get)
        return self.publisher(for: endpoint, withParameter: parameters)
    }
    
    func publisher(for endpoint: Endpoint, withParameter parameter: NetworkRequest) -> AnyPublisher<NetworkResponse, NetworkError> {
        guard let request = parameter.makeURLRequest(for: endpoint) else {
            return Fail(error: NetworkError.malformedRequest).eraseToAnyPublisher()
        }
        
        return self.processRequest(request)
    }
}
