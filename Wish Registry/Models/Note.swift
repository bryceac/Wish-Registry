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
    var content: String
    
    init(id: Int, content: String) {
        self.id = id
        self.content = content
    }
}
