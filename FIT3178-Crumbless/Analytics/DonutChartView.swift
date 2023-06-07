//
//  PieChartView.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 8/6/2023.
//

import UIKit

// Struct for a segment in the pie chart
struct Segment {
    let name: String
    let colour: UIColor
    let value: CGFloat
}

// Custom Donut Chart View class
class DonutChartView: UIView {
    var segments: [Segment] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Get the center point and radius of the view
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        
        // Set the radius and colour for the hole
        let holeRadius = radius * 0.7
        var holeColour = UIColor.white
        if UserDefaults.standard.bool(forKey: "darkMode") {
            holeColour = UIColor.black
        }
        
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
            
            // Draw path for the segment
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            
            // Fill the segment shaped by path
            segment.colour.setFill()
            path.fill()
            
            // Draw path for the hole
            let holePath = UIBezierPath()
            holePath.move(to: center)
            holePath.addArc(withCenter: center, radius: holeRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            holePath.close()
            
            // Fill the hole
            holeColour.setFill()
            holePath.fill()
            holeColour.setStroke()
            holePath.stroke()
            
            // Update the start angle for the next segment
            startAngle = endAngle
        }
        
        // Draw the centre text
        let consumedCount = segments[0].value
        let expiredCount = segments[1].value
        let totalCount = consumedCount + expiredCount
        drawCentre(consumed: consumedCount, total: totalCount)
        
        // Draw the legend
        drawLegend()
    }
    
    func drawCentre(consumed: CGFloat, total: CGFloat) {
        // Calculate the percentage of consumed food
        let consumedPercentage = Int((consumed / total) * 100)
        let centreText = "Consumed \n\(consumedPercentage)%"
        
        // Create the centre text rectangle
        let centreOrigin = CGPoint(x: bounds.width*0.15, y: bounds.height*0.4)
        let centreRectangle = CGRect(origin: centreOrigin, size: CGSize(width: bounds.width*0.7, height: bounds.width/2))
        
        // Create the centre text
        var centreTextColour = UIColor.black
        if UserDefaults.standard.bool(forKey: "darkMode") {
            centreTextColour = UIColor.white
        }
        var centreTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 40),
            .foregroundColor: centreTextColour,
        ]
        
        // Set paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 3
        centreTextAttributes[.paragraphStyle] = paragraphStyle
        
        let centreTextAttributedString = NSAttributedString(string: centreText, attributes: centreTextAttributes)
        centreTextAttributedString.draw(in: centreRectangle)
    }
    
    func drawLegend() {
        let legendOrigin = CGPoint(x: 10, y: bounds.height - 20)
        let legendItemSize = CGSize(width: 20, height: 20)
        let legendSpacing: CGFloat = 5
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
            let legendRectangleWidth = legendItemRectangle.width + legendTextWidth + legendSpacing * 5
            legendRectangle = legendRectangle.offsetBy(dx: legendRectangleWidth, dy: 0)
        }
    }
    
}


/**
 References
 - Drawing path: https://developer.apple.com/documentation/uikit/uibezierpath
 - Drawing and filling shapes defined by path: https://stackoverflow.com/questions/31569051/how-to-draw-a-line-in-the-simplest-way-in-swift
 - Setting stroke and fill colours: https://stackoverflow.com/questions/25533091/how-to-change-the-color-of-a-uibezierpath-in-swift
 - Calculating pie chart angles: https://stackoverflow.com/questions/29179692/how-can-i-convert-from-degrees-to-radians
 - Creating rectangles for legend elements: https://developer.apple.com/documentation/corefoundation/cgrect
 - Positioning legend element rectangles: https://developer.apple.com/documentation/corefoundation/cgpoint
 - Writing legend text: https://developer.apple.com/documentation/foundation/nsattributedstring
 - Wrapping multiline text: https://stackoverflow.com/questions/24134905/how-do-i-set-adaptive-multiline-uilabel-text
 */
