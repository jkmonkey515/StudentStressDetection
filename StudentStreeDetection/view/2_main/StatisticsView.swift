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
    @State private var countYES = 0
    @State private var countNO = 0
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    pickerView
                    
                    CustomBarChartView(data: statsData, tabMode: currentTab)
                    
                    Text("Very sad, sad, neutral, happy, very happy")
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Feeling entered by you")
                    
                    Divider()
                    
                    CustomBarChartView(data: statsData, chartMode: .ai, tabMode: currentTab, barColor: .lightOrange)
                    
                    Text("Feeling determined by AI")
                    
                    HStack {
                        Text("You agreed with us ")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.black)
                        + Text("\(countYES)/\(countYES + countNO)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.blue)
                        + Text(" times")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.black)
                        
                        Spacer()
                    }
                }
                .padding()
                .navigationTitle("Statistics")
                .task {
                    isLoading = true
                    FirestoreManager.shared.addListenerOnDailyFeelings { data in
                        self.isLoading = false
                        self.pageData = data
                    }
                    
                    let uid = UserData.shared.getUser().uid
                    if let user = await FirestoreManager.shared.fetchUser(uid: uid) {
                        countYES = user.countOfAgreeWithAI ?? 0
                        countNO = user.countOfDisagreeWithAI ?? 0
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
