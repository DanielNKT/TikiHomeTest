//
//  THTItemStore.swift
//  TikiHomeTest
//
//  Created by Nguyen Toan on 8/19/18.
//  Copyright © 2018 Nguyen Toan. All rights reserved.
//

import UIKit

class THTItemStore {
    var allItems: [THTItemObject] = []
    let itemArchiveURL: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("items.archive")
    }()
    
    init() {
        if let archivedItems =
            NSKeyedUnarchiver.unarchiveObject(withFile: itemArchiveURL.path) as? [THTItemObject] {
            allItems += archivedItems
        }
    }
    
    func createItem(itemObject:THTItemObject) {
        if allItems.contains(where: {$0.keywordItem == itemObject.keywordItem}) {
            // it exists, do something
            let index = allItems.index(where: {$0.keywordItem == itemObject.keywordItem})
            allItems.remove(at: index!)
        }
        print("count object: \(allItems.count)")
        allItems.insert(itemObject, at: 0)
    }
    
    func removeItem(_ item: THTItemObject) {
        if let index = allItems.index(of: item) {
            allItems.remove(at: index)
        }
    }
    
    func removeAllItem() {
        allItems.removeAll()
    }
    
    func saveChanges() -> Bool {
        print("Saving items to: \(itemArchiveURL.path)")
        return NSKeyedArchiver.archiveRootObject(allItems, toFile: itemArchiveURL.path)
    }
}
