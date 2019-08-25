# WaterflowLayout
Waterflow style layout for UICollectionView.
# Example
### Frame for Unsplash
https://itunes.apple.com/cn/app/frame-for-unsplash/id1380041207?mt=8

![Preview](https://github.com/JinyaX/WaterflowLayout/blob/master/preview.gif)

# How to use
Drag the ‘WaterflowLayout.swift’ to your Xcode project. It contains a protocol `WaterflowLayoutDelegate` and a class `WaterflowLayout`.

Write a custom collectionView in your view controller like this:
```swift
class YourViewController: UIViewController {

    ......

    // Waterflow View
    var collectionView: UICollectionView = {
        let layout = WaterflowLayout()
        layout.sectionInset = UIEdgeInset(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumColumnSpacing = 10
        layout.minimumInneritemSpacing = 10
        layout.columnCount = 2
        let view = UICollectionView(frame: YOUR_VIEW_FRAME, collectionViewLayout: layout)
        view.register(WaterFlowCell.self, forCellWithReuseIdentifier: "CELl_REUSE_ID")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
    }

    ......
    
}

// UICollectionView DataSource & Delegate
extension YourViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    ......

}

// WaterflowViewDelegate
extension YourViewController: WaterflowViewDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let height = calculated item's height
        let width = calculated item's width
        return CGSize(width: width, height: height)
    }
    
}
```
