//
//  DemoWaterfallCell.swift
//  Demo
//
//  Created by Jinya on 2021/11/2.
//

import UIKit

class DemoWaterfallCell: UICollectionViewCell {
    
    var name: String = "bicycle" {
        didSet {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(systemName: self.name)
            }
        }
    }
    private lazy var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: name)
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.gray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
