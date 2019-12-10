//
//  String.swift
//  Rolique
//
//  Created by Bohdan Savych on 8/14/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "localized version of \(self)")
    }
    
    public func localizeWithFormat(arguments: CVarArg...) -> String{
        return String(format: self.localized, arguments: arguments)
    }
    
    func nsRange(from range: Range<Index>) -> NSRange {
        return .init(range, in: self)
    }
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
    
    public func width(for font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        
        return size.width
    }
    
    public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    public func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.width
    }
    
    public var withoutSpacesAndNewLines: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func toPasteboard() {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = self
    }
    
    public func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
