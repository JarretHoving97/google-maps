import UIKit

extension String {
    func toImage(size: CGFloat) -> UIImage {
        let nsString = self
        let font = UIFont.systemFont(ofSize: size)
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
    
    func toAvatarImage(size: CGFloat) -> UIImage {
        let subStr = String(self.prefix(1)) + "."
        
        // Calculate the font size as 40% of the given size
        let fontSize = size * 0.4
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .regular),
            .foregroundColor: UIColor.white
        ]

        let textSize = subStr.size(withAttributes: textAttributes)
        let imageSize = CGSize(width: size, height: size)

        let image = UIGraphicsImageRenderer(size: imageSize).image { context in
            context.cgContext.setFillColor(UIColor.orange.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: imageSize))

            let textRect = CGRect(
                x: (size - textSize.width) / 2,
                y: (size - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            subStr.draw(in: textRect, withAttributes: textAttributes)
        }

        return image
    }
    
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<String.Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex, let range = self[startIndex...].range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound
                ? range.upperBound
                : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
