//
//  DeviceListView.swift
//  DeviceManager
//
//  Created by 김미진 on 11/26/23.
//

import Foundation
import SwiftUI

struct DeviceListView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isShowingMenu = false
    @State private var selectedMenuItem: String = "Home"
    
    var body: some View {
        iPhoneView()
    }
    
    @ViewBuilder
    func iPhoneView() -> some View {
        // 아이폰용 UI
        
        NavigationView {
            ZStack {
                Color.DMColor.main.edgesIgnoringSafeArea(.all)
                ScrollView {
                    
                }
                
                if isShowingMenu {
                    SideMenu(isShowingMenu: $isShowingMenu, selectedItem: $selectedMenuItem)
                }
            }
            .navigationTitle(selectedMenuItem)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isShowingMenu.toggle() }) {
                        Image(systemName: "sidebar.left")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color.DMColor.white)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            isShowingMenu = true
                        }
                        if gesture.translation.width < -100 {
                            isShowingMenu = false
                        }
                    }
            )
        }
        .navigationViewStyle(.stack)
    }
}
struct SideMenu: View {
    @Binding var isShowingMenu: Bool
    @Binding var selectedItem: String
    
    var body: some View {
        List {
            ForEach(["First", "Second", "Third"], id: \.self) { item in
                Button(action: {
                    selectedItem = item
                    isShowingMenu = false
                }) {
                    Text(item)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
    }
}
struct Sidebar: View {
    var body: some View {
        List {
            NavigationLink(destination: Text("First")) {
                Label("First", systemImage: "1.circle")
            }
            
            NavigationLink(destination: Text("Second")) {
                Label("Second", systemImage: "2.circle")
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
    }
}
