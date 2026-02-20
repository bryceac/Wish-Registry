//
//  DatabaseManager.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/14/26.
//
import SQLite
import Foundation

class DBManager {
    private var db: Connection
    
    var notes: [Note] {
        guard let notes = try? retrieveNotes() else { return [] }
        
        return notes
    }
    
    var items: [Item] {
        guard let items = try? retrieveItems() else { return [] }
        
        return items
    }
    
    // Tables
    let itemTable = Table("items")
    let notesTable = Table("notes")
    let itemNotesTable = Table("item_notes")
    
    // items table fields
    let itemID = SQLite.Expression<String>("id")
    let itemName = SQLite.Expression<String>("name")
    let itemQuantity = SQLite.Expression<Int>("quantity")
    let itemPriority = SQLite.Expression<String>("priority")
    let itemURL = SQLite.Expression<String?>("url")
    
    // notes table fields
    let noteID = SQLite.Expression<Int>("id")
    let noteContent = SQLite.Expression<String>("note")
    
    // item_note_table fields
    let linkedItemID = SQLite.Expression<String>("item_id")
    let linkedNoteID = SQLite.Expression<Int>("note_id")
    
    init(withDB db: URL) throws {
        self.db = try Connection(db.absoluteString)
    }
    
    func initializeDatabase() throws {
        try db.run(itemTable.create(ifNotExists: true) { t in
            t.column(itemID, primaryKey: true)
            t.column(itemName, defaultValue: "")
            t.column(itemQuantity, defaultValue: 1)
            t.column(itemPriority, check: Priority.allCases.map { priority in
                priority.rawValue
            }.contains(itemPriority), defaultValue: Priority.low.rawValue)
            t.column(itemURL, defaultValue: nil)
        })
        
        try db.run(notesTable.create(ifNotExists: true) { t in
            t.column(noteID, primaryKey: .autoincrement)
            t.column(noteContent, defaultValue: "")
        })
        
        try db.run(itemNotesTable.create(ifNotExists: true) { t in
            t.column(linkedItemID)
            t.column(linkedNoteID)
            t.primaryKey(linkedItemID, linkedNoteID)
        })
    }
    
    private func retrieveNotes() throws -> [Note] {
        var notes: [Note] = []
        
        for row in try db.prepare(notesTable) {
            notes.append(Note(id: row[noteID], content: row[noteContent]))
        }
        
        return notes
    }
    
    private func retrieveItemNoteLinks() throws -> [String: [Int]] {
        var relations: [String: [Int]] = [:]
        
        for row in try db.prepare(itemNotesTable) {
            let key = row[linkedItemID]
            let note_id = row[linkedNoteID]
            
            if var note_ids = relations[key] {
                note_ids.append(note_id)
            } else {
                relations[key] = [note_id]
            }
        }
        
        return relations
    }
    
    private func retrieveNotes(forItemWithID id: String) throws -> [String] {
        let notes = self.notes
        let relations = try retrieveItemNoteLinks()
        
        guard let noteIDs = relations[id] else { return [] }
        
        return notes.filter { note in
            noteIDs.contains(note.id)
        }.map { note in
            note.content
        }
    }
    
    private func retrieveItems() throws -> [Item] {
        var items: [Item] = []
        
        for row in try db.prepare(itemTable) {
            var item = Item(withID: row[itemID], name: row[itemName], quantity: row[itemQuantity], priority: Priority(rawValue: row[itemPriority]) ?? .low, url: .none ~= row[itemURL] ? nil : URL(string: row[itemURL]!))
            
            item.notes = try retrieveNotes(forItemWithID: item.id)
            
            items.append(item)
        }
        
        return items
    }
    
    func removeLink(betweenItemWithID itemID: String, andNoteWithID noteID: Int) throws {
        let relations = try retrieveItemNoteLinks()
        
        guard let noteIDs = relations[itemID], noteIDs.contains(noteID) else { return }
        
        let itemNoteLink = itemNotesTable.filter(linkedItemID == itemID && linkedNoteID == noteID)
        
        try db.run(itemNoteLink.delete())
    }
    
    func link(noteWithID noteID: Int, toItemWithID itemID: String) throws {
        let relations = try retrieveItemNoteLinks()
        
        guard .none ~= relations[itemID] || !relations[itemID]!.contains(noteID) else { return }
        
        try db.run(itemNotesTable.insert(linkedItemID <- itemID, linkedNoteID <- noteID))
    }
    
    func add(note: String) throws {
        guard !notes.contains(where: { storedNote in
            storedNote.content == note
        }) else { return }
        
        try db.run(notesTable.insert(noteContent <- note))
    }
    
    func update(noteWithID noteID: Int, andContent content: String) throws {
        guard notes.contains(where: { note in
            note.id == noteID
        }) else { return }
        
        let noteRecord = notesTable.filter(self.noteID == noteID)
        
        try db.run(noteRecord.update(noteContent <- content))
    }
    
    func delete(noteWithID noteID: Int) throws {
        guard notes.contains(where: { note in
            note.id == noteID
        }) else { return }
        
        let noteRecord = notesTable.filter(self.noteID == noteID)
        let relations = try retrieveItemNoteLinks()
        
        let itemIDs = relations.keys.filter { itemID in
            relations[itemID]!.contains(noteID)
        }
        
        for itemID in itemIDs {
            try removeLink(betweenItemWithID: itemID, andNoteWithID: noteID)
        }
        
        try db.run(noteRecord.delete())
    }
    
    private func add(notes: [String], toItemWithID itemID: String) throws {
        for note in notes {
            if let storedNote = self.notes.first(where: { housedNote in
                housedNote.content == note
            }) {
                try link(noteWithID: storedNote.id, toItemWithID: itemID)
            } else {
                try add(note: note)
                
                try link(noteWithID: self.notes.last!.id, toItemWithID: itemID)
            }
        }
    }
    
    func add(item: Item) throws {
        guard !items.contains(where: { storedItem in
            storedItem.id == item.id
        }) else { return }
        
        let insert = itemTable.insert(itemID <- item.id,
                                                          itemName <- item.name,
                                                          itemQuantity <- item.quantity,
                                                          itemPriority <- item.priority.rawValue,
                                      itemURL <- item.url?.absoluteString)
        
        try db.run(insert)
        
        guard !item.notes.isEmpty else { return }
        
        try add(notes: item.notes, toItemWithID: item.id)
    }
    
    func update(item: Item) throws {
        guard let storedItem = items.first(where: { housedItem in
            housedItem.id == item.id
        }) else { return }
        
        let itemRecord = itemTable.filter(itemID == item.id)
        
        try db.run(itemRecord.update(itemName <- item.name,
                                     itemQuantity <- item.quantity,
                                     itemPriority <- item.priority.rawValue,
                                     itemURL <- item.url?.absoluteString))
        
        let newNotes = item.notes.filter { note in
            !storedItem.notes.contains(note)
        }
        
        guard !newNotes.isEmpty else { return }
        
        try add(notes: newNotes, toItemWithID: item.id)
    }
    
    func delete(item: Item) throws {
        guard let _ = items.first(where: { housedItem in
            housedItem.id == item.id
        }) else { return }
        
        let itemRecord = itemTable.filter(itemID == item.id)
        
        try db.run(itemRecord.delete())
        
        let relations = try retrieveItemNoteLinks()
        
        guard let noteIDs = relations[item.id] else { return }
        
        for noteID in noteIDs {
            try removeLink(betweenItemWithID: item.id, andNoteWithID: noteID)
        }
    }
    
    func updateOrAdd(item: Item) throws {
        if let _ = items.first(where: { storedItem in
            storedItem.id.caseInsensitiveCompare(item.id) == .orderedSame
        }) {
            
            try update(item: item)
        } else {
            try add(item: item)
        }
    }
    
    func updateOrAdd(items: [Item]) throws {
        for item in items {
            try updateOrAdd(item: item)
        }
    }
}
