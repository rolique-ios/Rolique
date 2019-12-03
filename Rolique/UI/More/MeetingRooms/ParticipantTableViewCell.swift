//
//  ParticipantTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/25/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var imageSize: CGFloat { return 32.0 }
  static var defaultOffset: CGFloat { return 20.0 }
  static var littleOffset: CGFloat { return 10.0 }
  static var removeButtonSize: CGFloat { return 14.0 }
}

final class ParticipantTableViewCell: UITableViewCell {
  private lazy var userImageView = UIImageView()
  private lazy var userNameLabel = UILabel()
  private lazy var removeButton = UIButton()
  
  var removeButtonOnTap: ((String?) -> Void)?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    removeButton.setImage(R.image.removeParticipant(), for: .normal)
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func update(fullName: String?, imageUrlString: String?, removeButtonOnTap: ((String?) -> Void)?) {
    URL(string: imageUrlString.orEmpty).map(self.userImageView.setImage(with: ))
    userNameLabel.text = fullName
    self.removeButtonOnTap = removeButtonOnTap
    removeButton.isHidden = removeButtonOnTap == nil
  }
  
  @objc func handleRemoveButtonOnTap(_ button: UIButton) {
    removeButtonOnTap?(userNameLabel.text)
  }
  
  private func configureViews() {
    [userImageView, userNameLabel, removeButton].forEach(addSubviewAndDisableMaskTranslate(_:))
    
    userImageView.snp.makeConstraints { maker in
      maker.size.equalTo(Constants.imageSize)
      maker.centerY.equalToSuperview()
      maker.left.equalToSuperview().offset(Constants.defaultOffset)
    }
    
    userNameLabel.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview()
      maker.left.equalTo(userImageView.snp.right).offset(Constants.littleOffset)
    }
    
    removeButton.snp.makeConstraints { maker in
      maker.size.equalTo(Constants.removeButtonSize)
      maker.left.equalTo(userNameLabel.snp.right).offset(Constants.littleOffset)
      maker.right.greaterThanOrEqualToSuperview().offset(-Constants.littleOffset)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    userImageView.cancelLoad()
  }
}
