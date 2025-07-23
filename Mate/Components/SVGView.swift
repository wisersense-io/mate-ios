import SwiftUI
import WebKit

struct SVGView: UIViewRepresentable {
    let svgString: String
    let size: CGSize
    @EnvironmentObject var themeManager: ThemeManager
    
    // Convenience initializer for square size
    init(svgString: String, size: CGFloat) {
        self.svgString = svgString
        self.size = CGSize(width: size, height: size)
    }
    
    // Full initializer for custom size
    init(svgString: String, size: CGSize) {
        self.svgString = svgString
        self.size = size
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Get theme colors from ThemeManager
        let mainTextColorHex = themeManager.currentColors.mainTextColor.toHex()
        let svgSymbolColorHex = themeManager.currentColors.svgSymbolColor.toHex()
        let svgPointNotEmptyColorHex = themeManager.currentColors.svgPointNotEmptyColor.toHex()
        let svgPointEmptyColorHex = themeManager.currentColors.svgPointEmptyColor.toHex()
        let deviceRemovedColor = "#ffa308"
        
        // Theme class for dynamic CSS
        let themeClass = themeManager.isDarkMode ? "dark" : "light"
        
        // ✅ RESIZE SVG METHOD (JavaScript ported to Swift)
        let resizedSvgString = resizeSystemIcon(svgString, targetWidth: size.width, targetHeight: size.height)
        
        let htmlString = """
        <!DOCTYPE html>
        <html class="\(themeClass)">
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                :root {
                    --svg-symbol-color          : \(svgSymbolColorHex);
                    --svg-point-not-empty-color : \(svgPointNotEmptyColorHex);
                    --svg-point-empty-color     : \(svgPointEmptyColorHex);
                    --svg-main-text-color       : \(mainTextColorHex);
                }
                
                body {
                    margin: 0;
                    padding: 0;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    background-color: transparent;
                    overflow: hidden;
                }
        
                .rotate {
                    transform-box: fill-box;
                    transform-origin: center;
                }
                .rotate-90 {
                    transform: rotate(90deg);
                }
                .rotate-180 {
                    transform: rotate(180deg);
                }
                .rotate-270 {
                    transform: rotate(-90deg);
                }   
                
                svg {
                    overflow-clip-margin: content-box !important;
                    overflow: visible !important;
                    transform-origin: 50% 50% !important;
                    /* Default fill color for all SVG elements */
                    fill: var(--svg-main-text-color);
                }
                
                .svg-container {
                    width: \(size.width)px;
                    height: \(size.height)px;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    position: relative;
                }
                
                .svg-container svg {
                    width: 100%;
                    height: 100%;
                    object-fit: contain;
                    max-width: none;
                    max-height: none;
                }
        
                /* SVG Element Specific Colors */
                svg.symbol,
                svg [class="symbol"],
                [class="symbol"] {
                    fill: var(--svg-symbol-color) !important;
                }
                
                svg.point[empty="false"],
                svg [class="point"][empty="false"],
                [class="point"][empty="false"] {
                    fill: var(--svg-point-not-empty-color) !important;
                    stroke: none;
                }
                
                svg.point:not([empty]),
                svg.point[empty="true"],
                svg [class="point"]:not([empty]),
                svg [class="point"][empty="true"],
                [class="point"]:not([empty]),
                [class="point"][empty="true"] {
                    fill: var(--svg-point-empty-color) !important;
                    stroke: none !important;
                }
                
                svg.point[deviceRemoved="true"],
                svg [class="point"][deviceRemoved="true"],
                [class="point"][deviceRemoved="true"],
                svg [deviceRemoved="true"],
                [deviceRemoved="true"] {
                    fill: \(deviceRemovedColor) !important;
                    stroke: none;
                }
            </style>
        </head>
        <body>
            <div class="svg-container">
                \(resizedSvgString)
            </div>
        </body>
        </html>
        """
        
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    // MARK: - Helper Functions
    
    /// JavaScript resizeSystemIcon method ported to Swift
    private func resizeSystemIcon(_ icon: String, targetWidth: CGFloat? = nil, targetHeight: CGFloat? = nil) -> String {
        // Parse viewBox from SVG
        guard let viewBoxMatch = extractViewBox(from: icon) else {
            // If no viewBox, add width and height attributes to opening SVG tag
            let widthAttr = targetWidth != nil ? "width=\"\(targetWidth!)\"" : ""
            let heightAttr = targetHeight != nil ? "height=\"\(targetHeight!)\"" : ""
            
            // Find the opening SVG tag and add attributes
            let svgPattern = "<svg([^>]*?)>"
            if let regex = try? NSRegularExpression(pattern: svgPattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: icon, options: [], range: NSRange(location: 0, length: icon.count)),
               let range = Range(match.range, in: icon) {
                let originalTag = String(icon[range])
                let newTag = originalTag.replacingOccurrences(
                    of: "<svg",
                    with: "<svg \(widthAttr) \(heightAttr)"
                )
                return icon.replacingOccurrences(of: originalTag, with: newTag)
            }
            return icon // Return original if no SVG tag found
        }
        
        let originalWidth = viewBoxMatch.width
        let originalHeight = viewBoxMatch.height
        
        // Use provided dimensions or fallback to original
        let width = targetWidth ?? originalWidth
        let height = targetHeight ?? originalHeight
        
        // Calculate scale (minimum to maintain aspect ratio)
        let scale = min(width / originalWidth, height / originalHeight)
        
        // Calculate scaled dimensions
        let scaledWidth = originalWidth * scale
        let scaledHeight = originalHeight * scale
        
        // Create width and height attributes
        let widthAttr = "width=\"\(Int(scaledWidth))\""
        let heightAttr = "height=\"\(Int(scaledHeight))\""
        
        // Find and replace the opening SVG tag
        let svgPattern = "<svg([^>]*?)>"
        if let regex = try? NSRegularExpression(pattern: svgPattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: icon, options: [], range: NSRange(location: 0, length: icon.count)),
           let range = Range(match.range, in: icon) {
            let originalTag = String(icon[range])
            let newTag = originalTag.replacingOccurrences(
                of: "<svg",
                with: "<svg \(widthAttr) \(heightAttr)"
            )
            return icon.replacingOccurrences(of: originalTag, with: newTag)
        }
        
        return icon // Return original if no SVG tag found
    }
    
    private func extractViewBox(from svgString: String) -> (width: CGFloat, height: CGFloat)? {
        // Regex to find viewBox attribute
        let viewBoxPattern = #"viewBox\s*=\s*["|']([^"|']+)["|']"#
        
        guard let regex = try? NSRegularExpression(pattern: viewBoxPattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: svgString, options: [], range: NSRange(location: 0, length: svgString.count)),
              let range = Range(match.range(at: 1), in: svgString) else {
            return nil
        }
        
        let viewBoxValue = String(svgString[range])
        let components = viewBoxValue.split(separator: " ").compactMap { Double($0) }
        
        guard components.count >= 4 else { return nil }
        
        // viewBox format: "x y width height"
        return (width: CGFloat(components[2]), height: CGFloat(components[3]))
    }
}

// Extension to convert SwiftUI Color to hex
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
