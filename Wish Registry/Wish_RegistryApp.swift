//
//  Wish_RegistryApp.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/18/26.
//

import SwiftUI

@main
struct Wish_RegistryApp: App {
    let itemStore = ItemStore()
    let noteStore = NoteStore()
    var body: some Scene {
        WindowGroup {
            
            TabView {
                RegistryView().tabItem {
                    Text("Items")
                }.navigationTitle("Item Registry")
                    .environment(itemStore)
                    .environment(noteStore)
                NoteRegistryView().tabItem {
                    Text("Notes")
                }.navigationTitle("Note Registry")
                    .environment(noteStore)
            }
            
        }
    }
}
