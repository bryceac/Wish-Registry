//
//  ContentView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/14/26.
//

import SwiftUI
import UniformTypeIdentifiers
import IdentifiedCollections

struct RegistryView: View {
    @State private var store: Store = Store()
    @State private var showSaveSuccess = false
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportFormat: UTType? = nil
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(store.sortedItems) { item in
                        
                        var itemBinding: Binding<Item> {
                            Binding {
                                return item
                            } set: { newValue in
                                (item.name,
                                 item.quantity,
                                 item.priority,
                                 item.url,
                                 item.notes) = (newValue.name,
                                                newValue.quantity,
                                                newValue.priority,
                                                newValue.url,
                                                newValue.notes)
                            }

                        }
                        NavigationLink {
                            ItemDetailView(item: itemBinding)
                        } label: {
                            ItemView(item: item)
                        }
                    }.onDelete(perform: delete)
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu("Options") {
                            Button("Export Items") {
                                isExporting = true
                                exportFormat = .json
                            }
                            Button("Export Items to TSV") {
                                isExporting = true
                                exportFormat = .tsv
                            }
                            Button("Export Wishlist") {
                                isExporting = true
                                exportFormat = .html
                            }
                            Button("Import Items") {
                                isImporting = true
                            }
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            addNewItem()
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                }.onChange(of: store.items) {
                    if let lastIndex = store.items.indices.last {
                        proxy.scrollTo(store.items[lastIndex].id)
                    }
                }
            }
        }.onAppear {
            loadItems()
        }.alert("Save Successful", isPresented: $showSaveSuccess) {
            Button("Ok") {
                showSaveSuccess = false
            }
        } message: {
            Text("Wishlist Exported Successfully.")
        }.fileExporter(isPresented: $isExporting, document: WRFileDocument(items: store.sortedItems.elements), contentType: exportFormat ?? .json, defaultFilename: "wishlist") { result in
            if case .success = result {
                showSaveSuccess = true
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.json, .utf8TabSeparatedText], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "json":
                        loadItems(fromJSON: file)
                    default:
                        loadItems(fromTSV: file)
                    }
                }
            }
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "json":
                Task {
                    loadItems(fromJSON: fileURL)
                }
                
            default:
                Task {
                    loadItems(fromTSV: fileURL)
                }
            }
        }
    }
    
    @ViewBuilder var loadingOverlay: some View {
            
        if isLoading {
            ZStack {
                Color.black
                    
                ProgressView("loading data...").preferredColorScheme(.dark)
            }
        }
    }
}

extension RegistryView {
    func addNewItem() {
        guard let manager = DB.shared.manager else { return }
            
        try? manager.add(item: Item())
            
        loadItems()
    }
        
    func delete(at offsets: IndexSet) {
        guard let manager = DB.shared.manager else { return }
        for index in offsets {
            let item = store.sortedItems[index]
                
            store.sortedItems.remove(at: index)
                
            try? manager.delete(item: item)
        }
    }
        
    func retrieveItems() async -> [Item] {
            guard let manager = DB.shared.manager else { return [] }
            
            return manager.items
        }
        
    func loadItems() {
        if isLoading {
            isLoading.toggle()
        }
            
        Task {
            let items = await retrieveItems()
            store = Store(withItems: items)
                
            isLoading = false
        }
    }
        
    private func items(fromJSON file: URL) async -> [Item] {
        guard let decodedItems = try? Item.load(from: file) else { return [] }
            
        return decodedItems
    }
        
    private func items(fromTSV file: URL) async -> [Item] {
        guard let decodedItems = try? Item.load(fromTSV: file) else { return [] }
            
        return decodedItems
    }
        
    private func importItems(_ items: [Item]) {
        guard let manager = DB.shared.manager else { return }
            
        try? manager.updateOrAdd(items: items)
            
        loadItems()
    }
        
    func loadItems(fromJSON json: URL) {
        isLoading = true
            
        Task {
            let items = await items(fromJSON: json)
                
            importItems(items)
        }
    }
        
    func loadItems(fromTSV tsv: URL) {
        isLoading = true
            
        Task {
            let items = await items(fromTSV: tsv)
                
            importItems(items)
        }
    }
}

#Preview {
    RegistryView()
}
