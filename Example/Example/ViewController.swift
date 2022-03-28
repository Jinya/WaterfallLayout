//
//  ViewController.swift
//  Example
//
//  Created by Jinya on 2022/3/28.
//

import UIKit
import WaterfallLayout

class WaterfallViewCell: UICollectionViewCell {
    static let reuseIdentifier = "reuseIdentifier"

    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.cornerRadius = 12
        titleLabel.clipsToBounds = true

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

class ViewController: UIViewController {

    var waterfallView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewWaterfallLayout()
        layout.columnCount = 2
        layout.minimumColumnSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        waterfallView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        waterfallView.register(WaterfallViewCell.self, forCellWithReuseIdentifier: WaterfallViewCell.reuseIdentifier)
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
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WaterfallViewCell.reuseIdentifier, for: indexPath) as? WaterfallViewCell else {
            fatalError()
        }
        let cities: [String] = ["Shanghai", "Chongqing", "New York", "San Francisco", "Tokyo", "Phuket", "Singapore", "Wuhan", "Shenzhen", "Los Angeles"]
        let colors: [UIColor] = [.red, .magenta, .brown, .blue, .purple, .blue, .cyan, .gray, .green, .yellow, .purple]
        cell.titleLabel.text = cities.randomElement()!
        cell.titleLabel.backgroundColor = colors.randomElement()!
        return cell
    }
}

extension ViewController: UICollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let randomHeights: [CGFloat] = [300, 400, 500, 600, 700, 800]
        return CGSize(width: 500, height: randomHeights.randomElement()!)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? WaterfallViewCell else { return }
        print("Selected city is \(selectedCell.titleLabel.text ?? "None").")
    }
}
