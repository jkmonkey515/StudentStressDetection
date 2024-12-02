//
//  CustomBarChartView.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/1/24.
//

import SwiftUI
import Charts

struct BarData: Identifiable {
    let id = UUID()
    let value: Double
    let label: String
    let color: Color
}

struct CustomBarChartView: View {
    let data: [StatsModel]
    let maxValue: Double = 5

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(data) { oneStatData in
                    let averageLevel = calculateAverageLevel(for: oneStatData.listData)
                    VStack {
                        Text("\(averageLevel, specifier: "%.1f")")
                            .font(.system(size: 6))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(-30))
                            .padding(.bottom, 4)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.lightPurple)
                            .frame(
                                width: 25,
                                height: CGFloat(averageLevel / maxValue) * 200
                            )
                        
                        Text(oneStatData.startDate.toString(format: "MM/dd"))
                            .lineLimit(1)
                            .font(.system(size: 6))
                            .padding(.top, 4)
                    }
                }
            }
            .padding()
        }
    }
    
    private func calculateAverageLevel(for data: [DailyFeelingModel]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.map { $0.level }.reduce(0, +)
        return Double(total) / Double(data.count)
    }
}

#Preview {
    let mockData = Utils.shared.loadMockData()
    let sampleData = Utils.shared.groupDataByInterval(data: mockData, type: .weekly)
    CustomBarChartView(data: sampleData)
}

