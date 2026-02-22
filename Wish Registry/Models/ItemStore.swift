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
    var items: IdentifiedArrayOf<Item> {
        didSet {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.updateOrAdd(items: items)
        }
    }
    
    var sortedItems: IdentifiedArrayOf<Item> {
        get {
            IdentifiedArray(uniqueElements: items.sorted { firstItem, secondItem in
                firstItem.priority > secondItem.priority
            })
        }
        
        set(newValues) {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.updateOrAdd(items: newValues.elements)
            
            items = IdentifiedArray(uniqueElements: manager.items)
        }
    }
    
    init(withItems items: [Item] = []) {
        self.items = IdentifiedArray(uniqueElements: items)
    }
    
    func add(item: Item = Item()) {
        items.append(item)
    }
}
