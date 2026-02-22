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
    
    init(withNotes notes: [Note] = []) {
        self.notes = IdentifiedArray(uniqueElements: notes)
    }
}
