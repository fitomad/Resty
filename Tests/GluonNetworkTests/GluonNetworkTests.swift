import XCTest
import Combine
@testable import GluonNetwork

final class GluonNetworkTests: XCTestCase {
    private var subscribers = Set<AnyCancellable>()
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
        
        private var basePath: String {
            return "..."
        }
        
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
    
    func testGetAppleWebPage() throws {
        let expectation = self.expectation(description: "Apple page")

        let api = GluonNetwork()
        
        api.publisher(for: TestEndpoints.apple)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { apiResponse in
                XCTAssertNotNil(apiResponse.data)
            })
            .store(in: &subscribers)
        
        self.wait(for: [ expectation ], timeout: 10.0)
    }

    func testNotFound() {
        let expectation = self.expectation(description: "Not Found response test")

        let api = GluonNetwork()
        
        api.publisher(for: TestEndpoints.notFound)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let NetworkError) = completion {
                    if case NetworkError.notFound = NetworkError {
                        XCTAssertTrue(true)
                    } else {
                        XCTFail("Expected a not found (404) error")
                    }
                }

                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Expected a request failure")
            })
            .store(in: &subscribers)

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPOST() {
        let expectation = self.expectation(description: "POST HTTP method test")

        let user = User(name: "Charlie Parker", jobTitle: "Private investigator")
        let api = GluonNetwork()
        
        let encoder = JSONEncoder()

        var parameters = NetworkRequest()
        parameters.method = .post
        parameters.payload = try? encoder.encode(user)

        api.publisher(for: TestEndpoints.reqresPOST, withParameter: parameters)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let NetworkError) = completion {
                    XCTFail("Se ha producido un error. \(NetworkError)")
                }

                expectation.fulfill()
            }, receiveValue: { apiResponse in
                XCTAssertTrue(apiResponse.httpCodeResponse == 201)
            })
            .store(in: &subscribers)

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPOSTFailure() {
        let expectation = self.expectation(description: "POST HTTP method test")

        let login = Login(email: "myself@me.com")
        let api = GluonNetwork()

        let encoder = JSONEncoder()

        var parameters = NetworkRequest()
        parameters.method = .post
        parameters.payload = try? encoder.encode(login)

        api.publisher(for: TestEndpoints.reqresLogin, withParameter: parameters)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let NetworkError) = completion {
                    if case NetworkError.badRequest = NetworkError {
                        XCTAssertTrue(true)
                    } else {
                        XCTFail("Expected a bad request error")
                    }
                }

                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Expected a request failure")
            })
            .store(in: &subscribers)

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPUT() {
        let expectation = self.expectation(description: "PUT HTTP method test")

        let user = User(name: "Roland Deschain", jobTitle: "Midworld Gunslinger")
        let api = GluonNetwork()

        let encoder = JSONEncoder()

        var parameters = NetworkRequest()
        parameters.method = .put
        parameters.payload = try? encoder.encode(user)

        api.publisher(for: TestEndpoints.reqresPUT, withParameter: parameters)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let NetworkError) = completion {
                    XCTFail("Se ha producido un error. \(NetworkError)")
                }

                expectation.fulfill()
            }, receiveValue: { apiResponse in
                XCTAssertTrue(apiResponse.httpCodeResponse == 200)
            })
            .store(in: &subscribers)

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPATCH() {
        let expectation = self.expectation(description: "PATCH HTTP method test")

        let user = User(name: "Randall Flagg", jobTitle: "The Bag Guy")
        let api = GluonNetwork()

        let encoder = JSONEncoder()

        var parameters = NetworkRequest()
        parameters.method = .patch
        parameters.payload = try? encoder.encode(user)

        api.publisher(for: TestEndpoints.reqresPATCH, withParameter: parameters)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let NetworkError) = completion {
                    XCTFail("Se ha producido un error. \(NetworkError)")
                }

                expectation.fulfill()
            }, receiveValue: { apiResponse in
                XCTAssertTrue(apiResponse.httpCodeResponse == 200)
            })
            .store(in: &subscribers)

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testDELETE() {
        let expectation = self.expectation(description: "DELETE HTTP method test")

        let api = GluonNetwork()

        var parameters = NetworkRequest()
        parameters.method = .delete

        api.publisher(for: TestEndpoints.reqresDELETE, withParameter: parameters)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let NetworkError) = completion {
                    XCTFail("Se ha producido un error. \(NetworkError)")
                }

                expectation.fulfill()
            }, receiveValue: { apiResponse in
                XCTAssertTrue(apiResponse.httpCodeResponse == 204)
            })
            .store(in: &subscribers)

        self.wait(for: [ expectation ], timeout: 5.0)
    }

    func testPerformanceRegularRequest() {
        // This is an example of a performance test case.
        self.measure {
            try? self.testGetAppleWebPage()
        }
    }

    func testPerformancePOSTRequest() {
        // This is an example of a performance test case.
        self.measure {
            self.testPOST()
        }
    }
}
