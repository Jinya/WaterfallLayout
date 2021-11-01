# WaterfallLayout
A waterfall-like layout for UICollectionView.

## Preview
![Preview](preview.gif)

## Installation
#### Swift Package Manager (Recommended)

- Xcode >  File > Swift Packages > Add Package Dependency
- Add `https://github.com/Jinya/WaterfallLayout.git`
- Select "Exact Version" (recommend using the latest exact version)

## How to use
```swift
import UIKit
import WaterfallLayout

class YourViewController: UIViewController {

    ......

    // Waterfall View
    var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        layout.sectionInset = UIEdgeInset(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumColumnSpacing = 10
        layout.minimumInneritemSpacing = 10
        layout.columnCount = 2
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(WaterFlowCell.self, forCellWithReuseIdentifier: "CELl_REUSE_ID")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }

    ......
    
}

// UICollectionView DataSource & Delegate
extension YourViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    ......

}

// WaterflowView Delegate
extension YourViewController: WaterflowViewDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let height = calculated item's height
        let width = calculated item's width
        return CGSize(width: width, height: height)
    }

}
```

## MIT License 

WaterfallLayout released under the MIT license. See LICENSE for details.
