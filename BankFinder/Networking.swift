//
//  Networking.swift
//  BankFinder
//
//  Created by Jason Jobe on 4/3/20.
//  Copyright © 2020 Jason Jobe. All rights reserved.
//

import Foundation

public extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }
}

let iplist =  NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)

var nessie_api_key: String {
    iplist?.value(forKey: "NessieAPIKey") as? String ?? "MissingAPIKey"
}

extension URL {
    
    static func resource(_ path: String, in b: Bundle = .main) -> URL? {
        b.url(forResource: path, withExtension: nil)
    }
    static func api(_ p: String) -> URL? { URL(string: "http://api.reimaginebanking.com/\(p)") }

    static var getATMs: URL? = .api("atms?lat=38.9283&lng=-77.1753&rad=1&key=\(nessie_api_key)")

    static var getCustomers: URL? = .api("customers?key=\(nessie_api_key)")

    static var getAccounts: URL? = .api("customers/1/accounts?key=\(nessie_api_key)")
}

/*
struct Endpoint {
    let scheme: String
    let host: String
    let path: String
    let queryItems: [URLQueryItem]

    init(staticString string: StaticString) {
        let url = URL(staticString: string)
        self.scheme = url.scheme ?? "https"
        self.host = url.host ?? "localhost"
        self.path = url.path
        let urlc = URLComponents(url: url, resolvingAgainstBaseURL: <#T##Bool#>)
    }

    init?(string: String) {
        guard let u = URL(string: string) else { return nil }
        self.url = u
    }
}

extension Endpoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}
*/

/*
extension Endpoint {
    static func search(matching query: String,
                       sortedBy sorting: Sorting = .recency) -> Endpoint {
        return Endpoint(
            path: "/search/repositories",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue)
            ]
        )
    }
}

extension Endpoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}


class DataLoader {
    func request(_ endpoint: Endpoint,
                 then handler: @escaping (Result<Data>) -> Void) {
        guard let url = endpoint.url else {
            return handler(.failure(Error.invalidURL))
        }

        let task = urlSession.dataTask(with: url) {
            data, _, error in

            let result = data.map(Result.success) ??
                        .failure(Error.network(error))

            handler(result)
        }

        task.resume()
    }
}
*/

