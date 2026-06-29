//
//  ItemEditRow.swift
//  ASSIGNMENT7ODML
//
//  Created by Levi Daniel on 6/28/26.
//

import SwiftUI

struct ItemEditRow: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: PantryStore
    
    var itemToEdit: PantryItem?
    var initialBarcode: String?
    
    @State private var name: String = ""
    @State private var barcode: String = ""
    @State private var quantity: Int = 1
    @State private var category: FoodCategory = .pantry
    @State private var expiryDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Metadata")) {
                    TextField("Product Name (e.g., Almond Milk)", text: $name)
                    Text("Barcode: \(barcode)").foregroundColor(.gray)
                }
                
                Section(header: Text("Inventory Details")) {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                    Picker("Storage Location", selection: $category) {
                        ForEach(FoodCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    DatePicker("Expiration Date", selection: $expiryDate, displayedComponents: .date)
                }
            }
            .navigationTitle(itemToEdit == nil ? "Add Scanned Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let item = itemToEdit {
                    name = item.name
                    barcode = item.barcode
                    quantity = item.quantity
                    category = item.category
                    expiryDate = item.expiryDate
                } else if let scanned = initialBarcode {
                    barcode = scanned
                    if scanned == "01234567" {
                        name = "Organic Tomato Soup"
                    } else if scanned == "98765432" {
                        name = "Whole Wheat Bread"
                    }
                }
            }
        }
    }
    
    private func saveItem() {
        if let item = itemToEdit, let index = store.items.firstIndex(where: { $0.id == item.id }) {
            store.items[index] = PantryItem(id: item.id, name: name, barcode: barcode, quantity: quantity, category: category, expiryDate: expiryDate)
        } else {
            let newItem = PantryItem(name: name, barcode: barcode, quantity: quantity, category: category, expiryDate: expiryDate)
            store.items.append(newItem)
        }
        dismiss()
    }
}
