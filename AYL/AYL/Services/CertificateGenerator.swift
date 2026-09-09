//
//  CertificateGenerator.swift
//  AYL
//
//  Created by Олеся Орленко on 09.09.2026.
//

import UIKit

enum CertificateGenerator {

    static func makeImage(participantName: String, eventTitle: String, eventDateText: String) -> UIImage? {
        guard let template = UIImage(named: "CertificateTemplate") else { return nil }
        let size = template.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            template.draw(at: .zero)

            drawCentered(
                participantName, in: size, centerYFraction: 0.335,
                fontSize: size.width * 0.0413, weight: .bold, italic: false,
                color: UIColor(red: 0x24 / 255, green: 0x24 / 255, blue: 0x30 / 255, alpha: 1),
                maxWidthFraction: 0.9
            )
            drawCentered(
                eventTitle, in: size, centerYFraction: 0.438,
                fontSize: size.width * 0.0325, weight: .bold, italic: true,
                color: UIColor(red: 0x3E / 255, green: 0x9B / 255, blue: 0xD8 / 255, alpha: 1),
                maxWidthFraction: 0.72
            )
            drawCentered(
                eventDateText, in: size, centerYFraction: 0.5075,
                fontSize: size.width * 0.02, weight: .medium, italic: false,
                color: UIColor(red: 0x9A / 255, green: 0x9A / 255, blue: 0xA5 / 255, alpha: 1),
                maxWidthFraction: 0.9
            )
        }
    }

    private static func drawCentered(
        _ text: String, in size: CGSize, centerYFraction: CGFloat,
        fontSize: CGFloat, weight: UIFont.Weight, italic: Bool,
        color: UIColor, maxWidthFraction: CGFloat
    ) {
        let maxWidth = size.width * maxWidthFraction
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        func font(for pointSize: CGFloat) -> UIFont {
            let base = UIFont.systemFont(ofSize: pointSize, weight: weight)
            guard italic else { return base }
            var traits: UIFontDescriptor.SymbolicTraits = [.traitItalic]
            if weight == .bold { traits.insert(.traitBold) }
            guard let descriptor = base.fontDescriptor.withSymbolicTraits(traits) else { return base }
            return UIFont(descriptor: descriptor, size: pointSize)
        }

        var currentSize = fontSize
        var attributed = NSAttributedString(string: text, attributes: [.font: font(for: currentSize), .foregroundColor: color, .paragraphStyle: paragraph])
        var singleLineWidth = attributed.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).width

        while singleLineWidth > maxWidth && currentSize > fontSize * 0.55 {
            currentSize -= 2
            attributed = NSAttributedString(string: text, attributes: [.font: font(for: currentSize), .foregroundColor: color, .paragraphStyle: paragraph])
            singleLineWidth = attributed.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).width
        }

        let wrappedSize = attributed.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).size
        let origin = CGPoint(x: (size.width - maxWidth) / 2, y: size.height * centerYFraction - wrappedSize.height / 2)
        attributed.draw(with: CGRect(origin: origin, size: CGSize(width: maxWidth, height: wrappedSize.height)), options: [.usesLineFragmentOrigin], context: nil)
    }
}
