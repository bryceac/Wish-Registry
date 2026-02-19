//
//  NoteRegistryView.swift
//  Wlist
//
//  Created by Bryce Campbell on 2/15/26.
//
import SwiftUI

struct NoteRegistryView: View {
    @State var notes: [Note] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notes.indices, id: \.self) { index in
                    var noteBinding: Binding<Note> {
                        Binding {
                            return notes[index]
                        } set: { newValue in
                            notes[index] = newValue
                            try? DB.shared.manager!.update(noteWithID: newValue.id, andContent: newValue.content)
                        }
                    }
                    
                    NavigationLink(destination: NoteDetailView(note: noteBinding)) {
                        NoteView(note: notes[index])
                    }
                }.onDelete(perform: delete)
            }.onAppear {
                notes = DB.shared.manager!.notes
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            
            try? DB.shared.manager?.delete(noteWithID: note.id)
        }
    }
}
