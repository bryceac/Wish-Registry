//
//  SelectableNote.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//

import SwiftUI

struct SelectableNoteView: View {
    @Environment(NoteStore.self) private var noteStore
    @State var note: Note
    var itemID: String
    
    var isSelected: Bool {
        guard let noteIDs = noteStore.noteLinks[itemID] else { return false }
        
        return noteIDs.contains(note.id)
    }
    
    var action: () -> ()
    
    var body: some View {
        HStack {
            Button(action: action) {
                NoteView(note: note)
            }
            if isSelected {
                Spacer()
                Image(systemName: "checkmark")
            }
            
        }
    }
}
