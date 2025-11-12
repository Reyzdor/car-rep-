import SwiftUI

struct SmallCardView: View {
    let iconName: String
    let title: String
    let description: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(red: 0.90, green: 0.30, blue: 1.0))
            .frame(width: 100, height: 205)
            .overlay(
                VStack {
                    Image(iconName)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .offset(y: -30)
                        .foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.0))
                        .padding(10)
                    
                    Text(title)
                        .font(.caption)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .offset(y: -20)
                    
                    Text(description)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            )
    }
}
