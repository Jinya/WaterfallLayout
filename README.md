# WaterfallLayout
A waterfall-like (Pinterest-style) layout for UICollectionView.

## Requirements
iOS 9.0+

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

class DemoViewController: UIViewController {

    // Waterfall View
    lazy var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        
        // you can customize your layout
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumColumnSpacing = 16
        layout.minimumVerticalItemSpacing = 16
        layout.columnCount = 2
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(DemoWaterfallCell.self, forCellWithReuseIdentifier: "reuseIdentifier")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

// UICollectionView DataSource & Delegate
extension DemoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let name = ["airplane", "car", "bus", "tram", "bicycle"].randomElement()!
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath) as? DemoWaterfallCell else {
            let cell = DemoWaterfallCell(frame: .zero)
            cell.name = name
            return cell
        }
        cell.name = name
        return cell
    }
}

// WaterfallView Delegate
extension DemoViewController: WaterfallViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = [100, 150, 200].randomElement()!
        return height
    }
}
```

## MIT License 

WaterfallLayout released under the MIT license. See LICENSE for details.
