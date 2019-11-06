//
//  UICollectionView.swift
//  Spyfall
//
//  Created by bbb on 9/15/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

public extension UICollectionView {
    func setDelegateAndDatasource(_ object: UICollectionViewDelegate & UICollectionViewDataSource) {
        self.delegate = object
        self.dataSource = object
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return self.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func dequeue<T: UICollectionViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: String(describing: type.self), for: indexPath) as! T
    }
    
    func register(_ cells: [UICollectionViewCell.Type]) {
        cells.forEach {
            let cellName = String(describing: $0)
            register($0, forCellWithReuseIdentifier: cellName)
        }
    }
}
