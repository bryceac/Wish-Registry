//
//  NoteView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//
import SwiftUI

struct NoteView: View {
    @State var note: Note
    
    var body: some View {
        Text(note.content.isEmpty ? "New Note" : note.content.components(separatedBy: .newlines).first!)
    }
}
