//
//  ActionsTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

class ActionsTableViewCell: UITableViewCell {
  private struct Constants {
    static var containerViewInsets: UIEdgeInsets { return UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10) }
  }
  private lazy var containerView = UIView()
  private lazy var titleLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .secondaryBackgroundColor()
    containerView.layer.cornerRadius = 5.0
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with action: ActionType) {
    configureViews()
    
    containerView.setShadow()
    
    titleLabel.text = action.rawValue.capitalized
  }
  
  private func configureViews() {
    self.addSubview(containerView)
    containerView.addSubview(titleLabel)
    
    containerView.snp.makeConstraints { maker in
      maker.edges.equalTo(self).inset(Constants.containerViewInsets)
    }
    
    titleLabel.snp.makeConstraints { maker in
      maker.center.equalTo(containerView)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    containerView.removeFromSuperview()
    containerView.removeShadow()
    titleLabel.removeFromSuperview()
  }
}
