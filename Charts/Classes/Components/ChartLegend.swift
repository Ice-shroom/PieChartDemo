//
//  ChartLegend.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 24/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


public class ChartLegend: ChartComponentBase
{
    /// This property is deprecated - Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated=1.0, message="Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
    @objc(ChartLegendPosition)
    public enum Position: Int
    {
        case RightOfChart
        case RightOfChartCenter
        case RightOfChartInside
        case LeftOfChart
        case LeftOfChartCenter
        case LeftOfChartInside
        case BelowChartLeft
        case BelowChartRight
        case BelowChartCenter
        case AboveChartLeft
        case AboveChartRight
        case AboveChartCenter
        case PiechartCenter
    }
    
    @objc(ChartLegendForm)
    public enum Form: Int
    {
        case Square
        case Circle
        case Line
    }
    
    @objc(ChartLegendHorizontalAlignment)
    public enum HorizontalAlignment: Int
    {
        case Left
        case Center
        case Right
    }
    
    @objc(ChartLegendVerticalAlignment)
    public enum VerticalAlignment: Int
    {
        case Top
        case Center
        case Bottom
    }
    
    @objc(ChartLegendOrientation)
    public enum Orientation: Int
    {
        case Horizontal
        case Vertical
    }
    
    @objc(ChartLegendDirection)
    public enum Direction: Int
    {
        case LeftToRight
        case RightToLeft
    }

    /// the legend colors array, each color is for the form drawn at the same index
    public var colors = [NSUIColor?]()
    
    // the legend text array. a nil label will start a group.
    public var labels = [String?]()
    
    internal var _extraColors = [NSUIColor?]()
    internal var _extraLabels = [String?]()
    
    /// colors that will be appended to the end of the colors array after calculating the legend.
    public var extraColors: [NSUIColor?] { return _extraColors; }
    
    /// labels that will be appended to the end of the labels array after calculating the legend. a nil label will start a group.
    public var extraLabels: [String?] { return _extraLabels; }
    
    /// Are the legend labels/colors a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// 
    /// **default**: false (automatic legend)
    private var _isLegendCustom = false
    
    /// This property is deprecated - Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated=1.0, message="Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
    public var position: Position
    {
        get
        {
            if orientation == .Vertical && horizontalAlignment == .Center && verticalAlignment == .Center
            {
                return .PiechartCenter
            }
            else if orientation == .Horizontal
            {
                if verticalAlignment == .Top
                {
                    return horizontalAlignment == .Left ? .AboveChartLeft : (horizontalAlignment == .Right ? .AboveChartRight : .AboveChartCenter)
                }
                else
                {
                    return horizontalAlignment == .Left ? .BelowChartLeft : (horizontalAlignment == .Right ? .BelowChartRight : .BelowChartCenter)
                }
            }
            else
            {
                if horizontalAlignment == .Left
                {
                    return verticalAlignment == .Top && drawInside ? .LeftOfChartInside : (verticalAlignment == .Center ? .LeftOfChartCenter : .LeftOfChart)
                }
                else
                {
                    return verticalAlignment == .Top && drawInside ? .RightOfChartInside : (verticalAlignment == .Center ? .RightOfChartCenter : .RightOfChart)
                }
            }
        }
        set
        {
            switch newValue
            {
            case .LeftOfChart: fallthrough
            case .LeftOfChartInside: fallthrough
            case .LeftOfChartCenter:
                horizontalAlignment = .Left
                verticalAlignment = newValue == .LeftOfChartCenter ? .Center : .Top
                orientation = .Vertical
                
            case .RightOfChart: fallthrough
            case .RightOfChartInside: fallthrough
            case .RightOfChartCenter:
                horizontalAlignment = .Right
                verticalAlignment = newValue == .RightOfChartCenter ? .Center : .Top
                orientation = .Vertical
                
            case .AboveChartLeft: fallthrough
            case .AboveChartCenter: fallthrough
            case .AboveChartRight:
                horizontalAlignment = newValue == .AboveChartLeft ? .Left : (newValue == .AboveChartRight ? .Right : .Center)
                verticalAlignment = .Top
                orientation = .Horizontal
                
            case .BelowChartLeft: fallthrough
            case .BelowChartCenter: fallthrough
            case .BelowChartRight:
                horizontalAlignment = newValue == .BelowChartLeft ? .Left : (newValue == .BelowChartRight ? .Right : .Center)
                verticalAlignment = .Bottom
                orientation = .Horizontal
                
            case .PiechartCenter:
                horizontalAlignment = .Center
                verticalAlignment = .Center
                orientation = .Vertical
            }
            
            drawInside = newValue == .LeftOfChartInside || newValue == .RightOfChartInside
        }
    }
    
    /// The horizontal alignment of the legend
    public var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.Left
    
    /// The vertical alignment of the legend
    public var verticalAlignment: VerticalAlignment = VerticalAlignment.Bottom
    
    /// The orientation of the legend
    public var orientation: Orientation = Orientation.Horizontal
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    public var drawInside: Bool = false
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    public var isDrawInsideEnabled: Bool { return drawInside }
    
    /// The text direction of the legend
    public var direction: Direction = Direction.LeftToRight

    public var font: NSUIFont = NSUIFont.systemFontOfSize(10.0)
    public var textColor = NSUIColor.blackColor()

    public var form = Form.Square
    public var formSize = CGFloat(8.0)
    public var formLineWidth = CGFloat(1.5)
    
    public var xEntrySpace = CGFloat(6.0)
    public var yEntrySpace = CGFloat(0.0)
    public var formToTextSpace = CGFloat(5.0)
    public var stackSpace = CGFloat(3.0)
    
    public var calculatedLabelSizes = [CGSize]()
    public var calculatedLabelBreakPoints = [Bool]()
    public var calculatedLineSizes = [CGSize]()
    
    public override init()
    {
        super.init()
        
        self.xOffset = 5.0
        self.yOffset = 3.0
    }
    
    public init(colors: [NSUIColor?], labels: [String?])
    {
        super.init()
        
        self.colors = colors
        self.labels = labels
    }
    
    public init(colors: [NSObject], labels: [NSObject])
    {
        super.init()
        
        self.colorsObjc = colors
        self.labelsObjc = labels
    }
    
    public func getMaximumEntrySize(font: NSUIFont) -> CGSize
    {
        var maxW = CGFloat(0.0)
        var maxH = CGFloat(0.0)
        
        var labels = self.labels
        for i in 0 ..< labels.count
        {
            if (labels[i] == nil)
            {
                continue
            }
            
            let size = (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: font])
            
            if (size.width > maxW)
            {
                maxW = size.width
            }
            if (size.height > maxH)
            {
                maxH = size.height
            }
        }
        
        return CGSize(
            width: maxW + formSize + formToTextSpace,
            height: maxH
        )
    }
    
    public func getLabel(index: Int) -> String?
    {
        return labels[index]
    }
    
    /// This function is deprecated - Please read `neededWidth`/`neededHeight` after `calculateDimensions` was called.
    @available(*, deprecated=1.0, message="Please read `neededWidth`/`neededHeight` after `calculateDimensions` was called.")
    public func getFullSize(labelFont: NSUIFont) -> CGSize
    {
        return CGSize(width: neededWidth, height: neededHeight)
    }

    public var neededWidth = CGFloat(0.0)
    public var neededHeight = CGFloat(0.0)
    public var textWidthMax = CGFloat(0.0)
    public var textHeightMax = CGFloat(0.0)
    
    /// flag that indicates if word wrapping is enabled
    /// this is currently supported only for `orientation == Horizontal`.
    /// you may want to set maxSizePercent when word wrapping, to set the point where the text wraps.
    /// 
    /// **default**: false
    public var wordWrapEnabled = true
    
    /// if this is set, then word wrapping the legend is enabled.
    public var isWordWrapEnabled: Bool { return wordWrapEnabled }

    /// The maximum relative size out of the whole chart view in percent.
    /// If the legend is to the right/left of the chart, then this affects the width of the legend.
    /// If the legend is to the top/bottom of the chart, then this affects the height of the legend.
    /// 
    /// **default**: 0.95 (95%)
    public var maxSizePercent: CGFloat = 0.95
    
    public func calculateDimensions(labelFont labelFont: NSUIFont, viewPortHandler: ChartViewPortHandler)
    {
        let maxEntrySize = getMaximumEntrySize(labelFont)
        textWidthMax = maxEntrySize.width
        textHeightMax = maxEntrySize.height
        
        switch orientation
        {
        case .Vertical:
            
            var maxWidth = CGFloat(0.0)
            var width = CGFloat(0.0)
            var maxHeight = CGFloat(0.0)
            let labelLineHeight = labelFont.lineHeight
            
            var labels = self.labels
            let count = labels.count
            var wasStacked = false
            
            for i in 0 ..< count
            {
                let drawingForm = colors[i] != nil
                
                if !wasStacked
                {
                    width = 0.0
                }
                
                if drawingForm
                {
                    if wasStacked
                    {
                        width += stackSpace
                    }
                    width += formSize
                }
                
                if labels[i] != nil
                {
                    let size = (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont])
                    
                    if drawingForm && !wasStacked
                    {
                        width += formToTextSpace
                    }
                    else if wasStacked
                    {
                        maxWidth = max(maxWidth, width)
                        maxHeight += labelLineHeight + yEntrySpace
                        width = 0.0
                        wasStacked = false
                    }
                    
                    width += size.width
                    
                    if (i < count - 1)
                    {
                        maxHeight += labelLineHeight + yEntrySpace
                    }
                }
                else
                {
                    wasStacked = true
                    width += formSize
                    
                    if (i < count - 1)
                    {
                        width += stackSpace
                    }
                }
                
                maxWidth = max(maxWidth, width)
            }
            
            neededWidth = maxWidth
            neededHeight = maxHeight
            
        case .Horizontal:
            
            var labels = self.labels
            var colors = self.colors
            let labelCount = labels.count
            
            let labelLineHeight = labelFont.lineHeight
            let formSize = self.formSize
            let formToTextSpace = self.formToTextSpace
            let xEntrySpace = self.xEntrySpace
            let stackSpace = self.stackSpace
            let wordWrapEnabled = self.wordWrapEnabled
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth * maxSizePercent
            
            // Prepare arrays for calculated layout
            if (calculatedLabelSizes.count != labelCount)
            {
                calculatedLabelSizes = [CGSize](count: labelCount, repeatedValue: CGSize())
            }
            
            if (calculatedLabelBreakPoints.count != labelCount)
            {
                calculatedLabelBreakPoints = [Bool](count: labelCount, repeatedValue: false)
            }
            
            calculatedLineSizes.removeAll(keepCapacity: true)
            
            // Start calculating layout
            
            let labelAttrs = [NSFontAttributeName: labelFont]
            var maxLineWidth: CGFloat = 0.0
            var currentLineWidth: CGFloat = 0.0
            var requiredWidth: CGFloat = 0.0
            var stackedStartIndex: Int = -1
            
            for i in 0 ..< labelCount
            {
                let drawingForm = colors[i] != nil
                
                calculatedLabelBreakPoints[i] = false
                
                if (stackedStartIndex == -1)
                {
                    // we are not stacking, so required width is for this label only
                    requiredWidth = 0.0
                }
                else
                {
                    // add the spacing appropriate for stacked labels/forms
                    requiredWidth += stackSpace
                }
                
                // grouped forms have null labels
                if (labels[i] != nil)
                {
                    calculatedLabelSizes[i] = (labels[i] as NSString!).sizeWithAttributes(labelAttrs)
                    requiredWidth += drawingForm ? formToTextSpace + formSize : 0.0
                    requiredWidth += calculatedLabelSizes[i].width
                }
                else
                {
                    calculatedLabelSizes[i] = CGSize()
                    requiredWidth += drawingForm ? formSize : 0.0
                    
                    if (stackedStartIndex == -1)
                    {
                        // mark this index as we might want to break here later
                        stackedStartIndex = i
                    }
                }
                
                if (labels[i] != nil || i == labelCount - 1)
                {
                    let requiredSpacing = currentLineWidth == 0.0 ? 0.0 : xEntrySpace
                    
                    if (!wordWrapEnabled || // No word wrapping, it must fit.
                        currentLineWidth == 0.0 || // The line is empty, it must fit.
                        (contentWidth - currentLineWidth >= requiredSpacing + requiredWidth)) // It simply fits
                    {
                        // Expand current line
                        currentLineWidth += requiredSpacing + requiredWidth
                    }
                    else
                    { // It doesn't fit, we need to wrap a line
                        
                        // Add current line size to array
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                        
                        // Start a new line
                        calculatedLabelBreakPoints[stackedStartIndex > -1 ? stackedStartIndex : i] = true
                        currentLineWidth = requiredWidth
                    }
                    
                    if (i == labelCount - 1)
                    { // Add last line size to array
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                    }
                }
                
                stackedStartIndex = labels[i] != nil ? -1 : stackedStartIndex
            }
            
            neededWidth = maxLineWidth
            neededHeight = labelLineHeight * CGFloat(calculatedLineSizes.count) +
                yEntrySpace * CGFloat(calculatedLineSizes.count == 0 ? 0 : (calculatedLineSizes.count - 1))
        }
    }
    
    /// MARK: - Custom legend
    
    /// colors and labels that will be appended to the end of the auto calculated colors and labels after calculating the legend.
    /// (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
    public func setExtra(colors colors: [NSUIColor?], labels: [String?])
    {
        self._extraLabels = labels
        self._extraColors = colors
    }
    
    /// Sets a custom legend's labels and colors arrays.
    /// The colors count should match the labels count.
    /// * Each color is for the form drawn at the same index.
    /// * A nil label will start a group.
    /// * A nil color will avoid drawing a form, and a clearColor will leave a space for the form.
    /// This will disable the feature that automatically calculates the legend labels and colors from the datasets.
    /// Call `resetCustom(...)` to re-enable automatic calculation (and then `notifyDataSetChanged()` is needed).
    public func setCustom(colors colors: [NSUIColor?], labels: [String?])
    {
        self.labels = labels
        self.colors = colors
        _isLegendCustom = true
    }
    
    /// Calling this will disable the custom legend labels (set by `setLegend(...)`). Instead, the labels will again be calculated automatically (after `notifyDataSetChanged()` is called).
    public func resetCustom()
    {
        _isLegendCustom = false
    }
    
    /// **default**: false (automatic legend)
    /// - returns: true if a custom legend labels and colors has been set
    public var isLegendCustom: Bool
    {
        return _isLegendCustom
    }
    
    /// MARK: - ObjC compatibility
    
    /// colors that will be appended to the end of the colors array after calculating the legend.
    public var extraColorsObjc: [NSObject] { return ChartUtils.bridgedObjCGetNSUIColorArray(swift: _extraColors); }
    
    /// labels that will be appended to the end of the labels array after calculating the legend. a nil label will start a group.
    public var extraLabelsObjc: [NSObject] { return ChartUtils.bridgedObjCGetStringArray(swift: _extraLabels); }
    
    /// the legend colors array, each color is for the form drawn at the same index
    /// (ObjC bridging functions, as Swift 1.2 does not bridge optionals in array to `NSNull`s)
    public var colorsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetNSUIColorArray(swift: colors); }
        set { self.colors = ChartUtils.bridgedObjCGetNSUIColorArray(objc: newValue); }
    }
    
    // the legend text array. a nil label will start a group.
    /// (ObjC bridging functions, as Swift 1.2 does not bridge optionals in array to `NSNull`s)
    public var labelsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetStringArray(swift: labels); }
        set { self.labels = ChartUtils.bridgedObjCGetStringArray(objc: newValue); }
    }
    
    /// colors and labels that will be appended to the end of the auto calculated colors and labels after calculating the legend.
    /// (if the legend has already been calculated, you will need to call `notifyDataSetChanged()` to let the changes take effect)
    public func setExtra(colors colors: [NSObject], labels: [NSObject])
    {
        if (colors.count != labels.count)
        {
            fatalError("ChartLegend:setExtra() - colors array and labels array need to be of same size")
        }
        
        self._extraLabels = ChartUtils.bridgedObjCGetStringArray(objc: labels)
        self._extraColors = ChartUtils.bridgedObjCGetNSUIColorArray(objc: colors)
    }
    
    /// Sets a custom legend's labels and colors arrays.
    /// The colors count should match the labels count.
    /// * Each color is for the form drawn at the same index.
    /// * A nil label will start a group.
    /// * A nil color will avoid drawing a form, and a clearColor will leave a space for the form.
    /// This will disable the feature that automatically calculates the legend labels and colors from the datasets.
    /// Call `resetLegendToAuto(...)` to re-enable automatic calculation, and then if needed - call `notifyDataSetChanged()` on the chart to make it refresh the data.
    public func setCustom(colors colors: [NSObject], labels: [NSObject])
    {
        if (colors.count != labels.count)
        {
            fatalError("ChartLegend:setCustom() - colors array and labels array need to be of same size")
        }
        
        self.labelsObjc = labels
        self.colorsObjc = colors
        _isLegendCustom = true
    }
}
