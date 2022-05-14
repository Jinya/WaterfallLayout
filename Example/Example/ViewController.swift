
import UIKit
import WaterfallLayout

let cellReuseIdentifier = "cellReuseIdentifier"
let headerReuseIdentifier = "headerReuseIdentifier"
let footerReuseIdentifier = "footerReuseIdentifier"

class ViewController: UIViewController {
    let waterfallView = UICollectionView(frame: .zero, collectionViewLayout: WaterfallLayout())

    let colors: [UIColor] = [.red, .magenta, .brown, .blue, .purple, .blue, .cyan, .gray, .green, .yellow, .purple]

    lazy var cellSizes: [CGSize] = {
        let width = 500
        var sizes = [CGSize]()
        (0...100).forEach { _ in
            let height = [200, 300, 400, 500, 600, 700, 800, 900].randomElement()!
            sizes.append(.init(width: width, height: height))
        }
        return sizes
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        waterfallView.register(WaterfallViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        waterfallView.register(WaterfallHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        waterfallView.register(WaterfallHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier)
        waterfallView.dataSource = self
        waterfallView.delegate = self

        view.addSubview(waterfallView)
        waterfallView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waterfallView.topAnchor.constraint(equalTo: view.topAnchor),
            waterfallView.leftAnchor.constraint(equalTo: view.leftAnchor),
            waterfallView.rightAnchor.constraint(equalTo: view.rightAnchor),
            waterfallView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellSizes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? WaterfallViewCell else {
            fatalError()
        }
        cell.titleLabel.text = "cell \(indexPath.item)"
        cell.contentView.backgroundColor = colors.randomElement()!
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? WaterfallHeaderFooterView else {
                fatalError()
            }
            header.titleLabel.text = "Header"
            return header
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as? WaterfallHeaderFooterView else {
                fatalError()
            }
            footer.titleLabel.text = "footer"
            return footer
        default:
            fatalError()
        }
    }
}

extension ViewController: UICollectionViewDelegateWaterfallLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int {
        return traitCollection.horizontalSizeClass == .compact ? 2 : 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSizes[indexPath.item]
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumColumnSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 80)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 80)
    }
}

extension ViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Did select cell at \(indexPath.description)")
    }
}
