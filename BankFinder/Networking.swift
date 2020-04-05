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

let iplist =  NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Config", ofType: "plist")!)

var nessie_api_key: String {
    iplist?.value(forKey: "NessieAPIKey") as? String ?? "MissingAPIKey"
}

extension URL {
    
    static func resource(_ path: String, in b: Bundle = .main) -> URL? {
        b.url(forResource: path, withExtension: nil)
    }
    static func api(_ p: String, params: String = "") -> URL? { URL(string: "http://api.reimaginebanking.com/\(p)?key=\(nessie_api_key)&\(params)") }

    static var getATMs: URL? = .api("atms", params:"lat=38.9283&lng=-77.1753&rad=1")

    static var getCustomers: URL? = .api("customers")

    static func getAccountsForCustomer(id: String) -> URL? { .api("customers/\(id)/accounts") }
}
