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
        
        try? manager.add(item: item)
        
        items = IdentifiedArray(uniqueElements: manager.items)
    }
}
