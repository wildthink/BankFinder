//
//  BaseViewModel.swift
//  ATMFinder_SQLite
//
//  Created by Jobe, Jason on 3/10/20.
//  Copyright © 2020 Jobe, Jason. All rights reserved.
//
import Foundation
import SQift

//
extension NSObject {
    func trace(line: Int = #line, file: String = #file, function: String = #function, _ msg: String = "") {
        let name = type(of: self)
        Swift.print("TRACE", line, name, function, msg)
    }
}

func trace(line: Int = #line, file: String = #file, function: String = #function, _ msg: String = "") {
    Swift.print("TRACE", line, function, msg)
}

//

public protocol FormValuesProvider {
    var namespace: String? { get }
    var modelId: String? { get }

    func formValues() -> [String:Any]
}

enum ViewModelError: String, Error {
    case MissingData, MissingBootFile, InvalidSerialization
}

public class BaseViewModel: NSObject {
    static var shared: BaseViewModel?
    
    public var db: AppDatabase
    
    init (storageLocation: StorageLocation = .inMemory) throws {

        db = try AppDatabase(storageLocation: storageLocation)
        super.init()
        try configureDatabase()
        if BaseViewModel.shared == nil {
            BaseViewModel.shared = self
        }
    }

    @objc func didCommit() {
        trace()
        // NOTE: defer the action to avoid infinite loop
//        actions.forEach { $0.performAction(with: self) }
    }

    public func set(env: String, to value: Any) {
        try? db.set(env: env, to: value)
    }
    
    public func get<A>(env: String, default alt: A? = nil) -> A? {
        db.get(env: env) as? A ?? alt
    }
    
    var handleMissingResults: ((Any.Type, _ table: String, _ predicate: String?) -> Void)?
    
    func noResultsForFetch(of type: Any.Type, from table: String, where predicate: String?) {
        handleMissingResults?(type, table, predicate)
    }
    
    func fetch<T:ExpressibleByRow> (from table: String, searchId: String = "search", searchField: String? = nil, limit: Int? = nil) -> T? {

        var whereClause = ""
        var limitClause = ""
        let test = sql_predicate(field: searchField, search: searchId)

        if let test = test {
            whereClause = " WHERE \(test)"
        }

        if let limit = limit  {
            limitClause = " LIMIT \(limit)"
        }
        let sql: SQL = "SELECT * from \(table)\(whereClause)\(limitClause)"
        var results: T?
        try? db.executeRead {
            results = try? $0.query(sql, [])
        }
        if results == nil {
            noResultsForFetch(of: T.self, from: table, where: test)
        }
        return results
    }


    func sql_predicate(field: String?, search: String?) -> String? {
        guard let field = field, let search = search else { return nil }

        if let filter = db.get(env: search) as? String {
            guard !filter.isEmpty else { return nil }
            let keys = filter.split(separator: " ")
            var pred = ""
            let end = keys.count - 1
            for (ndx, key) in keys.enumerated() {
                pred += "\(field) LIKE '%\(key)%'"
                if ndx < end { pred += " AND " }
            }
            return pred
        }
        return nil
    }

    var commitHook: Any?
    
    func configureDatabase() throws {
        try db.executeWrite {
            $0.commitHook { [weak self] () -> Bool in
                // We call the perform so we let this event complete and return
                // before refreshing with the next state
                self?.perform(#selector(BaseViewModel.didCommit), with: nil, afterDelay: 0)
                return false
            }
        }
    }

    func load (_ file: String, in bundle: Bundle = Bundle.main, from key: String? = nil, into table: String) throws {
        var path: String
        if FileManager().fileExists(atPath: file) {
            path = file
        } else if let rpath = bundle.path(forResource: file, ofType: "") {
            path = rpath
        }
        else { throw ViewModelError.MissingData }

        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)

        let package = try JSONSerialization.jsonObject(with: data, options: [])
        
        var plist: Any?
        if let key = key, !key.isEmpty {
            plist = (package as? NSObject)?.value(forKeyPath: key)
        } else {
            plist = package
        }
        guard let items = plist as? [Any] else { throw ViewModelError.InvalidSerialization }

        try db.executeWrite(.immediate) {
            for item in items {
                guard let dict = item as? [String:Any] else { continue }
                try $0.insert(into: table, from: dict)
            }
        }
    }

}

/*
extension String: Error {}

extension Connection {
    
    /// This `insert` method is useful when it is desirable to insert  values
    /// from a Dictionary.
    ///
    /// - Parameter table: The name of the table
    ///
    /// - Parameter plist: A Dictionary with values for a record.
    ///
    /// - Returns: Void
    ///
    /// - Throws: A `SQLiteError` if SQLite encounters an error stepping through the statement.
    @discardableResult
    public func insert(into table: String, from plist: [String:Any]) throws -> Int64 {
        
        var keys: [String] = []
        var slots: [String] = []
        var values: [Bindable?] = []

        func asBindable(_ any: Any) -> Bindable? {
            if let bind = any as? Bindable { return bind }
            switch any {
            case is NSArray: return (any as? [Any])
            case is NSDictionary: return (any as? [String:Any])
            case is NSString: return (any as? String)
            case let num as NSNumber:
                if num is Int { return num.intValue }
                if num is Double { return num.doubleValue }
                return (num as Any) as? Bindable
            default:
                return any as? Bindable
            }
        }
        
        for (key, val) in plist {
            keys.append(key)
            slots.append("?")
            guard let bval = asBindable(val) else {
                throw "Cannot insert non Bindable value \(val) into \(table) \(key)"
            }
            values.append(bval)
        }
        let sql: SQL = "INSERT INTO \(table) (\(keys.joined(separator: ","))) VALUES(\(slots.joined(separator: ",")))"
        
        try run(sql, values)
        return lastInsertRowID
    }
}
*/

// MARK: SQift Method Wrappers

extension BaseViewModel {

    func select(_ col: String, from table: String, id: Int) throws -> Any? {
        var result: Any?
        try db.executeRead {
            result = try $0.select(col, from: table, id: id)
        }
        return result
    }

    func select(_ cols: [String], from table: String, where test: String? = nil) throws -> [[String:Any]] {
        var result: Any?
        try db.executeRead {
            result = try $0.select(cols, from: table, where: test)
        }
        return result as? [[String:Any]] ?? []
    }

    func fetch (_ sql: SQift.SQL, _ parameters: [SQift.Bindable?], _ body: (Row) -> Void) throws {
        try db.executeRead {
            try $0.fetch(sql, parameters, body)
        }
    }

}

// MARK: UI Aware functions
import UIKit

@objc public protocol ViewModel: NSObjectProtocol {
    func refresh(view: UIView, from: String, id: Int)
}

extension ViewModel {
    
    func set(env: String, to value: Any) throws {
        try BaseViewModel.shared?.db.set(env: env, to: value)
    }

    func get<A>(env: String, default alt: A?) -> A? {
        AppDatabase.shared.get(env: env) as? A ?? alt
    }
    
    func indentifiers(for table: String, filter: String?, filterField: String?) -> [Int] {
        trace()
        let results = NSMutableArray()
        try? BaseViewModel.shared?.db.executeRead(.deferred) {
            let sql: SQL = "SELECT id FROM \(table)"
            try? $0.fetch(sql, []) { row in
                if let int: Int = row.value(at: 0) {
                    results.add(int)
                }
            }
        }
        return (results as? [Int]) ?? []
    }

}

extension BaseViewModel: ViewModel {
    
    public func refresh(view: UIView, from table: String, id: Int) {
        view.visit {
            guard let key = $0.modelId else { return }
            let value = try? select(key, from: table, id: id)
            $0.contentValue = value
        }
    }
    
    func indentifiers(for table: String, filter: String?, filterField: String?) -> [Int] {
        trace()
        let results = NSMutableArray()
        try? BaseViewModel.shared?.db.executeRead(.deferred) {
            let sql: SQL = "SELECT id FROM \(table)"
            try? $0.fetch(sql, []) { row in
                if let int: Int = row.value(at: 0) {
                    results.add(int)
                }
            }
        }
        return (results as? [Int]) ?? []
    }

}

extension UIViewController {
    @objc public func refresh(from model: ViewModel) {
    }
}

protocol ViewModelProvider {
    var baseViewModel: BaseViewModel { get }
}

extension UIResponder {
    var viewModel: ViewModel? {
        return (self as? ViewModel)
            ?? (self as? ViewModelProvider)?.baseViewModel
            ?? next?.viewModel
            ?? BaseViewModel.shared
    }
}
