//
//  DB.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/15/26.
//

import Foundation

class DB {
    var manager: DBManager?
    var url: URL {
        didSet {
            manager = try? DBManager(withDB: url)
        }
    }
    
    static let shared = DB()
    
    private init() {
        url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("gift_registry").appendingPathExtension("db")
        
        do {
            if !FileManager.default.fileExists(atPath: url.absoluteString) {
                manager = try DBManager(withDB: url)
                try manager!.initializeDatabase()
            } else {
                manager = try DBManager(withDB: url)
            }
        } catch {}
    }
}
