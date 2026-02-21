//
//  ItemDetailView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/14/26.
//

import SwiftUI
import Foundation

struct ItemDetailView: View {
    @Binding var item: Item
    @State var presentNoteEditor = false
    @State var revealNotes = false
    
    var urlBinding: Binding<String> {
        Binding {
            guard let url = item.url else { return "" }
            
            return url.absoluteString
        } set: { newValue in
            guard let url = URL(string: newValue) else { return }
            
            item.url = url
        }

    }
    
    var recentNoteBinding: Binding<Note> {
        Binding {
            return DB.shared.manager!.notes.last!
        } set: { newValue in
            try? DB.shared.manager!.update(noteWithID: newValue.id, andContent: newValue.content)
        }

    }
    
    var body: some View {
        Form {
            TextField("Name", text: $item.name).submitLabel(.done)
            
            HStack {
                Stepper("Quantity") {
                    item.quantity += 1
                } onDecrement: {
                    item.quantity -= 1
                }
                
                Text("\(item.quantity)")

            }
            
            HStack {
                Picker("Priority", selection: $item.priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue)
                    }
                }.pickerStyle(.menu)
            }
            
            TextField("URL", text: urlBinding).submitLabel(.done)
            
            Section(isExpanded: $revealNotes) {
                List {
                    ForEach(DB.shared.manager!.notes) { note in
                        
                        SelectableNoteView(note: note, isSelected: item.notes.contains(note.content)) {
                            if item.notes.contains(note.content), let noteIndex = item.notes.firstIndex(of: note.content) {
                                item.notes.remove(at: noteIndex)
                                
                                try? DB.shared.manager!.removeLink(betweenItemWithID: item.id, andNoteWithID: note.id)
                            } else {
                                item.notes.append(note.content)
                                
                                try? DB.shared.manager!.link(noteWithID: note.id, toItemWithID: item.id)
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Notes")
                    Spacer()
                    if revealNotes {
                        Button("", systemImage: "plus") {
                            try? DB.shared.manager?.add(note: "")
                            
                            item.notes.append(DB.shared.manager!.notes.last!.content)
                            
                            try? DB.shared.manager?.link(noteWithID: DB.shared.manager!.notes.last!.id, toItemWithID: item.id)
                            
                            presentNoteEditor = true
                            
                        }.sheet(isPresented: $presentNoteEditor) {
                            presentNoteEditor = false
                        } content: {
                            NoteDetailView(note: recentNoteBinding)
                        }
                    }
                    
                    Button {
                        withAnimation {
                            revealNotes.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right").rotationEffect(!revealNotes ? Angle(degrees: 90) : Angle(degrees: 270))
                    }

                }
            }

        }.padding()
    }
}

#Preview {
    ItemDetailView(item: .constant(Item(name: "Mario Kart World", andNotes: [
        "Only if I get the Switch 2"
    ])))
}
