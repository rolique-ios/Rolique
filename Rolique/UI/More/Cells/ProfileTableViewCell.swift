//
//  ProfileTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var defaultOffset: CGFloat { return 20.0 }
  static var littleOffset: CGFloat { return 8.0 }
  static var userImageSize: CGFloat { return 60.0 }
}

final class ProfileTableViewCell: UITableViewCell {
  private lazy var userImageView = UIImageView()
  private lazy var stackView = UIStackView()
  private lazy var nameLabel = UILabel()
  private lazy var titleLabel = UILabel()
  private lazy var todayStatusLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = Colors.mainBackgroundColor
    self.selectionStyle = .none
    
    userImageView.roundCorner(radius: Constants.userImageSize / 2)
    
    nameLabel.textColor = Colors.mainTextColor
    
    titleLabel.textColor = .lightGray
    titleLabel.font = .italicSystemFont(ofSize: 14.0)
    
    stackView.axis = .vertical
    stackView.spacing = 5.0
    
    todayStatusLabel.textColor = .orange
    todayStatusLabel.layer.borderWidth = 1.0
    todayStatusLabel.layer.borderColor = UIColor.orange.cgColor
    todayStatusLabel.layer.cornerRadius = 4
    todayStatusLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    todayStatusLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with name: String, userImage: String?, todayStatus: String?, title: String) {
    URL(string: userImage.orEmpty).map(self.userImageView.setImage(with: ))
    
    nameLabel.text = name

    titleLabel.text = title
    titleLabel.isHidden = title.isEmpty

    let todayStatusIsEmpty = todayStatus.orEmpty.isEmpty
    todayStatusLabel.isHidden = todayStatusIsEmpty
    todayStatusLabel.text = todayStatusIsEmpty ? nil : " " + todayStatus.orEmpty + " "
  }
  
  private func configureViews() {
    [userImageView, stackView, todayStatusLabel].forEach(self.addSubviewAndDisableMaskTranslate)
    stackView.addArrangedSubview(nameLabel)
    stackView.addArrangedSubview(titleLabel)
    
    userImageView.snp.makeConstraints { maker in
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.centerY.equalToSuperview()
      maker.size.equalTo(Constants.userImageSize)
    }
    
    stackView.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.leading.equalTo(userImageView.snp.trailing).offset(Constants.littleOffset)
      maker.trailing.equalTo(todayStatusLabel.snp.leading).offset(-Constants.littleOffset)
    }
    
    todayStatusLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(stackView.snp.trailing).offset(Constants.littleOffset)
      maker.centerY.equalToSuperview()
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.cancelLoad()
  }
}
