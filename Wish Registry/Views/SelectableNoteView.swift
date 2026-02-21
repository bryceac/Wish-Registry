//
//  SelectableNote.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//

import SwiftUI

struct SelectableNoteView: View {
    @State var note: Note
    @State var item: Item
    
    var isSelected: Bool {
        return item.notes.contains(note.content)
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
