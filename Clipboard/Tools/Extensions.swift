//
//  Extensions.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/15.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Foundation
import AppKit

extension String {
    func humanizedTitle() -> String {
        let maxLength = 25
        let trimmedTitle = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedTitle.count > maxLength {
            let index = trimmedTitle.index(trimmedTitle.startIndex, offsetBy: maxLength)
            return "\(trimmedTitle[...index])..."
        } else {
            return trimmedTitle
        }
    }
}
extension NSImage {
    var averageColor: CGColor? {
        let inputImage = CIImage(cgImage: self.CGImage!)
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return NSColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255).cgColor
    }
}
extension NSImage {
    var CGImage: CGImage? {
        get {
            let imageData = self.tiffRepresentation
            let source = CGImageSourceCreateWithData(imageData as! CFData, nil) //.takeUnretainedValue()
            let maskRef = CGImageSourceCreateImageAtIndex(source!, 0, nil)
            return maskRef;
        }
    }
}
extension NSColor {
    convenience init(hexString: String) {
        var hex = hexString.hasPrefix("#") ? String(hexString.characters.dropFirst()) : hexString
        
        guard hex.characters.count == 3 || hex.characters.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            return
        }
        
        if hex.characters.count == 3 {
            for (index, char) in hex.characters.enumerated() {
                hex.insert(char, at: hex.characters.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        let number = Int(hex, radix: 16)!
        let red = CGFloat((number >> 16) & 0xFF) / 255.0
        let green = CGFloat((number >> 8) & 0xFF) / 255.0
        let blue = CGFloat(number & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
extension NSView {
    
    func bringSubviewToFront(_ view: NSView) {
        var theView = view
        self.sortSubviews({(viewA,viewB,rawPointer) in
            let view = rawPointer?.load(as: NSView.self)
            
            switch view {
            case viewA:
                return ComparisonResult.orderedDescending
            case viewB:
                return ComparisonResult.orderedAscending
            default:
                return ComparisonResult.orderedSame
            }
        }, context: &theView)
    }
    
}
