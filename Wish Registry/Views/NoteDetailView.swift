//
//  NoteSheet.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//

import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    
    var body: some View {
        Form {
            if note.content.isEmpty {
                VStack {
                    HStack {
                        Text("Enter Note Here").foregroundStyle(.tertiary)
                    }
                }
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $note.content)
            }.padding()
        }
    }
}

#Preview {
    NoteDetailView(note: .constant(Note(id: 1, content: "Hello, World!")))
}
