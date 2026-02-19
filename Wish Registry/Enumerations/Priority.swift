//
//  Priority.swift
//  Wish Registry
//
//  Created by Bryce Campbell on 2/14/26.
//


enum Priority: String, CaseIterable {
	case low, medium, high, highest
}

extension Priority {
	var sortOrder: Int {
		return Priority.allCases.firstIndex(of: self)!
	}
}

extension Priority: Codable {}

extension Priority: Comparable {
	static func < (rhs: Self, lhs: Self) -> Bool {
		rhs.sortOrder < lhs.sortOrder
	}
}

extension Priority: Identifiable {
    var id: String {
        return self.rawValue
    }
}
