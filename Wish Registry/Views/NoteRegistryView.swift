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
                ForEach(notes.indices, id: \.self) { index in
                    
                    NavigationLink(destination: NoteDetailView(note: $notes[index])) {
                        NoteView(note: notes[index])
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
