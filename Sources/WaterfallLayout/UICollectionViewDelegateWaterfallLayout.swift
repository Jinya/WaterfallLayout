//
//  UICollectionViewDelegateWaterfallLayout.swift
//  WaterfallLayout <https://github.com/Jinya/WaterfallLayout>
//
//  Available under the MIT license.

import UIKit

@objc public protocol UICollectionViewDelegateWaterfallLayout: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForHeaderIn section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       heightForFooterIn section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       insetsFor section: Int) -> UIEdgeInsets

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       minimumInteritemSpacingFor section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       minimumColumnSpacingFor section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       columnCountFor section: Int) -> Int
}
