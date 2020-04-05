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

    var window: UIWindow?

    var baseViewModel: BaseViewModel = try! BaseViewModel(storageLocation: .onDisk("/Users/jason/bank.db"))
    let loaded: NSMutableSet = NSMutableSet()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Reset the Database
        baseViewModel.delegate = self
        let path = Bundle.main.path(forResource: "db_create", ofType: "sql")!
        try! baseViewModel.db.execute(contentsOfFile: path)
        try! baseViewModel.db.createApplicationDatabase(reset: true)
        
        baseViewModel.handleMissingResults = { (model, type, table, predicate) in
            Swift.print (#line, "NO DATA found for", table)
            guard !self.loaded.contains(table) else {
                self.trace("RELOAD ATTEMPTED FOR \(table)")
                return
            }
            switch table {
            case "atms":
                try! model.load(.getATMs, keypath: "data", into: "_atms")
                self.loaded.add(table)
            case "branches":
                try! model.load(.resource("branches.json"), into: "_branches")
                self.loaded.add(table)
            case "customers":
                try! model.load(.getCustomers, into: "_customers")
                self.loaded.add(table)
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

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
}

extension AppDelegate: BaseViewModelDelegate {
    func modelWillCommit(_ vm: BaseViewModel) {
        guard let window = window else { return }
        window.rootViewController?.visit {
            $0.refresh(from: vm)
        }
    }
    
}
