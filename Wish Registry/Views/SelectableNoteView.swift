//
//  SelectableNote.swift
//  Wlist
//
//  Created by Bryce Campbell on 2/15/26.
//

import SwiftUI

struct SelectableNoteView: View {
    @State var note: Note
    var isSelected: Bool
    var action: (Note) -> ()
    
    var body: some View {
        HStack {
            if isSelected {
                Image(systemName: "checkmark")
                Spacer()
            }
            
            NoteView(note: note)
        }
    }
}
