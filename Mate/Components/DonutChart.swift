import SwiftUI

// MARK: - Data Models

public struct DonutChartData: Identifiable {
    public let id: String
    public let title: String
    public let centerValue: Int
    public let segments: [DonutChartSegment]
    
    public init(id: String, title: String, centerValue: Int, segments: [DonutChartSegment]) {
        self.id = id
        self.title = title
        self.centerValue = centerValue
        self.segments = segments
    }
}

public struct DonutChartSegment: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double // Percentage
    public let color: Color
    public let count: Int
    
    public init(label: String, value: Double, color: Color, count: Int) {
        self.label = label
        self.value = value
        self.color = color
        self.count = count
    }
}

// MARK: - Donut Chart Component

public struct DonutChart: View {
    let data: DonutChartData
    let chartSize: CGFloat
    let strokeWidth: CGFloat
    let isExpandable: Bool
    
    @State private var isExpanded = false
    @State private var animationProgress: CGFloat = 0
    @State private var segmentAnimationProgress: [CGFloat] = []
    @State private var selectedSegmentIndex: Int? = nil
    
    @EnvironmentObject var themeManager: ThemeManager
    
    public init(
        data: DonutChartData,
        chartSize: CGFloat = 200,
        strokeWidth: CGFloat = 30,
        isExpandable: Bool = true
    ) {
        self.data = data
        self.chartSize = chartSize
        self.strokeWidth = strokeWidth
        self.isExpandable = isExpandable
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Main content area with fixed height
            ZStack {
                // Chart or Legend content
                if !isExpanded {
                    // Donut Chart (default state)
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(themeManager.currentColors.mainBorderColor.opacity(0.1), lineWidth: strokeWidth)
                            .frame(width: chartSize, height: chartSize)
                        
                        // Animated segments
                        ForEach(Array(data.segments.enumerated()), id: \.offset) { index, segment in
                            DonutSegmentView(
                                segment: segment,
                                startFraction: startFractionForSegment(at: index),
                                endFraction: endFractionForSegment(at: index),
                                animationProgress: index < segmentAnimationProgress.count ? segmentAnimationProgress[index] : 0,
                                strokeWidth: strokeWidth,
                                isSelected: selectedSegmentIndex == index
                            )
                            .frame(width: chartSize, height: chartSize)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedSegmentIndex = selectedSegmentIndex == index ? nil : index
                                }
                            }
                        }
                        
                        // Center content
                        VStack(spacing: 2) {
                            Text("\(currentCenterValue)")
                                .font(.system(size: chartSize/6, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                                .animation(.easeInOut(duration: 0.3), value: currentCenterValue)
                            
                            Text(currentCenterLabel)
                                .font(.caption)
                                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                                .animation(.easeInOut(duration: 0.3), value: currentCenterLabel)
                                .multilineTextAlignment(.center)
                        }
                        .scaleEffect(animationProgress)
                        .opacity(animationProgress)
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                } else {
                    // Legend view (expanded state) - More responsive design
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(data.segments.enumerated()), id: \.offset) { index, segment in
                                    HStack(spacing: 10) {
                                        // Color indicator
                                        Circle()
                                            .fill(segment.color)
                                            .frame(width: 12, height: 12)
                                        
                                        // Label
                                        Text(segment.label)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(themeManager.currentColors.mainTextColor)
                                            .lineLimit(2)
                                        
                                        Spacer()
                                        
                                        // Count and percentage
                                        VStack(alignment: .trailing, spacing: 1) {
                                            Text("\(segment.count)")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(themeManager.currentColors.mainTextColor)
                                            
                                            Text(String(format: "%.1f%%", segment.value))
                                                .font(.system(size: 11))
                                                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(themeManager.currentColors.primaryWorkspaceColor)
                                            .shadow(color: themeManager.currentColors.mainBorderColor.opacity(0.1), radius: 1, x: 0, y: 1)
                                    )
                                    .scaleEffect(isExpanded ? 1.0 : 0.8, anchor: .center)
                                    .opacity(isExpanded ? 1.0 : 0.0)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: isExpanded)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedSegmentIndex = selectedSegmentIndex == index ? nil : index
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 8)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                // Toggle button in top-right corner
                if isExpandable {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isExpanded.toggle()
                                }
                            }) {
                                Image(systemName: isExpanded ? "chart.pie.fill" : "list.bullet")
                                    .font(.title3)
                                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(themeManager.currentColors.mainBgColor)
                                            .shadow(color: themeManager.currentColors.mainBorderColor.opacity(0.2), radius: 4, x: 0, y: 2)
                                    )
                            }
                            .rotationEffect(.degrees(isExpanded ? 360 : 0))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }
            .frame(height: chartSize + 48) // Fixed height for the main content
            .padding(.horizontal, 4)
            .padding(.vertical, 24)
            
            // Title - always at bottom
            Text(data.title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.currentColors.mainBgColor)
                .shadow(color: themeManager.currentColors.mainBorderColor.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Helper Methods
    
    private var largestSegment: DonutChartSegment {
        return data.segments.max { $0.value < $1.value } ?? data.segments.first!
    }
    
    private var largestSegmentIndex: Int {
        guard let largestSegment = data.segments.max(by: { $0.value < $1.value }),
              let index = data.segments.firstIndex(where: { $0.id == largestSegment.id }) else {
            return 0
        }
        return index
    }
    
    private var currentCenterValue: Int {
        if let selectedIndex = selectedSegmentIndex,
           selectedIndex < data.segments.count {
            return data.segments[selectedIndex].count
        }
        return data.centerValue
    }
    
    private var currentCenterLabel: String {
        if let selectedIndex = selectedSegmentIndex,
           selectedIndex < data.segments.count {
            return data.segments[selectedIndex].label
        }
        return largestSegment.label
    }
    
    private func startAnimation() {
        // Initialize segment animation progress
        segmentAnimationProgress = Array(repeating: 0, count: data.segments.count)
        
        // Select largest segment by default
        selectedSegmentIndex = largestSegmentIndex
        
        // Animate center value
        withAnimation(.easeOut(duration: 0.8)) {
            animationProgress = 1.0
        }
        
        // Animate segments with staggered delay
        for i in 0..<data.segments.count {
            withAnimation(.easeOut(duration: 1.0).delay(Double(i) * 0.2)) {
                if i < segmentAnimationProgress.count {
                    segmentAnimationProgress[i] = 1.0
                }
            }
        }
    }
    
    private func startFractionForSegment(at index: Int) -> Double {
        let precedingTotal = data.segments.prefix(index).reduce(0) { $0 + $1.value }
        return precedingTotal / 100.0
    }
    
    private func endFractionForSegment(at index: Int) -> Double {
        let precedingTotal = data.segments.prefix(index + 1).reduce(0) { $0 + $1.value }
        return precedingTotal / 100.0
    }
}

// MARK: - Supporting Views

struct DonutSegmentView: View {
    let segment: DonutChartSegment
    let startFraction: Double
    let endFraction: Double
    let animationProgress: CGFloat
    let strokeWidth: CGFloat
    let isSelected: Bool
    
    var body: some View {
        let segmentLength = endFraction - startFraction
        let animatedStartFraction = startFraction
        let animatedEndFraction = startFraction + (segmentLength * Double(animationProgress))
        
        Circle()
            .trim(from: animatedStartFraction, to: animatedEndFraction)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        segment.color,
                        segment.color.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(
                    lineWidth: isSelected ? strokeWidth + 4 : strokeWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90)) // Start from top (12 o'clock)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
            .animation(.easeInOut(duration: 1.0), value: animationProgress)
    }
}

#Preview {
    DonutChart(
        data: DonutChartData(
            id: "example",
            title: "Example Chart",
            centerValue: 233,
            segments: [
                DonutChartSegment(label: "Normal", value: 69.97, color: .blue, count: 233),
                DonutChartSegment(label: "Warning", value: 20.0, color: .orange, count: 67),
                DonutChartSegment(label: "Critical", value: 10.03, color: .red, count: 34),
                DonutChartSegment(label: "Danger", value: 131.03, color: .green, count: 131)
            ]
        )
    )
    .environmentObject(ThemeManager.shared)
} 
