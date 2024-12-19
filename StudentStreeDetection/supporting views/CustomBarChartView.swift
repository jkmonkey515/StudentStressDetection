//
//  CustomBarChartView.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/1/24.
//

import SwiftUI
import Charts

struct CustomBarChartView: View {
    let data: [StatsModel]
    var chartMode: BarChartMode = .user
    
    // for weekly and monthly, need to show all dates for this week/month
    var tabMode: StatsDateType = .weekly
    var barColor: Color = Color.lightPurple
    
    private let barTextHeight: CGFloat = 25
    private var barMaxHeight: CGFloat {
        ChartViewHeight - barTextHeight * 2
    }
    
    
    var body: some View {
        HStack {
            yAxisView
                .padding(.vertical, barTextHeight)
            
            if tabMode != .yearly {
                // for weekly and monthly
                ScrollView(.horizontal) {
                    HStack(alignment: .bottom, spacing: 5) {
                        ForEach(filteredData) { itemData in
                            barItemView(value: Double(chartMode == .user ? itemData.level : itemData.levelByAI), date: itemData.createdAt)
                        }
                    }
                }
            } else {
                // for yearly
                ScrollView(.horizontal) {
                    HStack(alignment: .bottom, spacing: 5) {
                        ForEach(data) { oneStatData in
                            let averageLevel = chartMode == .user ? calculateAverageLevel(for: oneStatData.listData) : calculateAverageLevelByAI(for: oneStatData.listData)
                            barItemView(value: averageLevel, date: oneStatData.startDate)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: ChartViewHeight)
    }
    
    // MARK: Bar Item View
    func barItemView(value: Double, date: Date) -> some View {
        VStack(spacing: 0) {
            if value < Double(FeelingStatus.allCases.count) {
                Spacer()
            }
            
            statusText(by: value)
                .multilineTextAlignment(.center)
//                .rotationEffect(.degrees(-20))
            
            
            RoundedRectangle(cornerRadius: 5)
                .fill(barColor)
                .frame(
                    width: tabMode == .weekly ? ((SCREEN_WIDTH - 100) / 7) : 25,
                    height: CGFloat((value == -1 ? 0 : value) / Double(FeelingStatus.allCases.count)) * barMaxHeight
                )
            
            Text(date.toString(format: "MM/dd"))
                .lineLimit(1)
                .font(.system(size: 10))
                .frame(height: 25)
        }
    }
    
    private var filteredData:[DailyFeelingModel] {
        if let last = data.last {
            return processData(statsModel: last)
        }
        else {
            return []
        }
    }
    
    func processData(statsModel: StatsModel) -> [DailyFeelingModel] {
        let calendar = Calendar.current
        var dailyData: [DailyFeelingModel] = []
        let startDate = statsModel.startDate
        let endDate = statsModel.endDate

        // Generate the range of dates for the week
        var currentDate = startDate
        while currentDate <= endDate {
            let sameDayData = statsModel.listData.filter {
                calendar.isDate($0.createdAt, inSameDayAs: currentDate)
            }

            if sameDayData.isEmpty {
                // Add default data for missing days
                dailyData.append(
                    DailyFeelingModel(
                        docId: UUID().uuidString,
                        uid: "default",
                        level: -1,
                        note: "No data",
                        levelByAI: -1,
                        createdAt: currentDate
                    )
                )
            } else {
                // Calculate the average level for the day
                let totalLevel = sameDayData.reduce(0) { $0 + $1.level }
                let totalLevelByAI = sameDayData.reduce(0) { $0 + $1.levelByAI }
                let count = sameDayData.count
                let averageLevel = totalLevel / count
                let averageLevelByAI = 5 - totalLevelByAI / count

                dailyData.append(
                    DailyFeelingModel(
                        docId: UUID().uuidString,
                        uid: "aggregated",
                        level: averageLevel,
                        note: "Aggregated data",
                        levelByAI: averageLevelByAI,
                        createdAt: currentDate
                    )
                )
            }

            // Move to the next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return dailyData
    }

    // MARK: Y Axis
    private var yAxisView: some View {
        HStack(spacing: 4) {
            VStack {
                if chartMode == .user {
                    ForEach(FeelingStatus.allCases.reversed(), id: \.self) { item in
                        Text(item.title)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.trailing)
                        Spacer()
                    }
                } else {
                    ForEach(FeelingStatus.allCases.reversed(), id: \.self) { item in
                        Image(item.image)
                            .resizable()
                            .frame(width: 24, height: 24)
                        Spacer()
                    }
                }
            }
            
            Rectangle()
                .frame(width: 1)
                .frame(maxHeight: .infinity)
                .foregroundColor(.gray)
        }
        .frame(height: ChartViewHeight - barTextHeight * 2)
    }
    
    private func calculateAverageLevel(for data: [DailyFeelingModel]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.map { $0.level }.reduce(0, +)
        return Double(total) / Double(data.count)
    }
    private func calculateAverageLevelByAI(for data: [DailyFeelingModel]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.map { $0.levelByAI }.reduce(0, +)
        return 5 - Double(total) / Double(data.count)
    }
    
    func statusText(by value: Double) -> some View {
        Text(Utils.shared.getStressLevelText(from: value))
            .font(.system(size: 8))
            .foregroundColor(.blue)
    }
}

#Preview {
//    let mockData = [DailyFeelingModel.default]
//    let sampleData = Utils.shared.groupDataByInterval(data: mockData, type: .weekly)
//    VStack {
//        CustomBarChartView(data: sampleData)
//    }
//    .padding()
    
    StatisticsView()
}

