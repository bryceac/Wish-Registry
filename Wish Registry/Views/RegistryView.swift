//
//  ContentView.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/14/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct RegistryView: View {
    @State var items: [Item] = []
    @State var showSaveSuccess = false
    @State var isExporting = false
    @State var isImporting = false
    @State var exportFormat: UTType? = nil
    @State var isLoading = false
    
    var sortedItems: [Item] {
        get {
            items.sorted { firstItem, secondItem in
                firstItem.priority > secondItem.priority
            }
        }
        
        set {
            
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(sortedItems.indices, id: \.self) { index in
                        
                        NavigationLink {
                            ItemDetailView(item: $sortedItems[index])
                        } label: {
                            ItemView(item: sortedItems[index])
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
                            let item = Item()
                            
                            try? DB.shared.manager?.add(item: item)
                            
                            loadItems()
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                }.onChange(of: items) {
                    if let lastIndex = items.indices.last, let storedItem = sortedItems.first(where: { housedItem in
                        items[lastIndex].id == housedItem.id
                    }) {
                        proxy.scrollTo(storedItem.id)
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
        }.fileExporter(isPresented: $isExporting, document: WRFileDocument(items: items), contentType: exportFormat ?? .json, defaultFilename: "wishlist") { result in
            if case .success = result {
                showSaveSuccess = true
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.json, .utf8TabSeparatedText], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "json":
                        Task {
                            let parsedItems = await items(fromJSON: file)
                            
                            importItems(parsedItems)
                        }
                        
                    default:
                        Task {
                            let parsedItems = await items(fromTSV: file)
                            
                            importItems(parsedItems)
                        }
                    }
                }
            }
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "json":
                Task {
                    let parsedItems = await items(fromJSON: fileURL)
                    
                    importItems(parsedItems)
                }
                
            default:
                Task {
                    let parsedItems = await items(fromTSV: fileURL)
                    
                    importItems(parsedItems)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let item = sortedItems[index]
            
            if let index = items.firstIndex(where: { storedItem in
                
                storedItem.id == item.id
            }) {
                items.remove(at: index)
            }
            
            try? DB.shared.manager?.delete(item: item)
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
    
    func retrieveItems() async -> [Item] {
        guard let manager = DB.shared.manager else { return [] }
        
        return manager.items
    }
    
    func loadItems() {
        if !isLoading {
            isLoading.toggle()
        }
        
        Task {
            let items = await retrieveItems()
            self.items = items
            
            isLoading = false
        }
    }
    
    func items(fromJSON file: URL) async -> [Item] {
        guard let decodedItems = try? Item.load(from: file) else { return [] }
        
        return decodedItems
    }
    
    func items(fromTSV file: URL) async -> [Item] {
        guard let decodedItems = try? Item.load(fromTSV: file) else { return [] }
        
        return decodedItems
    }
    
    func importItems(_ items: [Item]) {
        guard let manager = DB.shared.manager else { return }
        
        for item in items {
            try? manager.updateOrAdd(item: item)
        }
        
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
    RegistryView(items: [
        Item("9F432FA2-12D2-4B61-AA55-319D23601C4E\tNintendo Switch 2\t1\thighest\thttps://example.com/nintendo-switch-2"),
        Item("15278603-03F1-41E0-81ED-6E94883F9AC7\tMario Kart World\t1\thigh\thttps://example.com/mario-kart-world"),
        Item("C58232DE-AD35-4188-9736-66BC7CA52E09\tTrails in the Sky the 1st\t1\tmedium\thttps://example.com/trails-in-the-sky")
    ].compactMap({ item in
        item
    }))
}
