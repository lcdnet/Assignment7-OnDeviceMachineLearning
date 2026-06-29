//
//  PantryItem.swift
//  ASSIGNMENT7ODML
//
//  Created by Levi Daniel on 6/28/26.
//

import Foundation
import Combine

enum FoodCategory: String, CaseIterable, Identifiable, Codable {
    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"
    
    var id: String { self.rawValue }
}

struct PantryItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var barcode: String
    var quantity: Int
    var category: FoodCategory
    var expiryDate: Date
    
    var isExpired: Bool {
        Date() > expiryDate
    }
    
    var daysToExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
    }
    
}


class PantryStore : ObservableObject {
    @Published var items: [PantryItem] = [] {
        didSet { save() }
    }
    
    private let saveKey = "PantronItems"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([PantryItem].self, from: data) {
            self.items = decoded
        } else {
            self.items = []
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
