//
//  NoteRegistryView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//
import SwiftUI
import IdentifiedCollections

struct NoteRegistryView: View {
    @Environment(NoteStore.self) private var store
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.notes) { note in
                    
                    var noteBinding: Binding<Note> {
                        Binding {
                            return note
                        } set: { newValue in
                            store.update(note: newValue)
                        }
                    }
                    
                    NavigationLink(destination: NoteDetailView(note: noteBinding).navigationTitle("Note Editor")) {
                        NoteView(note: note)
                    }
                }.onDelete(perform: delete)
            }
        }
    }
}

extension NoteRegistryView {
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let note = store.notes[index]
                
            store.remove(note: note)
        }
    }
}
