import SwiftUI

struct SkipOnBoardingView: View {
    let text: String
    @Binding var hasCompetedBoarding: Bool
    
    var body: some View {
        Text(text)
            .offset(x: 120,y: -360)
            .font(.headline)
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .onTapGesture {
                hasCompetedBoarding = true
            }
    }
}
