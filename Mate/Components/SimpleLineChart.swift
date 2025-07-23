import SwiftUI

struct SimpleLineChart: View {
    let title: String
    let trendData: [HealthScoreTrendItem]
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedDataPoint: HealthScoreTrendItem?
    @State private var showTooltip: Bool = false
    @State private var tooltipPosition: CGPoint = .zero
    @State private var animationProgress: CGFloat = 0
    @State private var pointAnimationProgress: CGFloat = 0
    
    private let chartHeight: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 0) {
            // Chart Title
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.bottom, 20)
            
            if trendData.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.3))
                    Text("no_data_available".localized())
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                }
                .frame(height: chartHeight)
                .padding(.bottom, 24)
            } else {
                VStack(spacing: 16) {
                    // Main Chart Area - Scrollable
                    ScrollView(.horizontal, showsIndicators: false) {
                        GeometryReader { geometry in
                            ZStack {
                                // Grid Background
                                GridBackground()
                                
                                // Chart Line with animation
                                if normalizedPoints(width: geometry.size.width).count > 1 {
                                    AnimatedLinePath(
                                        points: normalizedPoints(width: geometry.size.width),
                                        animationProgress: animationProgress
                                    )
                                    .stroke(Color.blue, lineWidth: 2)
                                }
                                
                                // Data Points with staggered animation
                                ForEach(Array(normalizedPoints(width: geometry.size.width).enumerated()), id: \.offset) { index, point in
                                    let pointDelay = Double(index) * 0.05
                                    let pointProgress = max(0, min(1, (pointAnimationProgress - pointDelay) / 0.3))
                                    
                                    Circle()
                                        .fill(selectedDataPoint?.label == trendData[index].label ? Color.blue : Color.white)
                                        .frame(width: 8, height: 8)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                        .scaleEffect(pointProgress)
                                        .opacity(pointProgress)
                                        .position(
                                            x: point.x + 35, // Y-axis için padding
                                            y: point.y + 20  // X-axis için padding
                                        )
                                        .onTapGesture {
                                            handleDataPointTap(at: index, point: point, geometry: geometry)
                                        }
                                }
                                
                                // Smart Tooltip
                                if showTooltip, let selectedData = selectedDataPoint {
                                    SmartTooltipView(
                                        dataPoint: selectedData,
                                        position: tooltipPosition,
                                        chartBounds: geometry.frame(in: .local)
                                    )
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                }
                                
                                // Y-Axis Labels
                                VStack {
                                    ForEach(yAxisLabels.reversed(), id: \.self) { label in
                                        Text(String(format: "%.1f", label))
                                            .font(.caption2)
                                            .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if label != yAxisLabels.last {
                                            Spacer()
                                        }
                                    }
                                }
                                .frame(width: 30, height: chartHeight)
                                .position(x: 15, y: chartHeight/2 + 20)
                            }
                        }
                        .frame(width: calculateChartWidth(), height: chartHeight + 40)
                    }
                    .padding(.horizontal, 24)
                    
                    // X-Axis Labels - Scrollable for many data points
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: 35) // Y-axis için padding
                            
                            HStack(spacing: 0) {
                                ForEach(Array(trendData.enumerated()), id: \.offset) { index, item in
                                    Text(item.label)
                                        .font(.caption2)
                                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.8))
                                        .frame(width: 60) // Point spacing ile aynı
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            Spacer()
                                .frame(width: 35) // Sağ padding
                        }
                        .frame(width: calculateChartWidth())
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(themeManager.currentColors.mainBgColor)
                .shadow(
                    color: themeManager.currentColors.mainBorderColor.opacity(0.15),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .onAppear {
            startAnimation()
        }
        .onChange(of: trendData) {
            resetAndStartAnimation()
        }
    }
    
    // MARK: - Animation Methods
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.5)) {
            animationProgress = 1.0
        }
        
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            pointAnimationProgress = 1.0
        }
    }
    
    private func resetAndStartAnimation() {
        animationProgress = 0
        pointAnimationProgress = 0
        startAnimation()
    }
    
    // MARK: - Computed Properties
    
    private var dataPoints: [Double] {
        return trendData.map { $0.value }
    }
    
    private var yAxisLabels: [Double] {
        guard !dataPoints.isEmpty else { return [0, 2, 4, 6, 8, 10] }
        
        let minValue = dataPoints.min() ?? 0
        let maxValue = dataPoints.max() ?? 10
        let range = maxValue - minValue
        
        let padding = range * 0.1
        let adjustedMin = max(0, minValue - padding)
        let adjustedMax = maxValue + padding
        let adjustedRange = adjustedMax - adjustedMin
        
        let step = adjustedRange / 4
        var labels: [Double] = []
        
        for i in 0...4 {
            let value = adjustedMin + (step * Double(i))
            labels.append(value)
        }
        
        return labels
    }
    
    private func calculateChartWidth() -> CGFloat {
        let pointSpacing: CGFloat = 60
        let leftPadding: CGFloat = 35
        let rightPadding: CGFloat = 35
        let minWidth = UIScreen.main.bounds.width - 48 // padding
        
        if trendData.isEmpty {
            return minWidth
        }
        
        let calculatedWidth = CGFloat(max(1, trendData.count - 1)) * pointSpacing + leftPadding + rightPadding
        return max(minWidth, calculatedWidth)
    }
    
    private func normalizedPoints(width: CGFloat) -> [CGPoint] {
        guard !dataPoints.isEmpty else { return [] }
        
        let minValue = yAxisLabels.first ?? 0
        let maxValue = yAxisLabels.last ?? 10
        let range = maxValue - minValue
        
        let pointSpacing: CGFloat = 60 // Sabit mesafe her point arasında
        let usableHeight = chartHeight - 40 // Üst/alt padding
        
        return dataPoints.enumerated().map { index, value in
            let x = CGFloat(index) * pointSpacing
            let normalizedValue = range > 0 ? (value - minValue) / range : 0.5
            let y = usableHeight - (CGFloat(normalizedValue) * usableHeight)
            return CGPoint(x: x, y: y)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleDataPointTap(at index: Int, point: CGPoint, geometry: GeometryProxy) {
        selectedDataPoint = trendData[index]
        
        // Smart tooltip positioning
        let baseX = point.x + 35
        let baseY = point.y + 20
        
        tooltipPosition = calculateSmartTooltipPosition(
            basePosition: CGPoint(x: baseX, y: baseY),
            chartBounds: geometry.frame(in: .local)
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showTooltip = true
        }
        
        // Auto-hide tooltip after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if selectedDataPoint?.label == trendData[index].label {
                withAnimation(.easeOut(duration: 0.2)) {
                    showTooltip = false
                }
            }
        }
    }
    
    private func calculateSmartTooltipPosition(basePosition: CGPoint, chartBounds: CGRect) -> CGPoint {
        let tooltipWidth: CGFloat = 80
        let tooltipHeight: CGFloat = 40
        let margin: CGFloat = 10
        
        var adjustedPosition = basePosition
        
        // Horizontal positioning
        if basePosition.x + tooltipWidth/2 > chartBounds.maxX - margin {
            // Too far right, move left
            adjustedPosition.x = chartBounds.maxX - tooltipWidth/2 - margin
        } else if basePosition.x - tooltipWidth/2 < chartBounds.minX + margin {
            // Too far left, move right
            adjustedPosition.x = chartBounds.minX + tooltipWidth/2 + margin
        }
        
        // Vertical positioning
        if basePosition.y - tooltipHeight - margin < chartBounds.minY {
            // Too high, show below point
            adjustedPosition.y = basePosition.y + tooltipHeight + margin
        } else {
            // Show above point
            adjustedPosition.y = basePosition.y - tooltipHeight/2 - margin
        }
        
        return adjustedPosition
    }
}

// MARK: - Supporting Views

struct GridBackground: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Horizontal grid lines
            VStack(spacing: 0) {
                ForEach(0..<5) { _ in
                    Rectangle()
                        .fill(themeManager.currentColors.mainBorderColor.opacity(0.2))
                        .frame(height: 1)
                    Spacer()
                }
                Rectangle()
                    .fill(themeManager.currentColors.mainBorderColor.opacity(0.2))
                    .frame(height: 1)
            }
            
            // Vertical grid lines
            HStack(spacing: 0) {
                ForEach(0..<5) { _ in
                    Rectangle()
                        .fill(themeManager.currentColors.mainBorderColor.opacity(0.1))
                        .frame(width: 1)
                    Spacer()
                }
                Rectangle()
                    .fill(themeManager.currentColors.mainBorderColor.opacity(0.1))
                    .frame(width: 1)
            }
        }
    }
}

struct AnimatedLinePath: Shape {
    let points: [CGPoint]
    var animationProgress: CGFloat
    
    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }
        
        var path = Path()
        let paddingOffset = CGPoint(x: 35, y: 20)
        
        // Calculate the total length of the path
        var totalLength: CGFloat = 0
        for i in 1..<points.count {
            let prevPoint = points[i-1]
            let currentPoint = points[i]
            totalLength += sqrt(pow(currentPoint.x - prevPoint.x, 2) + pow(currentPoint.y - prevPoint.y, 2))
        }
        
        let targetLength = totalLength * animationProgress
        var currentLength: CGFloat = 0
        
        path.move(to: CGPoint(x: points[0].x + paddingOffset.x, y: points[0].y + paddingOffset.y))
        
        for i in 1..<points.count {
            let prevPoint = points[i-1]
            let currentPoint = points[i]
            let segmentLength = sqrt(pow(currentPoint.x - prevPoint.x, 2) + pow(currentPoint.y - prevPoint.y, 2))
            
            if currentLength + segmentLength <= targetLength {
                // Draw the full segment
                path.addLine(to: CGPoint(x: currentPoint.x + paddingOffset.x, y: currentPoint.y + paddingOffset.y))
                currentLength += segmentLength
            } else {
                // Draw partial segment
                let remainingLength = targetLength - currentLength
                let ratio = remainingLength / segmentLength
                let partialX = prevPoint.x + (currentPoint.x - prevPoint.x) * ratio
                let partialY = prevPoint.y + (currentPoint.y - prevPoint.y) * ratio
                path.addLine(to: CGPoint(x: partialX + paddingOffset.x, y: partialY + paddingOffset.y))
                break
            }
        }
        
        return path
    }
}

struct SmartTooltipView: View {
    let dataPoint: HealthScoreTrendItem
    let position: CGPoint
    let chartBounds: CGRect
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dataPoint.label)
                .font(.caption)
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.8))
            
            Text(String(format: "%.1f", dataPoint.value))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentColors.mainTextColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeManager.currentColors.primaryWorkspaceColor)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .overlay(
            // Arrow pointing to the data point
            Triangle()
                .fill(themeManager.currentColors.primaryWorkspaceColor)
                .frame(width: 8, height: 6)
                .rotationEffect(.degrees(180))
                .offset(y: 20)
        )
        .position(position)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SimpleLineChart(
        title: "Weekly Trend",
        trendData: [
            HealthScoreTrendItem(label: "Mon", value: 7.2),
            HealthScoreTrendItem(label: "Tue", value: 6.8),
            HealthScoreTrendItem(label: "Wed", value: 8.1),
            HealthScoreTrendItem(label: "Thu", value: 7.5),
            HealthScoreTrendItem(label: "Fri", value: 8.9),
            HealthScoreTrendItem(label: "Sat", value: 7.1),
            HealthScoreTrendItem(label: "Sun", value: 8.3),
            HealthScoreTrendItem(label: "Mon2", value: 6.9),
            HealthScoreTrendItem(label: "Tue2", value: 7.8),
            HealthScoreTrendItem(label: "Wed2", value: 8.5),
            HealthScoreTrendItem(label: "Thu2", value: 7.2),
            HealthScoreTrendItem(label: "Fri2", value: 8.7),
            HealthScoreTrendItem(label: "Sat2", value: 7.6),
            HealthScoreTrendItem(label: "Sun2", value: 8.2),
            HealthScoreTrendItem(label: "Mon3", value: 7.9)
        ]
    )
    .environmentObject(ThemeManager.shared)
}
