//
//  PieChartView.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 8/6/2023.
//

import UIKit

struct Segment {
    let name: String
    let colour: UIColor
    let value: CGFloat
}

class PieChartView: UIView {
    var segments: [Segment] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Get the center point and radius of the view
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        
        // Set up the initial angle (12 o'clock position = -90 degrees)
        var startAngle: CGFloat = -.pi / 2
        
        // Calculate the total value of all segments
        var totalValue: CGFloat = 0
        for segment in segments {
            totalValue += segment.value
        }
        
        // Draw each segment
        for segment in segments {
            // Calculate the end angle of the current segment
            let endAngle = startAngle + (2 * .pi * (segment.value / totalValue))
            
            // Create a path for the segment
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            
            // Set the fill colour for the segment
            segment.colour.setFill()
            
            // Fill the segment shaped by path
            path.fill()
            
            // Update the start angle for the next segment
            startAngle = endAngle
        }
        
        // Draw the legend
        drawLegend()
    }
    
    private func drawLegend() {
        let legendOrigin = CGPoint(x: 0, y: bounds.height - 20)
        let legendItemSize = CGSize(width: 20, height: 20)
        let legendSpacing: CGFloat = 8
        var legendRectangle = CGRect(origin: legendOrigin, size: CGSize.zero)
        
        for segment in segments {
            let legendColour = segment.colour
            let legendText = "\(segment.name): \(Int(segment.value))"
            
            // Create and draw the legend item rectangle
            let legendItemRectangle = CGRect(origin: legendRectangle.origin, size: legendItemSize)
            let legendColourPath = UIBezierPath(rect: legendItemRectangle)
            legendColour.setFill()
            legendColourPath.fill()
            
            // Create the legend text rectangle
            let legendTextOrigin = CGPoint(x: legendItemRectangle.maxX + legendSpacing, y: bounds.height - 18)
            let legendTextWidth = legendText.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)]).width
            let legendTextRectangle = CGRect(origin: legendTextOrigin, size: CGSize(width: legendTextWidth, height: legendItemSize.height))
            
            // Write the legend text
            var legendTextColour = UIColor.black
            if UserDefaults.standard.bool(forKey: "darkMode") {
                legendTextColour = UIColor.white
            }
            let legendTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: legendTextColour
            ]
            let legendTextAttributedString = NSAttributedString(string: legendText, attributes: legendTextAttributes)
            legendTextAttributedString.draw(in: legendTextRectangle)
            
            // Update the legend rectangle for the next segment legend
            let legendRectangleWidth = legendItemRectangle.width + legendTextWidth + legendSpacing * 4
            legendRectangle = legendRectangle.offsetBy(dx: legendRectangleWidth, dy: 0)
        }
    }
    
}
