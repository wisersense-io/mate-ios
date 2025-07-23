import SwiftUI

struct HealthScoreGaugeWidget: View {
    let score: Double // 0.0 to 10.0
    let title: String
    let onShareTapped: (() -> Void)?

    @EnvironmentObject var themeManager: ThemeManager
    @State private var animatedScore: Double = 0.0
    @State private var needleAnimated: Bool = false
    @State private var arcAnimationProgress: CGFloat = 0.0

    // Widget ölçüleri
    private let widgetWidth: CGFloat = 320
    private let gaugeSize: CGFloat = 120

    init(score: Double, title: String = "Sağlık Skoru", onShareTapped: (() -> Void)? = nil) {
        self.score = min(max(score, 0.0), 10.0)
        self.title = title
        self.onShareTapped = onShareTapped
    }

    var body: some View {
        VStack(spacing: 0) {
            // Başlık
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.bottom, 20)

            // Göstergenin kendisi
            ZStack {
                GaugeBackground(size: gaugeSize * 1.25, animationProgress: arcAnimationProgress)
                ScoreLabel(size: gaugeSize, score: animatedScore)
            }
            .frame(width: gaugeSize * 1.25, height: 100)
            .padding(.top, 36)
    
            // Paylaş Butonu
            HStack {
                Button(action: {
                    onShareTapped?()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Paylaş")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.currentColors.mainAccentColor)
                    )
                }
                .scaleEffect(needleAnimated ? 1.0 : 0.9)
                .opacity(needleAnimated ? 1.0 : 0.7)
                
                Spacer()
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(themeManager.currentColors.mainBgColor)
                .shadow(color: themeManager.currentColors.mainBorderColor.opacity(0.2),
                        radius: 8, x: 0, y: 4)
        )
        .onAppear {
            startAnimation()
        }
        .onChange(of: score) {
            resetAndStartAnimation()
        }
    }
    
    // MARK: - Animation Methods
    
    private func startAnimation() {
        // Arc animasyonu
        withAnimation(.easeInOut(duration: 1.2)) {
            arcAnimationProgress = 1.0
        }
        
        // Score animasyonu
        withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
            animatedScore = score
        }
        
        // Needle animasyonu
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.8)) {
            needleAnimated = true
        }
    }
    
    private func resetAndStartAnimation() {
        arcAnimationProgress = 0.0
        animatedScore = 0.0
        needleAnimated = false
        startAnimation()
    }
}

struct GaugeBackground: View {
    let size: CGFloat
    let animationProgress: CGFloat
    
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Background circle (inactive state)
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(themeManager.currentColors.mainBorderColor.opacity(0.2), lineWidth: 12)
                .rotationEffect(.degrees(180))
                .frame(width: size, height: size)
            
            // Renkli yarım daire segmentleri
            ForEach(0..<10) { i in
                let start = Double(i) / 10
                let end = Double(i + 1) / 10
                let segmentProgress = min(max((animationProgress - start) / 0.1, 0), 1)
                
                Arc(startAngle: .degrees(180 + 180 * start),
                    endAngle: .degrees(180 + 180 * end))
                    .trim(from: 0, to: segmentProgress)
                    .stroke(colorForIndex(i), lineWidth: 12)
                    .opacity(segmentProgress)
            }

            // Sayılar
            ForEach(0...10, id: \.self) { i in
                let angle = Double(i) * 18
                let radius = size / 2 + 20
                let numberProgress = min(max(animationProgress - 0.5, 0), 1)
                
                Text("\(i)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .scaleEffect(numberProgress)
                    .opacity(numberProgress)
                    .position(
                        x: size / 2 + CGFloat(cos((180 + angle) * .pi / 180) * radius),
                        y: size / 2 + CGFloat(sin((180 + angle) * .pi / 180) * radius)
                    )
            }
            
            // Center dot
            /*Circle()
                .fill(themeManager.currentColors.mainA.opacity(0.8))
                .frame(width: 8, height: 8)
                .position(x: size / 2, y: size / 2)
                .scaleEffect(animationProgress)
             */
        }
        .frame(width: size, height: size)
    }

    private func colorForIndex(_ i: Int) -> Color {
        switch i {
        case 0...1: return Color(red: 0.82, green: 0.04, blue: 0.04) // Kırmızı
        case 2...4: return Color(red: 1.0, green: 0.34, blue: 0.13)  // Turuncu
        case 5...7: return Color(red: 1.0, green: 0.61, blue: 0.13)  // Sarı
        default: return Color(red: 0.13, green: 0.76, blue: 1.0)     // Mavi
        }
    }
}

struct NeedleView: View {
    let size: CGFloat
    let score: Double
    let isAnimated: Bool

    var body: some View {
        let angle = Angle.degrees(180 - (score / 10) * 180)

        ZStack {
            // Needle shadow
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.3))
                .frame(width: 4, height: size / 2 - 15)
                .offset(x: 1, y: -(size / 4) + 7.5)
                .rotationEffect(angle)
                .blur(radius: 2)
            
            // Main needle
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color(for: score), color(for: score).opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: size / 2 - 15)
                .offset(y: -(size / 4) + 7.5)
                .rotationEffect(angle)
                .shadow(color: color(for: score).opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Needle tip
            Circle()
                .fill(color(for: score))
                .frame(width: 6, height: 6)
                .offset(y: -(size / 2) + 10)
                .rotationEffect(angle)
                .shadow(color: color(for: score).opacity(0.5), radius: 1, x: 0, y: 1)
            
            // Center hub
            
        }
        .scaleEffect(isAnimated ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimated)
    }
    
    private func color(for score: Double) -> Color {
        switch score {
        case 0...2: return Color(red: 0.82, green: 0.04, blue: 0.04)
        case 2...5: return Color(red: 1.0, green: 0.34, blue: 0.13)
        case 5...8: return Color(red: 1.0, green: 0.61, blue: 0.13)
        default: return Color(red: 0.13, green: 0.76, blue: 1.0)
        }
    }
}

struct ScoreLabel: View {
    let size: CGFloat
    let score: Double
    
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", score))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color(for: score))
                .shadow(color: color(for: score).opacity(0.3), radius: 2, x: 0, y: 1)
            
        }
        .offset(y: size * -0.05)
        .scaleEffect(score > 0 ? 1.0 : 0.8)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: score)
    }

    private func color(for score: Double) -> Color {
        switch score {
        case 0..<2: return Color(red: 0.82, green: 0.04, blue: 0.04)
        case 2..<5: return Color(red: 1.0, green: 0.34, blue: 0.13)
        case 5..<8: return Color(red: 1.0, green: 0.61, blue: 0.13)
        default: return Color(red: 0.13, green: 0.76, blue: 1.0)
        }
    }
}

struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

#Preview {
    VStack {
        HealthScoreGaugeWidget(score: 9.8)
    }
    .environmentObject(ThemeManager.shared)
}
