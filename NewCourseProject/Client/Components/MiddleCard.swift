import SwiftUI

struct MiddleCardView: View {
    let titleTarif: String
    let types: [String]
    let prices: [String]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(red: 0.90, green: 0.30, blue: 1.0))
            .frame(width: 350, height: 205)
            .overlay(
                VStack(spacing: 4) {
                    Text(titleTarif)
                        .offset(y: -10)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)

                    
                    ForEach(Array(zip(types, prices)), id: \.0) { type, price in
                        HStack {
                            Text(type)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .offset(x: -5, y: 10)
                                .padding(10)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(price)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            )
    }
}
