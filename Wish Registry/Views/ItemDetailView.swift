//
//  ItemDetailView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/14/26.
//

import SwiftUI
import Foundation

struct ItemDetailView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        Form {
            TextField("Name", text: $viewModel.item.name).submitLabel(.done)
            
            HStack {
                Stepper("Quantity") {
                    viewModel.item.quantity += 1
                } onDecrement: {
                    viewModel.item.quantity -= 1
                }
                
                Text("\(viewModel.item.quantity)")

            }
            
            HStack {
                Picker("Priority", selection: $viewModel.item.priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue)
                    }
                }.pickerStyle(.menu)
            }
            
            TextField("URL", text: viewModel.urlBinding).submitLabel(.done)
            
            Section(isExpanded: $viewModel.revealNotes) {
                List {
                    ForEach(viewModel.notes) { note in
                        
                        SelectableNoteView(note: note, item: viewModel.item) {
                            if viewModel.item.notes.contains(note.content), let noteIndex = viewModel.item.notes.firstIndex(of: note.content) {
                                viewModel.item.notes.remove(at: noteIndex)
                                
                                try? DB.shared.manager!.removeLink(betweenItemWithID: viewModel.item.id, andNoteWithID: note.id)
                            } else {
                                viewModel.item.notes.append(note.content)
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Notes")
                    Spacer()
                    if viewModel.revealNotes {
                        Button("", systemImage: "plus") {
                            viewModel.item.notes.append("")
                            
                            viewModel.presentNoteEditor = true
                            
                        }.sheet(isPresented: $viewModel.presentNoteEditor) {
                            viewModel.presentNoteEditor = false
                        } content: {
                            if let recentNoteIndex = viewModel.notes.indices.last {
                                NoteDetailView(note: viewModel.recentNoteBinding)
                            }
                        }
                    }
                    
                    Button {
                        withAnimation {
                            viewModel.revealNotes.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right").rotationEffect(!viewModel.revealNotes ? Angle(degrees: 90) : Angle(degrees: 270))
                    }

                }
            }

        }.padding()
    }
}

extension ItemDetailView {
    @Observable
    class ViewModel {
        var item: Item!
        var presentNoteEditor = false
        var revealNotes = false
        
        var urlBinding: Binding<String> {
            Binding {
                guard let url = self.item.url else { return "" }
                
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
                guard let manager = DB.shared.manager, var storedNote = manager.notes.first(where: { note in
                    note.id == newValue.id
                }) else { return }
                
                storedNote.content = newValue.content
            }

        }
    }
}

#Preview {
    ItemDetailView()
}
