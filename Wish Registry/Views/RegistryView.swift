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
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.store.sortedItems) { item in
                        
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            ItemView(item: item)
                        }
                    }.onDelete(perform: viewModel.delete)
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu("Options") {
                            Button("Export Items") {
                                viewModel.isExporting = true
                                viewModel.exportFormat = .json
                            }
                            Button("Export Items to TSV") {
                                viewModel.isExporting = true
                                viewModel.exportFormat = .tsv
                            }
                            Button("Export Wishlist") {
                                viewModel.isExporting = true
                                viewModel.exportFormat = .html
                            }
                            Button("Import Items") {
                                viewModel.isImporting = true
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
                }.onChange(of: viewModel.store.items) {
                    if let lastIndex = viewModel.store.items.indices.last {
                        proxy.scrollTo(viewModel.store.items[lastIndex].id)
                    }
                }
            }
        }.onAppear {
            loadItems()
        }.alert("Save Successful", isPresented: $viewModel.showSaveSuccess) {
            Button("Ok") {
                viewModel.showSaveSuccess = false
            }
        } message: {
            Text("Wishlist Exported Successfully.")
        }.fileExporter(isPresented: $viewModel.isExporting, document: WRFileDocument(items: items.sortedItems.elements), contentType: exportFormat ?? .json, defaultFilename: "wishlist") { result in
            if case .success = result {
                viewModel.showSaveSuccess = true
            }
        }.fileImporter(isPresented: $viewModel.isImporting, allowedContentTypes: [.json, .utf8TabSeparatedText], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "json":
                        Task {
                            let parsedItems = await items(fromJSON: file)
                            
                            viewModel.importItems(parsedItems)
                        }
                        
                    default:
                        Task {
                            let parsedItems = await viewModel.items(fromTSV: file)
                            
                            viewModel.importItems(parsedItems)
                        }
                    }
                }
            }
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "json":
                Task {
                    let parsedItems = await viewModel.items(fromJSON: fileURL)
                    
                    viewModel.importItems(parsedItems)
                }
                
            default:
                Task {
                    let parsedItems = await viewModel.items(fromTSV: fileURL)
                    
                    viewModel.importItems(parsedItems)
                }
            }
        }
    }
    
    
    
    @ViewBuilder var loadingOverlay: some View {
            
        if viewModel.isLoading {
            ZStack {
                Color.black
                    
                ProgressView("loading data...").preferredColorScheme(.dark)
            }
        }
    }
}

extension RegistryView {
    @Observable class ViewModel {
        var store: Store = Store()
        var showSaveSuccess = false
        var isExporting = false
        var isImporting = false
        var exportFormat: UTType? = nil
        var isLoading = false
        
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
        
        func importItems(_ items: [Item]) {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.updateOrAdd(items: items)
            
            loadItems()
        }
        
        func loadItems(fromJSON json: URL) {
            viewModel.isLoading = true
            
            Task {
                let items = await items(fromJSON: json)
                
                importItems(items)
            }
        }
        
        func loadItems(fromTSV tsv: URL) {
            viewModel.isLoading = true
            
            Task {
                let items = await items(fromTSV: tsv)
                
                importItems(items)
            }
        }
    }
}

#Preview {
    RegistryView()
}
