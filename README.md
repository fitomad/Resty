# GluonNetwork

Network layer framework written 100% Swift. Developers can consume REST APIs in two ways

* [Reactive](#reactive). Using the `Combine` framework
* [Single-Shot](#async/await) operation. With the `async/await` pattern

## Consuming a HTTP API with GluonNetwork framework

First of all we need a REST API to consume. This consumption is done through endpoints, that are a set of URL.

For that reason GluonFramework provides a protocol named Endpoint that is the type expected for the whole network operations across the framework.

This protocol defines only one variable named path that represents an URL

```swift
var path: String { get }
```

This `path` variable is a `String` type, that is because we want to provide an easy an versatil for developers to build and create URL paths.

We recommend define an enumeration with the endpoints that are going to be requested and make that enumerations adopts the Endpoint protocol. Let us show you an example

```swift
enum AppleEndpoints {
    case mainPage
    case regionalMainPage(countryCode: String)
    case developers
}

extension AppleEndpoints: Endpoint {
    var path: String {
        switch self {
            case .mainPage:
                return "https://www.apple.com"
            case .regionalMainPage(let countryCode):
                return "https://www.apple.com/\(countryCode)/"
            case .developers:
                return "https://developer.apple.com/"
        }
    }
}
```

As you can see in the example above, we use the enumeration associated values to build the URL dynamically. For example, if we want to consume the spanish version of the Apple main page we do something like this

```swift
let appleSpain = AppleEndpoints.regionalMainPage(countryCode: "es")
```

Now that we can set the URL that we need to consume, but what about query parameters, payload...? Let me introduce you the `NetworkRequest` structure  

Thanks to the `NetworkRequest` we can customize the HTTP request that que want to perform in four ways

* HTTP method
* Query parameters
* HTTP headers
* Body payload

### HTTP method
You can set the HTTP method needed in your request with the `HttpMethod` enumeration

### HTTP headers
Request headers will be set using a Dictionary with a key of `String` type and values with `String` values too.

### Body Payload
The HTTP request body payload is expected as a `Data` type

### Query Parameters
The URL query items in GluonNetwork conforms the `QueryParameter` protocol thar defines a property named `queryItem` of type `URLQueryItem`

```swift
var queryItem: URLQueryItem { get }
```

We recommend create an enum that conforms the `QueryParameter` protocol and create different enumerations grouped by their functionality. For example we will have en enumeration with the pagination parameters and other one with the filter ones.

```swift
enum Pagination: QueryParameter {
    case offset(value: Int)
    case page(value: Int)
    case limit(value: Int)
    
    var queryItem: URLQueryItem {
        switch self {
            case .offset(let value): 
                return URLQueryItem(name: "offset", value: "\(value)")
            case .page(let value): 
                return URLQueryItem(name: "page", value: "\(value)")
            case .limit(let value): 
                return URLQueryItem(name: "limit", value: "\(value)")
        }
    }
}

enum Filter: QueryParameter {
    case term(value: String)
    
    var queryItem: URLQueryItem {
        switch self {
            case .term(let value): 
                return URLQueryItem(name: "term", value: "\(value)")
        }
    }
}
```

And now, all together

```swift
let globant = Company(name: "Company", country: "Argentina")

let query: [QueryParameter] = [
    Filter.term(value: "apple")
]

var parameters = NetworkRequest()
parameters.method = .post
parameters.queryParameters = query
parameters.payload = try? JSONEncoder().encode(globant)
```

Now we are ready to perform a network request.

## Reactive

```swift
var subscribers = Set<AnyCancellable>()
let api = GluonNetwork()

api.publisher(for: TestEndpoints.apple)
    .receive(on: DispatchQueue.main)
    .sink(receiveCompletion: { completion in
        if case .failure(let networkError) = completion {
            ...
        }
    }, receiveValue: { apiResponse in
        ...
    })
    .store(in: &subscribers)
```

## Async/Await

```swift
let api = GluonNetwork()

do {
    let response = try await api.fetch(endpoint: TestEndpoints.apple)
} catch let error as NetworkError {
    ...
}
```
