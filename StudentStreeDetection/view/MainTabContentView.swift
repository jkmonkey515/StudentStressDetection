//
//  MainTabContentView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import SwiftUI

struct MainTabContentView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tag(0)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .environmentObject(globalData)
            
            StatisticsView()
                .tag(1)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Statistics")
                }
                .environmentObject(globalData)
            
            SettingsView()
                .tag(2)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Setting")
                }
                .environmentObject(globalData)
        }
    }
}

#Preview {
    MainTabContentView().environmentObject(AppGlobalData())
}
