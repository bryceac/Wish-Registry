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
    @State private var presentNoteEditor = false
    @State private var revealNotes = false
    
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
                        
                        SelectableNoteView(note: note, item: item) {
                            if item.notes.contains(note.content), let noteIndex = item.notes.firstIndex(of: note.content) {
                                item.notes.remove(at: noteIndex)
                                
                                try? DB.shared.manager!.removeLink(betweenItemWithID: item.id, andNoteWithID: note.id)
                            } else {
                                item.notes.append(note.content)
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
                            item.notes.append("")
                            
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

extension ItemDetailView {
    var urlBinding: Binding<String> {
        Binding {
            guard let url = item.url else { return "" }
                
            return url.absoluteString
        } set: { newValue in
            guard let url = URL(string: newValue) else { return }
                
            self.item.url = url
        }
    }
        
    var recentNoteBinding: Binding<Note> {
        Binding {
            return DB.shared.manager!.notes.last!
        } set: { newValue in
            guard let manager = DB.shared.manager, let storedNote = manager.notes.last else { return }
                
            storedNote.content = newValue.content
        }

    }
}

#Preview {
    ItemDetailView(item: .constant(Item("\tNintendo Switch 2\t1\thighest\t")!))
}
