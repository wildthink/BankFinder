//
//  AppDelegate.swift
//  BankFinder
//
//  Created by Jason Jobe on 3/30/20.
//  Copyright © 2020 Jason Jobe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ViewModelProvider {

    var baseViewModel: BaseViewModel = try! BaseViewModel(storageLocation: .onDisk("/Users/jason/bank.db"))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Reset the Database
        let path = Bundle.main.path(forResource: "db_create", ofType: "sql")!
        try! baseViewModel.db.execute(contentsOfFile: path)
        
        // Populate the tables with bundled JSON data
        try! baseViewModel.load("branches.json", in: .main, into: "branches")
        
        baseViewModel.handleMissingResults = { (type, table, predicate) in
            Swift.print (#line, "NO DATA", table)
            switch table {
            case "atms":
                 self.baseViewModel.load(url: .getATMs, from: "data", into: "atms")
            default:
                Swift.print (#line, "NO WAY TO GET", table)
            }
        }
        
        if let id = try? baseViewModel.select("id", from: "atms", id: 0) {
            Swift.print ("Select \(id)")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

let nessie_api_key = ""

extension URL {
    static var getATMs: URL = URL(string: "http://api.reimaginebanking.com/atms?lat=38.9283&lng=-77.1753&rad=1&key=\(nessie_api_key)")!
}
