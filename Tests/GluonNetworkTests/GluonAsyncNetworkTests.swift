//
//  GluonAsyncNetworkTests.swift
//  
//
//  Created by Adolfo Vera Blasco on 16/11/22.
//

import XCTest
@testable import GluonNetwork

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}

final class GluonAsyncNetworkTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    ///
    public enum TestEndpoints: Endpoint {
        case apple
        case google
        case microsoft
        case reqresPOST
        case reqresPUT
        case reqresPATCH
        case reqresDELETE
        case reqresLogin
        case notFound
        
        public var path: String {
            switch self {
                case .apple: return "https://apple.com/es"
                case .google: return "https://google.com"
                case .microsoft: return "https://microsoft.com"
                case .reqresPOST: return "https://reqres.in/api/users"
                case .reqresPUT: return "https://reqres.in/api/users/2"
                case .reqresPATCH: return "https://reqres.in/api/users/2"
                case .reqresDELETE: return "https://reqres.in/api/users/2"
                case .reqresLogin: return "https://reqres.in/api/login"
                case .notFound: return "https://apple.com/unavailable-resource"
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetAppleWebPage() async throws  {
        let expectation = self.expectation(description: "Apple page")

        let api = GluonNetwork()
        
        let response = try await api.fetch(endpoint: TestEndpoints.apple)
            
        XCTAssertNotNil(response.data, "🚨 No data recovered from Apple website")

        expectation.fulfill()
        
        self.wait(for: [ expectation ], timeout: 10.0)
    }

    func testNotFound() async throws {
        let expectation = self.expectation(description: "Not Found response test")

        let api = GluonNetwork()
        
        do {
            try await api.fetch(endpoint: TestEndpoints.notFound)
        } catch let responseError as NetworkError {
            XCTAssertEqual(responseError, .notFound, "🚨 Expected a 404 HTTP error (Not Found). Received a \(responseError) error")
        }
        
        expectation.fulfill()

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPOST() async throws {
        let expectation = self.expectation(description: "POST HTTP method test")

        let user = User(name: "Charlie Parker", jobTitle: "Private investigator")
        let api = GluonNetwork()

        let encoder = JSONEncoder()

        var parameters = NetworkRequest()
        parameters.method = .post
        parameters.payload = try? encoder.encode(user)
        
        do {
            let response = try await api.fetch(endpoint: TestEndpoints.reqresPOST, withParameters: parameters)
            XCTAssertTrue(response.httpCodeResponse == 201)
        } catch let error {
            XCTFail("🚨 Error \(error.localizedDescription)")
        }
        
        expectation.fulfill()

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPOSTFailure() async throws {
        let expectation = self.expectation(description: "POST HTTP method test")

        let login = Login(email: "myself@me.com")
        let api = GluonNetwork()

        let encoder = JSONEncoder()

        do {
            var parameters = NetworkRequest()
            parameters.method = .post
            parameters.payload = try? encoder.encode(login)
            
            try await api.fetch(endpoint: TestEndpoints.reqresLogin, withParameters: parameters)
        } catch let error as NetworkError {
            XCTAssertTrue(error == .badRequest, "🚨 Expected a bad request error")
        }
        
        expectation.fulfill()

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPUT() async throws {
        let expectation = self.expectation(description: "PUT HTTP method test")

        let user = User(name: "Roland Deschain", jobTitle: "Midworld Gunslinger")
        let api = GluonNetwork()

        let encoder = JSONEncoder()

        var parameters = NetworkRequest()
        parameters.method = .put
        parameters.payload = try? encoder.encode(user)

        do {
            let response = try await api.fetch(endpoint: TestEndpoints.reqresPUT, withParameters: parameters)
            XCTAssertTrue(response.httpCodeResponse == 200, "🚨 Expected a 200 HTTP code")
        } catch let error {
            XCTFail("🚨 Error at PUT operation. \(error.localizedDescription)")
        }
        
        expectation.fulfill()

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPATCH() async throws {
        let expectation = self.expectation(description: "PATCH HTTP method test")

        let user = User(name: "Randall Flagg", jobTitle: "The Bag Guy")
        let api = GluonNetwork()

        let encoder = JSONEncoder()

        var parameters = NetworkRequest()
        parameters.method = .patch
        parameters.payload = try? encoder.encode(user)

        do {
            let response = try await api.fetch(endpoint: TestEndpoints.reqresPATCH, withParameters: parameters)
            XCTAssertTrue(response.httpCodeResponse == 200, "🚨 Expected a 200 HTTP code")
        } catch let error {
            XCTFail("Se ha producido un error. \(error.localizedDescription)")
        }
        
        expectation.fulfill()

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testDELETE() async throws {
        let expectation = self.expectation(description: "DELETE HTTP method test")

        let api = GluonNetwork()

        var parameters = NetworkRequest()
        parameters.method = .delete

        do {
            let response = try await api.fetch(endpoint: TestEndpoints.reqresDELETE, withParameters: parameters)
            XCTAssertTrue(response.httpCodeResponse == 204, "🚨 Expected a 204 HTTP code")
        } catch let error {
            XCTFail("Se ha producido un error. \(error.localizedDescription)")
        }
        
        expectation.fulfill()

        self.wait(for: [ expectation ], timeout: 5.0)
    }
}
