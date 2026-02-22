//
//  Store.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/20/26.
//
import IdentifiedCollections
import Foundation

@Observable
class ItemStore {
    var items: IdentifiedArrayOf<Item> = []
    
    var sortedItems: IdentifiedArrayOf<Item> {
        IdentifiedArray(uniqueElements: items.sorted { firstItem, secondItem in
                firstItem.priority > secondItem.priority
        })
    }
    
    func add(item: Item = Item()) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.updateOrAdd(item: item)
        
        items = IdentifiedArray(uniqueElements: manager.items)
    }
    
    func add(items: [Item]) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.updateOrAdd(items: items)
        
        self.items = IdentifiedArray(uniqueElements: manager.items)
    }
    
    func remove(item: Item) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.delete(item: item)
        
        items = IdentifiedArray(uniqueElements: manager.items)
    }
    
    func update(item: Item) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.update(item: item)
        
        items = IdentifiedArray(uniqueElements: manager.items)
    }
}
