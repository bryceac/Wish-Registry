//
//  NoteSheet.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//

import SwiftUI

struct NoteDetailView: View {
    @FocusState private var editorHasFocus: Bool
    
    @Binding var note: Note
    
    var body: some View {
        Form {
            ZStack(alignment: .topLeading) {
                if note.content.isEmpty &&  !editorHasFocus {
                    VStack {
                        HStack {
                            Text("Enter Note Here").foregroundStyle(.tertiary)
                        }
                    }
                }
                TextEditor(text: $note.content).focused($editorHasFocus)
            }.padding()
        }
    }
}

#Preview {
    NoteDetailView(note: .constant(Note(id: 1, content: "Hello, World!")))
}
