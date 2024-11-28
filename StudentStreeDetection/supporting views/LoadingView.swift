//
//  LoadingView.swift
//  StudentStreeDetection
//
//  Created by Developer on 11/28/24.
//

import SwiftUI

struct LoadingView: View {
    
    var color: Color = .gray
    
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(color)
            .controlSize(.regular)
    }
}
