//
//  WaterflowLayout.swift
//  Frame
//
//  Created by Jinya on 2018/4/25.
//  Copyright © 2018年 Jinya. All rights reserved.
//

import UIKit

@objc protocol WaterflowViewDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForHeaderInSection section: NSInteger) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForFooterInSection section: NSInteger) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       minimumInneritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat
}

enum WaterflowLayoutItemRenderDirection: NSInteger {
    case shortestFirst
    case leftToRight
    case rightToLeft
}

class WaterflowLayout: UICollectionViewLayout {
    
    /// column count
    var columnCount: NSInteger {
        didSet {
            invalidateLayout()
        }
    }
    
    /// spacing between two columns
    var minimumColumnSpacing: CGFloat {
        didSet {
            invalidateLayout()
        }
    }
    
    /// spacing between two items in a column
    var minimumInneritemSpacing: CGFloat {
        didSet {
            invalidateLayout()
        }
    }
    
    /// height for header
    var headerHeight: CGFloat {
        didSet {
            invalidateLayout()
        }
    }
    
    /// height for footer
    var footerHeight: CGFloat {
        didSet {
            invalidateLayout()
        }
    }
    
    /// insets for section
    var sectionInset: UIEdgeInsets {
        didSet {
            invalidateLayout()
        }
    }
    
    /// direction priority for item rendering
    var itemRenderDirection: WaterflowLayoutItemRenderDirection {
        didSet {
            invalidateLayout()
        }
    }
    
    
    // MARK: - Private
    private let waterflowElementKindSectionHeader = "waterflowElementKindSectionHeader"
    private let waterflowElementKindSectionFooter = "waterflowElementKindSectionFooter"
    
    private weak var delegate: WaterflowViewDelegate? {
        get {
            return self.collectionView?.delegate as? WaterflowViewDelegate
        }
    }
    
    private var columnHeights: [CGFloat]
    private var sectionAttributes: [[UICollectionViewLayoutAttributes]]
    private var allItemAttributes: [UICollectionViewLayoutAttributes]
    private var headersAttributes: [UICollectionViewLayoutAttributes]
    private var footersAttributes: [UICollectionViewLayoutAttributes]
    private var unionRects: [CGRect]
    private let unionSize = 20
    
    override init() {
        headerHeight = 0.0
        footerHeight = 0.0
        columnCount = 2
        minimumInneritemSpacing = 16
        minimumColumnSpacing = 16
        sectionInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        itemRenderDirection = .shortestFirst
        
        headersAttributes = []
        footersAttributes = []
        unionRects = []
        columnHeights = []
        allItemAttributes = []
        sectionAttributes = []
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func itemWidth(in section: NSInteger) -> CGFloat {
        let width: CGFloat = self.collectionView!.frame.size.width - sectionInset.left - sectionInset.right
        let spaceColumCount: CGFloat = CGFloat(columnCount - 1)
        return floor((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columnCount))
    }
    
    override func prepare(){
        super.prepare()
        
        guard let cView = self.collectionView else { return }
        
        let numberOfSections = cView.numberOfSections
        if numberOfSections == 0 { return }
        
        headersAttributes.removeAll()
        footersAttributes.removeAll()
        unionRects.removeAll()
        columnHeights.removeAll()
        allItemAttributes.removeAll()
        sectionAttributes.removeAll()
        
        var idx = 0
        while idx < columnCount {
            columnHeights.append(0)
            idx += 1
        }
        
        var top: CGFloat = 0.0
        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0 ..< numberOfSections {
            /*
             * 1. Get section-specific metrics (minimumInneritemSpacing, sectionInset)
             */
            var minimumInneritemSpacing: CGFloat
            if let miniumSpacing = self.delegate?.collectionView?(cView,
                                                                  layout: self, minimumInneritemSpacingForSectionAtIndex: section) {
                minimumInneritemSpacing = miniumSpacing
            } else {
                minimumInneritemSpacing = self.minimumColumnSpacing
            }

            let width = cView.frame.size.width - sectionInset.left - sectionInset.right
            let spaceColumCount = CGFloat(columnCount - 1)
            let itemWidth = floor((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columnCount))
            
            /*
             * 2. Section header
             */
            var heightHeader: CGFloat
            if let height = self.delegate?.collectionView?(cView, layout: self, heightForHeaderInSection: section) {
                heightHeader = height
            } else {
                heightHeader = self.headerHeight
            }
            
            if heightHeader > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: waterflowElementKindSectionHeader, with: IndexPath(row: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: cView.frame.size.width, height: heightHeader)
                headersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                
                // top = attributes.frame.maxX
                top = attributes.frame.maxY
            }
            top += sectionInset.top
            for idx in 0 ..< columnCount {
                columnHeights[idx]=top;
            }
            
            /*
             * 3. Section items
             */
            let itemCount = cView.numberOfItems(inSection: section)
            //            var itemAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes].init(repeating: UICollectionViewLayoutAttributes(), count: itemCount)
            var itemAttributes: [UICollectionViewLayoutAttributes] = []
            
            // Item will be put into shortest column.
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                
                let columnIndex = nextColumnIndexForItem(idx)
                let xOffset = sectionInset.left + (itemWidth + minimumColumnSpacing) * CGFloat(columnIndex)
                let yOffset = columnHeights[columnIndex]
                let itemSize = self.delegate?.collectionView(cView, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight : CGFloat = 0.0
                if itemSize?.height > 0 && itemSize?.width > 0 {
                    itemHeight = floor(itemSize!.height*itemWidth/itemSize!.width)
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[columnIndex] = attributes.frame.maxY + minimumInneritemSpacing;
            }
            sectionAttributes.append(itemAttributes)
            
            /*
             * 4. Section footer
             */
            var footerHeight: CGFloat = 0.0
            let columnIndex  = longestColumnIndex()
            top = columnHeights[columnIndex] - minimumInneritemSpacing + sectionInset.bottom
            
            if let height = self.delegate?.collectionView?(cView,
                                                           layout: self, heightForFooterInSection: section) {
                footerHeight = height
            } else {
                footerHeight = self.footerHeight
            }
            
            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: waterflowElementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: cView.frame.size.width, height: footerHeight)
                footersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            
            for idx in 0 ..< columnCount {
                columnHeights[idx] = top
            }
        }
        
        idx = 0
        let itemCounts = allItemAttributes.count
        while (idx < itemCounts) {
            let rect1 = allItemAttributes[idx].frame as CGRect
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame as CGRect
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }
    
    override var collectionViewContentSize: CGSize {
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0 {
            return CGSize.zero
        }
        
        var contentSize = self.collectionView!.bounds.size as CGSize
        let height = columnHeights[0]
        contentSize.height = height
        return  contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= sectionAttributes.count {
            return nil
        }
        if indexPath.item >= sectionAttributes[indexPath.section].count {
            return nil
        }
        let list = sectionAttributes[indexPath.section]
        return list[indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes{
        var attribute = UICollectionViewLayoutAttributes()
        if elementKind == waterflowElementKindSectionHeader {
            attribute = headersAttributes[indexPath.section]
        } else if elementKind == waterflowElementKindSectionFooter {
            attribute = footersAttributes[indexPath.section]
        }
        return attribute
    }
    
    override func layoutAttributesForElements (in rect : CGRect) -> [UICollectionViewLayoutAttributes] {
        var begin = 0, end = unionRects.count
        let attrs = NSMutableArray()
        
        for i in 0 ..< end {
            if rect.intersects(unionRects[i]) {
                begin = i * unionSize;
                break
            }
        }
        var i = unionRects.count - 1
        while i >= 0 {
            if rect.intersects(unionRects[i]) {
                end = min((i + 1) * unionSize, allItemAttributes.count)
                break
            }
            i -= 1
        }
        for i in begin ..< end {
            let attr = allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.add(attr)
            }
        }
        
        return NSArray(array: attrs) as! [UICollectionViewLayoutAttributes]
    }
    
    override func shouldInvalidateLayout (forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        if newBounds.width != oldBounds.width{
            return true
        }
        return false
    }
    
    /// Find the shortest column index
    private func shortestColumnIndex () -> Int {
        guard let minHeight = columnHeights.min(),
            let index = columnHeights.firstIndex(of: minHeight) else {
                return 0
        }
        return index
    }
    
    /// Find the longest column index
    private func longestColumnIndex () -> Int {
        guard let maxHeight = columnHeights.max(),
            let index = columnHeights.firstIndex(of: maxHeight) else {
                return 0
        }
        return index
    }
    
    /// Find the column index of next item rendering
    private func nextColumnIndexForItem (_ item : Int) -> Int {
        var index = 0
        switch (itemRenderDirection){
        case .shortestFirst :
            index = shortestColumnIndex()
        case .leftToRight :
            index = (item % columnCount)
        case .rightToLeft:
            index = (columnCount - 1) - (item % columnCount);
        }
        return index
    }
}


// MARK: - Utils
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
