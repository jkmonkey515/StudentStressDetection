//
//  CustomPicker.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/1/24.
//

import SwiftUI

struct CustomPicker: View {
    @Binding var currentTab:StatsDateType
    
    var body: some View {
        Picker("Options", selection: $currentTab) {
            ForEach(StatsDateType.allCases, id: \.self) { option in
                Text(option.title)
                    .tag(option.title)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(
            GeometryReader { geometry in
                ZStack {
                    ForEach(StatsDateType.allCases.indices, id: \.self) { idx in
                        if idx == currentTab.index {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.lightPurple, Color.lightOrange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width / CGFloat(StatsDateType.allCases.count) - 4, height: geometry.size.height - 4)
                                .offset(x: CGFloat(idx) * (geometry.size.width / CGFloat(StatsDateType.allCases.count)))
                                .animation(.easeInOut, value: currentTab)
                        }
                    }
                }
            }
        )
        .cornerRadius(8)
        .padding(4)
    }
}

#Preview {
    CustomPicker(currentTab: .constant(.weekly))
}
