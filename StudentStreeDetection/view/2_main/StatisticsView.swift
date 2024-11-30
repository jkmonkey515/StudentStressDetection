//
//  StatisticsView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    var body: some View {
        NavigationStack {
            VStack {
                Text("Statistics")
            }
            .navigationTitle("Statistics")
            
        }
    }
}

#Preview {
    StatisticsView()
}
