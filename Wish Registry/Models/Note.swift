//
//  Note.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/14/26.
//
import Foundation

@Observable
class Note: Identifiable {
    let id: Int
    var content: String {
        didSet {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.update(noteWithID: self.id, andContent: content)
        }
    }
    
    init(id: Int, content: String) {
        self.id = id
        self.content = content
    }
}
