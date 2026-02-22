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
    
    init() {
        if let manager = DB.shared.manager {
            notes = IdentifiedArray(uniqueElements: manager.notes)
        } else {
            notes = []
        }
    }
    
    func add(note: String = "") {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.add(note: note)
        
        notes = IdentifiedArray(uniqueElements: manager.notes)
    }
    
    func add(notes: [String]) {
        guard let manager = DB.shared.manager else { return }
        
        for note in notes {
            try? manager.add(note: note)
        }
        
        self.notes = IdentifiedArray(uniqueElements: manager.notes)
    }
    
    func remove(note: Note) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.delete(noteWithID: note.id)
        
        notes = IdentifiedArray(uniqueElements: manager.notes)
    }
    
    func link(note: Note, toItemWithID itemID: String) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.link(noteWithID: note.id, toItemWithID: itemID)
    }
    
    func unlink(note: Note, froItemWithID itemID: String) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.removeLink(betweenItemWithID: itemID, andNoteWithID: note.id)
    }
}
