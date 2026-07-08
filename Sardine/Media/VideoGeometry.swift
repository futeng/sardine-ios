import AVFoundation
import CoreGraphics

enum VideoGeometry {
    static func displaySize(naturalSize: CGSize, preferredTransform: CGAffineTransform) -> CGSize {
        let transformed = CGRect(origin: .zero, size: naturalSize).applying(preferredTransform)
        return CGSize(width: abs(transformed.width), height: abs(transformed.height))
    }

    static func outputSize(displaySize: CGSize, maxLongSide: CGFloat) -> CGSize {
        guard displaySize.width > 0, displaySize.height > 0 else {
            return displaySize
        }

        let longSide = max(displaySize.width, displaySize.height)
        guard longSide > maxLongSide else {
            return evenSize(displaySize)
        }

        let scale = maxLongSide / longSide
        return evenSize(CGSize(width: displaySize.width * scale, height: displaySize.height * scale))
    }

    private static func evenSize(_ size: CGSize) -> CGSize {
        let width = max(2, Int(size.width.rounded()))
        let height = max(2, Int(size.height.rounded()))
        return CGSize(
            width: width.isMultiple(of: 2) ? width : width - 1,
            height: height.isMultiple(of: 2) ? height : height - 1
        )
    }
}

