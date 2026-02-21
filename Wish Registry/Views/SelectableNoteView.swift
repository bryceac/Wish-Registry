//
//  SelectableNote.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//

import SwiftUI

struct SelectableNoteView: View {
    @State var note: Note
    var isSelected: Bool
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
