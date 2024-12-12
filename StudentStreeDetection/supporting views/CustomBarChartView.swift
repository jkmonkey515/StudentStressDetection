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
    var barColor: Color = Color.lightPurple
    let maxValue: Double = 5

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(data) { oneStatData in
                    let averageLevel = chartMode == .user ? calculateAverageLevel(for: oneStatData.listData) : calculateAverageLevelByAI(for: oneStatData.listData)
                    VStack {
                        Text("\(averageLevel, specifier: "%.1f")")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(-30))
                            .padding(.bottom, 4)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(barColor)
                            .frame(
                                width: 25,
                                height: CGFloat(averageLevel / maxValue) * 200
                            )
                        
                        Text(oneStatData.startDate.toString(format: "MM/dd"))
                            .lineLimit(1)
                            .font(.system(size: 10))
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private func calculateAverageLevel(for data: [DailyFeelingModel]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.map { $0.level }.reduce(0, +)
        return Double(total) / Double(data.count)
    }
    private func calculateAverageLevelByAI(for data: [DailyFeelingModel]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.map { $0.levelByAI }.reduce(0, +)
        return Double(total) / Double(data.count)
    }
}

#Preview {
    let mockData = [DailyFeelingModel.default]
    let sampleData = Utils.shared.groupDataByInterval(data: mockData, type: .weekly)
    CustomBarChartView(data: sampleData)
}

