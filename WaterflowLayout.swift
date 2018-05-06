//
//  WaterflowLayout.swift
//  Frame
//
//  Created by Jinya on 2018/4/25.
//  Copyright © 2018年 Jinya. All rights reserved.
//

import UIKit

protocol WaterflowLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
}

class WaterflowLayout: UICollectionViewLayout {
    
    weak var delegate: WaterflowLayoutDelegate?
    
    /// collectionView sections contentInset, default = (10, 10, 10, 10)
    public var sectionInset: UIEdgeInsets = UIEdgeInsets(
        top: 10,
        left: 10,
        bottom: 10,
        right: 10
    )
    
    /// spacing between columns, default = 10
    public var columnSpacing: CGFloat = 10
    
    /// spacing between rows, default = 10
    public var rowSpacing: CGFloat = 10
    
    /// columns's count, default = 2
    public var columnsCount: Int = 2
    
    /// collectionView content Height
    private var contentHeight: CGFloat = 0
    
    /// max Y for columns
    private var maxYArray = [CGFloat]()
    
    /// attributes Array for all collectionViewItems
    private var attrsArray = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        return CGSize(
            width: collectionView!.frame.size.width,
            height: contentHeight + sectionInset.bottom
        )
    }
    
    override func prepare() {
        guard columnsCount > 0, let collectionView = collectionView else {
            return
        }
        contentHeight = sectionInset.top
        maxYArray.removeAll()
        attrsArray.removeAll()
        
        maxYArray = Array(repeating: sectionInset.top, count: columnsCount)
        
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        for i in 0..<itemsCount {
            let indexPath = IndexPath(item: i, section: 0)
            guard let attribute = layoutAttributesForItem(at: indexPath) else {
                continue
            }
            attrsArray.append(attribute)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let delegate = delegate, columnsCount > 0 else {
            return nil
        }
        
        /// find the shortest column
        let minHeight = maxYArray.min()!
        let minColumn = maxYArray.index(of: minHeight)!
        
        /// calculate the item size
        let width: CGFloat = (collectionView!.frame.size.width - sectionInset.left - sectionInset.right - CGFloat(columnsCount - 1) * columnSpacing) / CGFloat(columnsCount)
        let height: CGFloat = delegate.collectionView(collectionView!, heightForItemAt: indexPath)
        
        let x: CGFloat = sectionInset.left + (width + columnSpacing) * CGFloat(minColumn)
        var y = minHeight
        if indexPath.item >= columnsCount {
            y += rowSpacing
        }
        
        /// update the maxY
        maxYArray[minColumn] = y + height
        
        if contentHeight < maxYArray.max()! {
            contentHeight = maxYArray.max()!
        }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(x: x, y: y, width: width, height: height)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard columnsCount > 0 else {
            return nil
        }
        var resultAttrs = [UICollectionViewLayoutAttributes]()
        resultAttrs = attrsArray.filter({ (attr) -> Bool in
            return attr.frame.intersects(rect)
        })
        return resultAttrs
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }
        let oldBounds = collectionView.bounds
        
        return (oldBounds.width == newBounds.width) ? false : true
    }
}
