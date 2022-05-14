//
// WaterfallLayout
// The MIT License (MIT)
//
// Copyright (c) 2018-2022 Jinya (https://github.com/Jinya)

import UIKit

extension CGSize {
    static func -(lhs: Self, rhs: Self) -> Self {
        return .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    /// Return the size after content insets are applied.
    func applyingInset(_ inset: UIEdgeInsets) -> CGSize {
        return self - CGSize(width: inset.left + inset.right,
                             height: inset.top + inset.bottom)
    }
}
