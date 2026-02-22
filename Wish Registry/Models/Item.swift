import Foundation

struct Item: Identifiable {
	let id: String
    var name: String {
        didSet {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.update(item: self)
        }
    }
    var quantity: Int {
        didSet {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.update(item: self)
        }
    }
    var priority: Priority {
        didSet {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.update(item: self)
        }
    }
    var url: URL? {
        didSet {
            guard let manager = DB.shared.manager else { return }
            
            try? manager.update(item: self)
        }
    }
    var notes: [String] {
        didSet {
            guard let manager = DB.shared.manager else { return }
            
            for note in notes {
                if let storedNote = manager.notes.first(where: { n in
                    n.content == note
                }) {
                    try? manager.link(noteWithID: storedNote.id, toItemWithID: self.id)
                } else {
                    try? manager.add(note: note)
                    
                    guard let recentNote = manager.notes.last else { continue }
                    
                    try? manager.link(noteWithID: recentNote.id, toItemWithID: self.id)
                }
            }
        }
    }
	
	init(withID id: String = UUID().uuidString, name: String = "", quantity: Int = 1, priority: Priority = .low, url: URL? = nil, andNotes notes: [String] = []) {
		self.id = id
		self.name = name
		self.quantity = quantity
		self.priority = priority
		self.url = url
		self.notes = notes
	}
}

extension Item: Codable {
	private enum CodingKeys: String, CodingKey {
		case id, name, quantity, priority, url, notes
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(self.id, forKey: .id)
		try container.encode(self.name, forKey: .name)
		
		if self.quantity > 1 {
			try container.encode(self.quantity, forKey: .quantity)
		}
		
		if case Priority.low = self.priority {} else {
			try container.encode(self.priority, forKey: .priority)
		}
		
		if case .none = self.url {} else {
			try container.encode(self.url, forKey: .url)
		}
		
		if !self.notes.isEmpty {
			try container.encode(self.notes, forKey: .notes)
		}
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.id = container.contains(.id) ? try container.decode(String.self, forKey: .id) : UUID().uuidString
		self.name = try container.decode(String.self, forKey: .name)
		self.quantity = container.contains(.quantity) ? try container.decode(Int.self, forKey: .quantity) : 1
		self.priority = container.contains(.priority) ? try container.decode(Priority.self, forKey: .priority) : Priority.low
		self.url = container.contains(.url) ? try container.decode(URL.self, forKey: .url) : nil
		self.notes = container.contains(.notes) ? try container.decode([String].self, forKey: .notes) : []
	}
}

extension Item: CustomStringConvertible {
	var description: String {
		if let url = self.url {
			return "\t\(self.id)\t\(self.name)\t\(self.quantity)\t\(self.priority)\t\(url)"
		} else {
			return "\t\(self.id)\t\(self.name)\t\(self.quantity)\t\(self.priority)\t"
		}
	}
}

extension Item: LosslessStringConvertible {
	init?(_ description: String) {
		let fields = description.components(separatedBy: "\t")
		
		guard fields.count == 5 else { return nil } 
		
		self.id = !fields[0].isEmpty ? fields[0] : UUID().uuidString
		self.name = fields[1]
		self.quantity = !fields[2].isEmpty ? Int(fields[2]) ?? 1 : 1
		self.priority = !fields[3].isEmpty ? Priority(rawValue: fields[3]) ?? Priority.low : Priority.low
		self.url = !fields[4].isEmpty ? URL(string: fields[4]) : nil
		self.notes = []
	}
}

extension Item {
    static func load(from data: Data) throws -> [Item] {
        let jsonDecoder = JSONDecoder()
        
        return try jsonDecoder.decode([Item].self, from: data)
    }
    
    static func load(from file: URL) throws -> [Item] {
        let jsonData = try Data(contentsOf: file)
        
        return try load(from: jsonData)
    }
    
    static func load(fromTSV tsv: URL) throws -> [Item] {
        let content = try String(contentsOf: tsv, encoding: .utf8)
        
        return content.components(separatedBy: .newlines).compactMap { line in
            Item(line)
        }
    }
}

extension Item: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id.caseInsensitiveCompare(rhs.id) == .orderedSame &&
        lhs.name == rhs.name &&
        lhs.quantity == rhs.quantity &&
        lhs.priority == rhs.priority &&
        lhs.url == rhs.url
    }
}

extension Array where Element == Item {
    var data: Data? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        guard let encodedItems = try? jsonEncoder.encode(self) else { return nil }
        return encodedItems
    }
}
