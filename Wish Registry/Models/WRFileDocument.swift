//
//  WRFileDocument.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/16/26.
//
import Foundation
import UniformTypeIdentifiers
import SwiftUI
import Collections

extension UTType {
    static var tsv: UTType {
        UTType(importedAs: "me.brycecampbell.tsv")
    }
}

struct WRFileDocument {
    static var readableContentTypes: [UTType] = [
        .json,
        .tsv
    ]
    
    static var writableContentTypes: [UTType] = [
        .json,
        .tsv,
        .html
    ]
    
    var items: [Item] = []
    
    var sortedItems: [Item] {
        return items.sorted { firstItem, secondItem in
            firstItem.priority > secondItem.priority
        }
    }
}

extension WRFileDocument: FileDocument {
    init(configuration: ReadConfiguration) throws {
        
        if let fileData = configuration.file.regularFileContents {
            switch configuration.file.filename {
            case let .some(filename) where filename.hasSuffix("json"):
                    items = try Item.load(from: fileData)
            default:
                if let content = String(data: fileData, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines)
                    
                    items = lines.compactMap({ line in
                        Item(line)
                    })
                }
            }
        }
    }
    
    func generateTSV() -> String {
        sortedItems.map { item in
            item.description
        }.joined(separator: "\n")
    }
    
    func uniqueNotes() -> OrderedSet<String> {
        var notes: OrderedSet<String> = OrderedSet()
        
        for item in sortedItems {
            for note in item.notes {
                notes.append(note)
            }
        }
        
        return notes
    }
    
    func noteList() -> String {
        let notes = uniqueNotes()

        var noteString = "\t\t\t\t<ol id=\"notes\">\r\n"

        for (position, note) in notes.enumerated() {
            let idNumber = position+1;

            noteString += "\t\t\t\t\t<li id=\"note\(idNumber)\">\(note)</li>\r\n"
        }

        noteString += "\t\t\t\t</ol>\r\n"

        return noteString
    }
    
    func registry(item: Item) -> String {
        var details = item.quantity > 1 ? "\(item.quantity) " :
        ""

        let notes = uniqueNotes()

        if let url = item.url {
            if url.absoluteString.isEmpty {
                details += "\(item.name)";
            } else {
                details += "<a href=\"\(url)\">\(item.name)</a>"
            }
        } else {
            details += "\(item.name)"
        }

        if !item.notes.isEmpty {
            details += " "

            for (position, note) in notes.enumerated() {
                if item.notes.contains(note) {
                    let idNumber = position+1;
                    let destination = "#note\(idNumber)"
                    details += "<sup>[<a href=\"\(destination)\">\(idNumber)</a>]</sup>"
                }
            }
        }

        return details
    }
    
    func registry() -> String {
        var itemString = "\t\t\t<ol id=\"registry\">\r\n"

        for item in sortedItems {
            itemString += "\t\t\t\t<li>\(registry(item: item))</li>\r\n"
        }

        itemString += "\t\t\t</ol>\r\n"

        return itemString
    }
    
    func generateHTML() -> String {
        var html = "<!DOCTYPE html>\r\n"

            html += "<html>\r\n"
            html += "\t<head>\r\n"
            html += "\t\t<title>Wishlist</title>\r\n"
            html += "\t\t<style>\r\n"
            html += """
                \t\t\tviewport {
                \t\t\t\tzoom:1.0;
                \t\t\t\twidth:device-width;
                \t\t\t}
                \t\t\t@media screen and (max-width:980px) {
                \t\t\tbody {
                \t\t\t\tfont-size:2em;;
                \t\t\t}
                \t\t\t#registry li {
                \t\t\t\tmargin-bottom:20px;
                \t\t\t}
                \t\t\t}\r\n
                """
            html += "\t\t</style>\r\n"
            html += "\t</head>\r\n"
            html += "\t<body>\r\n"
            html += "\t\t<article>\r\n"
            html += "\t\t\t<header>\r\n"
            html += "\t\t\t\t<h1>Wishlist</h1>\r\n"
            html += "\t\t\t\t<hr>\r\n"
            html += "\t\t\t</header>\r\n"
            html += registry()
            if !uniqueNotes().isEmpty {
                html += "\t\t\t<footer>\r\n"
                html += "\t\t\t\t<h2>Notes</h2>\r\n"
                html += "\t\t\t\t<hr>\r\n"
                html += noteList()
                html += "\t\t\t</footer>\r\n"
            }
            html += "\t\t</article>\r\n"
            html += "\t</body>\r\n"
            html += "</html>"
        
        return html
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var fileWrapper = FileWrapper()
        
        switch configuration.contentType {
        case .json:
            if let jsonData = items.data {
                fileWrapper = FileWrapper(regularFileWithContents: jsonData)
            }
        case .utf8TabSeparatedText:
            if let tsvData = generateTSV().data(using: .utf8) {
                fileWrapper = FileWrapper(regularFileWithContents: tsvData)
            }
        case .html:
            if let htmlData = generateHTML().data(using: .utf8) {
                fileWrapper = FileWrapper(regularFileWithContents: htmlData)
            }
        default: ()
        }
        
        return fileWrapper
    }
}
