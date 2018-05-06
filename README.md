# WaterflowLayout
Waterflow style layout for UICollectionView.
# Preview
![Preview](https://github.com/JinyaX/WaterflowLayout/blob/master/preview.gif)
# How to use
Drag the ‘WaterflowLayout.swift’ to your Xcode project. It contains a protocol `WaterflowLayoutDelegate` and a class `WaterflowLayout`.
Write a custom collectionView like this:
```swift
class DemoCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, WaterflowLayoutDelegate {

    ......
    
    init() {
        super.init()
        
        let layout = WaterflowLayout()
        layout.delegate = self
        layout.sectionInset = UIEdgeInset(top: 10, left: 10, bottom: 10, right: 10)
        layout.columnSpacing = 10
        layout.rowSpacing = 10
        layout.columnsCount = 10
        self.collectionViewLayout = layout
    }
    
    // WaterflowLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let height = calculated item's height
        return height
    }
    
    ......
    
}
```
