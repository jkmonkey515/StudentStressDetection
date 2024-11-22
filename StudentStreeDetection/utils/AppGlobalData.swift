//
//  AppGlobalData.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import SwiftUI

@MainActor
final class AppGlobalData: ObservableObject {
    @AppStorage("authCompleted") var isAuthCompleted: Bool = false
}
