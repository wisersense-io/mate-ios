import SwiftUI

struct CircularCountdownView: View {
    var totalTime: Double = 300
    var currentTime: Double
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 10)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(currentTime / totalTime))
                .stroke(
                    themeManager.currentColors.mainAccentColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.25), value: currentTime)
            
            Text(formatTime(Int(currentTime)))
                .font(.title2)
                .bold()
                .foregroundColor(themeManager.currentColors.mainTextColor)
        }
        .frame(width: 130, height: 130)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
