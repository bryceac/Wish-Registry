//
//  NoteStore.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/22/26.
//
import IdentifiedCollections
import Foundation

@Observable
class NoteStore {
    var notes: IdentifiedArrayOf<Note>
    
    var latestNote: Note? {
        return notes.last
    }
    
    var noteLinks: [String: [Int]] {
        guard let manager = DB.shared.manager else { return [:] }
        
        return manager.noteLinks
    }
    
    init(withNotes notes: [Note] = []) {
        self.notes = IdentifiedArray(uniqueElements: notes)
    }
}
