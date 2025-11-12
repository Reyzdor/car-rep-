import SwiftUI

struct LargeCardView: View {
    let iconName: String
    let title: String
    let description: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(red: 0.90, green: 0.30, blue: 1.0))
            .frame(width: 350, height: 280)
            .offset(y: -20)
            .overlay(
                VStack(spacing: 10) {
                    Circle()
                        .fill(Color(red: 0.0, green: 1.0, blue: 0.0))
                        .frame(width: 100, height: 90)
                        .overlay(
                            Image(iconName)
                                .resizable()
                                .offset(y: 0)
                                .frame(width: 50, height: 50)
                        )
                        .padding(10)
                    
                    Text(title)
                        .font(.headline)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(10)
                    
                    Text(description)
                        .font(.caption)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                }
                .offset(y: -50)
            )
    }
}
