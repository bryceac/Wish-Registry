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
    var itemNotes: [String]
    
    var isSelected: Bool {
        return itemNotes.contains(note.content)
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
