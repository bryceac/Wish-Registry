//
//  NoteRegistryView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//
import SwiftUI

struct NoteRegistryView: View {
    @State private var notes: [Note] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    
                    var NoteBinding: Binding<Note> {
                        Binding {
                            return note
                        } set: { newValue in
                            note.content = newValue.content
                        }

                    }
                    
                    NavigationLink(destination: NoteDetailView(note: NoteBinding)) {
                        NoteView(note: note)
                    }
                }.onDelete(perform: delete)
            }.onAppear {
                loadNotes()
            }
        }
    }
}

extension NoteRegistryView {
    func loadNotes() {
        guard let manager = DB.shared.manager else { return }
        notes = manager.notes
    }
        
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
                
            try? DB.shared.manager?.delete(noteWithID: note.id)
        }
    }
}
