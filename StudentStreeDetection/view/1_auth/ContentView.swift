//
//  ContentView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/20/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    
    @State private var isAppActive = false
    @State private var size = 0.75
    @State private var opacity = 0.5
    private let animationDuration = 0.8
    
    var body: some View {
        Group {
            ZStack {
                if isAppActive {
                    if globalData.isAuthCompleted {
                        HomeView()
                            .environmentObject(globalData)
                    } else {
                        RegisterView()
                            .environmentObject(globalData)
                    }
                } else {
                    splashView
                }
            }
        }
    }
    
    private var splashView: some View {
        ZStack {
            Color.cyan.edgesIgnoringSafeArea(.all)
            
//            LinearGradient(
//                gradient: Gradient(colors: [Color(hex: "8c52fe"), Color(hex: "fe914e")]),
//                startPoint: .leading,
//                endPoint: .trailing
//            )
//            .ignoresSafeArea()
            
            VStack {
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                .padding()
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear(perform: animateLogo)
            }
            .onAppear(perform: activateSplashScreen)
        }
    }
    
    private func animateLogo() {
        withAnimation(.easeIn(duration: animationDuration)) {
            self.size = 1.2
            self.opacity = 1.0
        }
    }
    
    private func activateSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.isAppActive = true
        }
    }
}

#Preview {
    ContentView().environmentObject(AppGlobalData())
}
