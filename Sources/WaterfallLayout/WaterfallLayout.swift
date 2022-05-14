//
// WaterfallLayout
// The MIT License (MIT)
//
// Copyright (c) 2018-2022 Jinya (https://github.com/Jinya)

import UIKit

extension WaterfallLayout {
    /// Constants that describe the reference point of the section insets.
    public enum SectionInsetReference: Int {
        /// Section insets are defined in relation to the collection view's content inset.
        case fromContentInset = 0

        /// Section insets are defined in relation to the safe area of the layout.
        case fromSafeArea = 1

        /// Section insets are defined in relation to the margins of the layout.
        case fromLayoutMargins = 2
    }
}

/// A layout object that organizes items into a waterfall with optional header and footer views for each section.
@available(iOS 11.0, *)
public class WaterfallLayout: UICollectionViewLayout {
    /// The default size to use for cells.
    ///
    /// If the delegate does not implement the collectionView(_:layout:sizeForItemAt:) method, the waterfall layout uses the value in this property to set the size of each cell. This results in cells that all have the same size.
    ///
    /// The default size value is (50.0, 50.0).
    public var itemSize: CGSize = .init(width: 50, height: 50) {
        didSet { invalidateLayout() }
    }

    public var numberOfColumns: Int = 1 {
        didSet {
            invalidateLayout()
        }
    }

    /// The minimum spacing to use between columns of items in the waterfall.
    public var minimumColumnSpacing: CGFloat = 0 {
        didSet { invalidateLayout() }
    }

    /// The minimum spacing to use between items in the same row.
    public var minimumInteritemSpacing: CGFloat = 0 {
        didSet { invalidateLayout() }
    }

    /// The margins used to lay out content in a section.
    public var sectionInset: UIEdgeInsets = .zero {
        didSet { invalidateLayout() }
    }

    /// The boundary that section insets are defined in relation to.
    ///
    /// The default value of this property is `WaterfallLayout.SectionInsetReference.fromContentInset`.
    ///
    /// The minimum value of this property is always the collection view's contentInset. For example, if the value of this property is `WaterfallLayout.SectionInsetReference.fromSafeArea`, but the adjusted content inset is greater than the combination of the safe area and section insets, then the section's content is aligned with the content inset instead.
    public var sectionInsetReference: SectionInsetReference = .fromContentInset {
        didSet { invalidateLayout() }
    }

    public var headerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }

    public var footerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }

    public var delegate: UICollectionViewDelegateWaterfallLayout? {
        get {
            return collectionView!.delegate as? UICollectionViewDelegateWaterfallLayout
        }
    }

    // ╔═════════════════════╦═════════╦═════════╗
    // ║ `columnHeight`      ║ column 0║ column 1║
    // ╠═════════════════════╬═════════╬═════════╣
    // ║ section 0           ║ 200     ║ 220     ║
    // ╠═════════════════════╬═════════╬═════════╣
    // ║ section 1           ║ 550     ║ 530     ║
    // ╠═════════════════════╬═════════╬═════════╣
    // ║ section 2           ║ 800     ║ 820     ║
    // ╚═════════════════════╩═════════╩═════════╝

    /// Array of arrays. Each array stores all waterfall column heights for each section.
    private var columnHeights: [[CGFloat]] = []

    /// Array of arrays. Each array stores item attributes for each section.
    private var attributesForSectionItems: [[UICollectionViewLayoutAttributes]] = []

    /// LayoutAttributes for all elements in the collection view, including cells, supplementary views, and decoration views.
    private var attributesForAllElements: [UICollectionViewLayoutAttributes] = []

    private var attributesForHeaders: [Int: UICollectionViewLayoutAttributes] = [:]
    private var attributesForFooters: [Int: UICollectionViewLayoutAttributes] = [:]

    /// Array to store union rectangles.
    private var unionRects: [CGRect] = []
    private let unionSize = 20

    public override func invalidateLayout() {
        super.invalidateLayout()
    }

    public override func prepare() {
        super.prepare()

        let numberOfSections = collectionView!.numberOfSections
        guard numberOfSections > 0 else {
            return
        }

        attributesForHeaders = [:]
        attributesForFooters = [:]
        unionRects = []
        attributesForAllElements = []
        attributesForSectionItems = .init(repeating: [], count: numberOfSections)
        columnHeights = .init(repeating: [], count: numberOfSections)

        var top: CGFloat = 0
        var attributes = UICollectionViewLayoutAttributes()

        for section in 0..<numberOfSections {

            // 1. Get section-specific metrics
            let sectionInset = inset(forSection: section)
            let numberOfColumns = numberOfColumns(inSection: section)
            let columnSpacing = columnSpacing(forSection: section)
            let interitemSpacing = interitemSpacing(forSection: section)
            let effectiveItemWidth = effectiveItemWidth(inSection: section)

            // 2. Header
            let headerSize = headerReferenceSize(inSection: section)
            if headerSize.height > 0 {
                attributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: IndexPath(row: 0, section: section)
                )
                attributes.frame = CGRect(x: 0, y: top,
                                          width: headerSize.width,
                                          height: headerSize.height)

                attributesForHeaders[section] = attributes
                attributesForAllElements.append(attributes)

                top = attributes.frame.maxY
            }

            top += sectionInset.top
            columnHeights[section] = [CGFloat](repeating: top, count: numberOfColumns)

            // 3. Cells
            let numberOfItems = collectionView!.numberOfItems(inSection: section)

            // Every item will be put into the shortest column of current section.
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                let currentColumnIndex = columnIndex(forItemAt: indexPath)

                let xOffset = sectionInset.left + (effectiveItemWidth + columnSpacing) * CGFloat(currentColumnIndex)
                let yOffset = columnHeights[section][currentColumnIndex]

                let referenceItemSize = itemSize(at: indexPath)
                let effectiveItemHeight = (effectiveItemWidth * referenceItemSize.height / referenceItemSize.width)

                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset,
                                          width: effectiveItemWidth, height: effectiveItemHeight)

                attributesForSectionItems[section].append(attributes)
                attributesForAllElements.append(attributes)
                columnHeights[section][currentColumnIndex] = attributes.frame.maxY + interitemSpacing
            }

            // 4. Footer
            let longestLineIndex  = longestColumnIndex(inSection: section)
            top = columnHeights[section][longestLineIndex] - interitemSpacing + sectionInset.bottom
            let footerSize = footerReferenceSize(inSection: section)

            if footerSize.height > 0 {
                attributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    with: IndexPath(item: 0, section: section)
                )
                attributes.frame = CGRect(x: 0, y: top,
                                          width: footerSize.width,
                                          height: footerSize.height)

                attributesForFooters[section] = attributes
                attributesForAllElements.append(attributes)

                top = attributes.frame.maxY
            }

            columnHeights[section] = [CGFloat](repeating: top, count: numberOfColumns)
        }

        // Cache rects
        let count = attributesForAllElements.count
        var i = 0
        while i < count {
            let rect1 = attributesForAllElements[i].frame
            i = min(i + unionSize, count) - 1
            let rect2 = attributesForAllElements[i].frame
            unionRects.append(rect1.union(rect2))
            i += 1
        }
    }

    public override var collectionViewContentSize: CGSize {
        guard collectionView!.numberOfSections > 0,
              let collectionViewContentHeight = columnHeights.last?.first else {
            return .zero
        }
        return .init(width: collectionViewEffectiveContentSize.width, height: collectionViewContentHeight)
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= attributesForSectionItems.count {
            return nil
        }
        let list = attributesForSectionItems[indexPath.section]
        if indexPath.item >= list.count {
            return nil
        }
        return list[indexPath.item]
    }

    public override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes {
        var attribute: UICollectionViewLayoutAttributes?
        if elementKind == UICollectionView.elementKindSectionHeader {
            attribute = attributesForHeaders[indexPath.section]
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            attribute = attributesForFooters[indexPath.section]
        }
        return attribute ?? UICollectionViewLayoutAttributes()
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count

        if let i = unionRects.firstIndex(where: { rect.intersects($0) }) {
            begin = i * unionSize
        }
        if let i = unionRects.lastIndex(where: { rect.intersects($0) }) {
            end = min((i + 1) * unionSize, attributesForAllElements.count)
        }
        return attributesForAllElements[begin..<end]
            .filter { rect.intersects($0.frame) }
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView!.bounds.width
    }

    /// Find the column index for the item at specifying indexPath.
    private func columnIndex(forItemAt indexPath: IndexPath) -> Int {
        return shortestColumnIndex(inSection: indexPath.section)
    }

    /// Find the shortest column in the specifying section.
    private func shortestColumnIndex(inSection section: Int) -> Int {
        return columnHeights[section].enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }

    /// Find the longest column in the specifying section.
    private func longestColumnIndex(inSection section: Int) -> Int {
        return columnHeights[section].enumerated()
            .max(by: { $0.element < $1.element })?
            .offset ?? 0
    }
}

extension WaterfallLayout {
    private var collectionViewEffectiveContentSize: CGSize {
        let inset: UIEdgeInsets
        switch sectionInsetReference {
        case .fromContentInset:
            inset = collectionView!.contentInset
        case .fromSafeArea:
            inset = collectionView!.safeAreaInsets
        case .fromLayoutMargins:
            inset = collectionView!.layoutMargins
        }
        return collectionView!.bounds.size.applyingInset(inset)
    }

    private func effectiveContentWidth(forSection section: Int) -> CGFloat {
        let sectionInset = inset(forSection: section)
        return collectionViewEffectiveContentSize.width - sectionInset.left - sectionInset.right
    }

    private func effectiveItemWidth(inSection section: Int) -> CGFloat {
        let numberOfColumns = numberOfColumns(inSection: section)
        let columnSpacing = columnSpacing(forSection: section)
        let sectionContentWidth = effectiveContentWidth(forSection: section)
        let width = (sectionContentWidth - (columnSpacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)
        assert(width >= 0, "Item's width should be negative value.")
        return width
    }

    private func itemSize(at indexPath: IndexPath) -> CGSize {
        let referenceItemSize = delegate?.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) ?? itemSize
        assert(referenceItemSize.width.isNormal && referenceItemSize.height.isNormal, "Item size values must be normal values(not zero, subnormal, infinity, or NaN).")
        return referenceItemSize
    }

    private func numberOfColumns(inSection section: Int) -> Int {
        let numberOfColumns = delegate?.collectionView?(collectionView!, layout: self, numberOfColumnsInSection: section) ?? numberOfColumns
        assert(numberOfColumns > 0, "The number of columns must be greater than zero.")
        return numberOfColumns
    }

    private func inset(forSection section: Int) -> UIEdgeInsets {
        return delegate?.collectionView?(collectionView!, layout: self, insetForSectionAt: section) ?? sectionInset
    }

    private func columnSpacing(forSection section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView!, layout: self, minimumColumnSpacingForSectionAt: section) ?? minimumColumnSpacing
    }

    private func interitemSpacing(forSection section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
    }

    private func headerReferenceSize(inSection section: Int) -> CGSize {
        return delegate?.collectionView?(collectionView!, layout: self, referenceSizeForHeaderInSection: section) ?? headerReferenceSize
    }

    private func footerReferenceSize(inSection section: Int) -> CGSize {
        return delegate?.collectionView?(collectionView!, layout: self, referenceSizeForFooterInSection: section) ?? footerReferenceSize
    }
}
