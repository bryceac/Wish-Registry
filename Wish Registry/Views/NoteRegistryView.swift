//
//  NoteRegistryView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//
import SwiftUI

struct NoteRegistryView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes.indices, id: \.self) { index in
                    
                    NavigationLink(destination: NoteDetailView(note: $viewModel.notes[index])) {
                        NoteView(note: viewModel.notes[index])
                    }
                }.onDelete(perform: viewModel.delete)
            }.onAppear {
                viewModel.loadNotes()
            }
        }
    }
}

extension NoteRegistryView {
    @Observable
    class ViewModel {
        var notes: [Note] = []
        
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
}
