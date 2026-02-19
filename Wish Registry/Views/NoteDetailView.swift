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
            ZStack(alignment: .topLeading) {
                TextEditor(text: $note.content).frame(minWidth: 50, idealWidth: 60, maxWidth: 100, minHeight: 50, idealHeight: 60, maxHeight: 100)
                
                if note.content.isEmpty {
                    VStack {
                        HStack {
                            Text("Enter Note Here").foregroundStyle(.tertiary)
                        }
                    }
                }
            }.padding()
        }
    }
}

#Preview {
    NoteDetailView(note: .constant(Note(id: 1, content: "Hello, World!")))
}
