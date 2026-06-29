//
//  ContentView.swift
//  ASSIGNMENT7ODML
//
//  Created by Levi Daniel on 6/28/26.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject var store = PantryStore()
    @State private var selectedFilter: FoodCategory? = nil
    @State private var activeScanBarcode: String? = nil
    @State private var isShowingScanner = false
    @State private var isShowingError = false
    @State private var editingItem: PantryItem? = nil
    
    // Summary Calculations
    var expiredCount: Int { store.items.filter { $0.isExpired }.count }
    var runningLowCount: Int { store.items.filter { !$0.isExpired && $0.daysToExpiry <= 3 }.count }
    
    var filteredItems: [PantryItem] {
        if let filter = selectedFilter {
            return store.items.filter { $0.category == filter }
        }
        return store.items
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Summary KPI Cards Banner
                HStack(spacing: 12) {
                    DashboardCard(title: "Expired", count: expiredCount, color: .red)
                    DashboardCard(title: "Expiring Soon", count: runningLowCount, color: .orange)
                    DashboardCard(title: "Total Goods", count: store.items.count, color: .green)
                }
                .padding()
                
                // Segmented Filter Tabs
                Picker("Filter Location", selection: $selectedFilter) {
                    Text("All Locations").tag(FoodCategory?.none)
                    ForEach(FoodCategory.allCases) { cat in
                        Text(cat.rawValue).tag(FoodCategory?.some(cat))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // List Layout & Empty State Logic
                if store.items.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "basket.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("Your Pantry is Empty")
                            .font(.headline)
                        Text("Tap the camera icon below to run on-device machine learning and log your barcode essentials.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.headline)
                                    Text("Qty: \(item.quantity) | \(item.category.rawValue)")
                                        .font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.isExpired ? "Expired" : "\(item.daysToExpiry)d left")
                                    .font(.caption).bold()
                                    .padding(.all, 6)
                                    .background(item.isExpired ? Color.red.opacity(0.2) : (item.daysToExpiry <= 3 ? Color.orange.opacity(0.2) : Color.green.opacity(0.2)))
                                    .foregroundColor(item.isExpired ? .red : (item.daysToExpiry <= 3 ? .orange : .green))
                                    .cornerRadius(6)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingItem = item }
                        }
                        .onDelete { indexSet in
                            store.items.remove(atOffsets: indexSet)
                        }
                    }
                }
                
                // Trigger Button
                Button(action: { isShowingScanner = true }) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scan Product Barcode")
                    }
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(Color.blue).cornerRadius(12)
                    .padding()
                }
            }
            .navigationTitle("Pantron - Shelf-life tracker")
            .sheet(isPresented: $isShowingScanner) {
                ZStack {
                    BarcodeScanView(scannedBarcode: $activeScanBarcode, isShowingError: $isShowingError)
                    VStack {
                        Text("Align barcode inside camera view").foregroundColor(.white)
                            .padding().background(Color.black.opacity(0.6)).cornerRadius(8).padding(.top, 30)
                        Spacer()
                    }
                }
                .onChange(of: activeScanBarcode) { newValue in
                    if newValue != nil { isShowingScanner = false }
                }
            }
            // Displays input modifier sheet dynamically after scanning context returns or explicit taps occur
            .sheet(isPresented: Binding(
                get: { activeScanBarcode != nil || editingItem != nil },
                set: { if !$0 { activeScanBarcode = nil; editingItem = nil } }
            )) {
                ItemEditRow(store: store, itemToEdit: editingItem, initialBarcode: activeScanBarcode)
            }
        }
    }
}

// Reusable Summary Widget
struct DashboardCard: View {
    var title: String
    var count: Int
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text("\(count)").font(.title).bold().foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
