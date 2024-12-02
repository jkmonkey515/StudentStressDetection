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
                    
                    CustomBarChartView(stats: statsData)
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
                    
                    pageData = loadMockData()
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
        let list = loadMockData()
        return Utils.shared.groupDataByInterval(data: list, type: currentTab)
    }
    
    func loadMockData() -> [DailyFeelingModel] {
        // Mock daily feelings for two weeks
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return [
            DailyFeelingModel(docId: "1", uid: "user1", level: 3, note: "Feeling okay", createdAt: formatter.date(from: "2024-1-17")!),
            DailyFeelingModel(docId: "2", uid: "user1", level: 4, note: "Good day!", createdAt: formatter.date(from: "2024-2-18")!),
            DailyFeelingModel(docId: "3", uid: "user1", level: 2, note: "Feeling tired", createdAt: formatter.date(from: "2024-3-19")!),
            DailyFeelingModel(docId: "4", uid: "user1", level: 5, note: "Excellent mood!", createdAt: formatter.date(from: "2024-4-20")!),
            DailyFeelingModel(docId: "5", uid: "user1", level: 1, note: "Rough day", createdAt: formatter.date(from: "2024-5-21")!),
            DailyFeelingModel(docId: "6", uid: "user1", level: 3, note: "Feeling neutral", createdAt: formatter.date(from: "2024-6-22")!),
            DailyFeelingModel(docId: "7", uid: "user1", level: 4, note: "Pretty good", createdAt: formatter.date(from: "2024-7-23")!),
            DailyFeelingModel(docId: "8", uid: "user1", level: 2, note: "A bit stressed", createdAt: formatter.date(from: "2024-8-24")!),
            DailyFeelingModel(docId: "9", uid: "user1", level: 5, note: "Feeling awesome!", createdAt: formatter.date(from: "2024-9-25")!),
            DailyFeelingModel(docId: "10", uid: "user1", level: 3, note: "A calm day", createdAt: formatter.date(from: "2024-7-26")!),
            DailyFeelingModel(docId: "11", uid: "user1", level: 1, note: "Overwhelmed", createdAt: formatter.date(from: "2024-10-27")!),
            DailyFeelingModel(docId: "12", uid: "user1", level: 4, note: "Doing well", createdAt: formatter.date(from: "2024-11-28")!),
            DailyFeelingModel(docId: "13", uid: "user1", level: 3, note: "A decent day", createdAt: formatter.date(from: "2024-11-29")!),
            DailyFeelingModel(docId: "14", uid: "user1", level: 2, note: "Low energy", createdAt: formatter.date(from: "2024-11-30")!)
        ]
         
    }
    
}

#Preview {
    StatisticsView()
}
