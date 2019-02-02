//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Abdullah Aldakhiel on 25/01/2019.
//  Copyright © 2019 Abdullah Aldakhiel. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DataController.shared.load()
        return true
    }
    
}

