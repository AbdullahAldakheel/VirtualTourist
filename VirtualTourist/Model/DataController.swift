//
//  DataController.swift
//  VirtualTourist
//
//  Created by Abdullah Aldakhiel on 31/01/2019.
//  Copyright © 2019 Abdullah Aldakhiel. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    static let shared = DataController()
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Vr")
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
