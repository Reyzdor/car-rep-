import SwiftUI

struct OnBoardingButton: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = .green
    var textColor: Color = .white
    var showArrow: Bool = true
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.callout)
                    .fontWeight(.regular)
                
                if showArrow {
                    
                    Image(systemName: "chevron.forward")
                        .font(.caption)
                        .fontWeight(.light)
                    
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(14)
        }
        .padding(.horizontal, 20)
    }
}
