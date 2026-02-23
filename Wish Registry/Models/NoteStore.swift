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
    
    init() {
        if let manager = DB.shared.manager {
            notes = IdentifiedArray(uniqueElements: manager.notes)
        } else {
            notes = []
        }
    }
    
    func reload() {
        guard let manager = DB.shared.manager else { return }
        
        notes = IdentifiedArray(uniqueElements: manager.notes)
    }
    
    func add(note: String = "") {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.add(note: note)
        
        reload()
    }
    
    func add(notes: [String]) {
        guard let manager = DB.shared.manager else { return }
        
        for note in notes {
            try? manager.add(note: note)
        }
        
        reload()
    }
    
    func remove(note: Note) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.delete(noteWithID: note.id)
        
        reload()
    }
    
    func update(note: Note) {
        guard let manager = DB.shared.manager else { return }
        
        try? manager.update(noteWithID: note.id, andContent: note.content)
        
        reload()
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
