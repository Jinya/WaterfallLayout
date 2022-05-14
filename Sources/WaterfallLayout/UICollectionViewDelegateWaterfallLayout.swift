//
// WaterfallLayout
// The MIT License (MIT)
//
// Copyright (c) 2018-2022 Jinya (https://github.com/Jinya)

import UIKit

@available(iOS 11.0, *)
@objc public protocol UICollectionViewDelegateWaterfallLayout: UICollectionViewDelegate {

    // MARK: - Getting the Size of Items

    /// Asks the delegate for the size of the specified item’s cell.
    ///
    /// If you do not implement this method, the waterfall layout uses the values in its `itemSize` property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    @objc optional func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize

    /// Asks the delegate for the number of columns in the specified section.
    ///
    /// If you do not implement this method, the waterfall layout uses the values in its `numberOfColumns` property to set the number of columns instead.
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       numberOfColumnsInSection section: Int) -> Int

    // MARK: - Getting the Section Spacing

    /// Asks the delegate for the margins to apply to content in the specified section.
    ///
    /// If you do not implement this method, the waterfall layout uses the value in its `sectionInset` property to set the margins instead.
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       insetForSectionAt section: Int) -> UIEdgeInsets

    /// Asks the delegate for the spacing between columns of a section.
    ///
    /// If you do not implement this method, the waterfall layout uses the value in its `minimumColumnSpacing` property to set the space between columns instead.
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       minimumColumnSpacingForSectionAt section: Int) -> CGFloat

    /// Asks the delegate for the size of the footer view in the specified section.
    ///
    /// If you do not implement this method, the waterfall layout uses the value in its `minimumInteritemSpacing` property to set the space between items instead.
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       minimumInteritemSpacingForSectionAt section: Int) -> CGFloat

    // MARK: - Getting the Header and Footer Sizes

    /// Asks the delegate for the size of the header view in the specified section.
    ///
    /// If you do not implement this method, the waterfall layout uses the value in its `headerReferenceSize` property to set the size of the header.
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       referenceSizeForHeaderInSection section: Int) -> CGSize

    /// Asks the delegate for the size of the footer view in the specified section.
    ///
    /// If you do not implement this method, the waterfall layout uses the value in its `footerReferenceSize` property to set the size of the footer.
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       referenceSizeForFooterInSection section: Int) -> CGSize
}
