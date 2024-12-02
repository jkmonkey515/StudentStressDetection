//
//  EmojiItemView.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/1/24.
//

import SwiftUI

struct EmojiItemView: View {
    
    let item: FeelingStatus
    let cornerRadius: CGFloat = 10
    
    var body: some View {
        VStack {
            Image(item.image)
                .resizable()
                .frame(maxWidth: .infinity)
                .aspectRatio(contentMode: .fit)
            
//            Text(item.title)
        }
//        .padding(.vertical)
//        .padding(.horizontal, 4)
//        .background(Color.red)
//        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//        .overlay(
//            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
//                .stroke(Color.gray.opacity(0.8), lineWidth: 1)
//        )
    }
}

#Preview {
    EmojiItemView(item: .grin)
}
