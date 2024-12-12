//
//  StatisticsView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    @State private var isLoading = false
    @State private var pageData: [DailyFeelingModel] = []
//    @State private var statsData: [StatsModel] = []
    @State private var currentTab: StatsDateType = .weekly
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    pickerView
                    
                    CustomBarChartView(data: statsData)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 300)
                    
                    Text("Analytics by AI")
                    
                    CustomBarChartView(data: statsData, chartMode: .ai, barColor: .lightOrange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 300)
                }
                .padding()
                .navigationTitle("Statistics")
                .task {
                    isLoading = true
                    FirestoreManager.shared.addListenerOnDailyFeelings { data in
                        self.isLoading = false
                        self.pageData = data
                    }
                }
            }
        }
    }
    
    var pickerView: some View {
        Picker("Options", selection: $currentTab) {
            ForEach(StatsDateType.allCases, id: \.self) { option in
                Text(option.title)
                    .tag(option.title)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    var statsData: [StatsModel] {
        let data = pageData
        let result = Utils.shared.groupDataByInterval(data: data, type: currentTab)
        return result
    }
    
}

#Preview {
    StatisticsView()
}
