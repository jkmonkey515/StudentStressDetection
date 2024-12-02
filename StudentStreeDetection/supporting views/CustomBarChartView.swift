//
//  CustomBarChartView.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/1/24.
//

import SwiftUI

import SwiftUI
import Charts

struct CustomBarChartView: View {
    var stats: [StatsModel]
    
    let yAxisValues: [String] = [
        "Depressed", "Level2", "Level3", "Level4", "Happy"
    ]
    
    var body: some View {
        Chart {
            ForEach(stats, id: \.id) { stat in
                let averageLevel = calculateAverageLevel(for: stat.listData)
                BarMark(
                    x: .value("Start Date", stat.startDate, unit: .day),
                    y: .value("Average Level", averageLevel)
                )
                .foregroundStyle(Color.blue)
                .annotation(position: .top) {
                    Text("\(averageLevel, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .alignmentGuide(.leading) { _ in 0 } // Align the chart to the left
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear)) {
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                AxisTick()
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
        .chartYScale(domain: 0...5)
        .padding()
    }
    
    private func calculateAverageLevel(for data: [DailyFeelingModel]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.map { $0.level }.reduce(0, +)
        return Double(total) / Double(data.count)
    }
}

#Preview {
//    CustomBarChartView(stats: [])
    StatisticsView()
}
