import SwiftUI

struct StripesOnBoardingView: View {
    let iconName: String
    let title: String
    let description: String
    let approved: String
    let circleColor: Color
    let iconColor: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(red: 0.90, green: 0.30, blue: 1.0))
            .frame(width: 350, height: 63)
            .overlay(
                HStack(spacing: 15) {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(iconName)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(iconColor)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(description)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: approved)
                        .font(.system(size: 21, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
            )
    }
}
