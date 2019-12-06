//
//  ImageButton.swift
//  Coloretta
//
//  Created by Bohdan Savych on 11/18/19.
//  Copyright © 2019 Padres. All rights reserved.
//

import UIKit
import SnapKit

final class ImageButton: UIView {
    private(set) lazy var imageView = UIImageView()
    private lazy var button = UIButton()
    private lazy var insets = UIEdgeInsets.zero
    
    var onTap: (() -> Void)?
    
    init(insets: UIEdgeInsets) {
        super.init(frame: .zero)
        
        self.insets = insets
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    func configure() {
        [imageView, button].forEach(addSubview)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(self.insets.top)
            $0.bottom.equalToSuperview().inset(self.insets.bottom)
            $0.left.equalToSuperview().inset(self.insets.left)
            $0.right.equalToSuperview().inset(self.insets.right)
        }
        
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button.setTitle("", for: .normal)
        imageView.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
}

// MARK: - Actions
private extension ImageButton {
    @objc func buttonTouchUpInside(sender: UIButton) {
        onTap?()
    }
}
