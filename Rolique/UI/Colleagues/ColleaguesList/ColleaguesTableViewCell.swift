//
//  ColleaguesTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

protocol ColleaguesTableViewCellDelegate: class {
  func touchPhone(_ cell: ColleaguesTableViewCell)
}

final class ColleaguesTableViewCell: UITableViewCell {
  private struct Constants {
    static var defaultOffset: CGFloat { return 15.0 }
    static var littleOffset: CGFloat { return 8.0 }
    static var containerViewInsets: UIEdgeInsets { return UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10) }
    static var phoneImageSize: CGFloat { return 30.0 }
    static var userImageSize: CGFloat { return 60.0 }
  }
  private lazy var containerView = UIView()
  private lazy var userImageView = InteractiveImageView()
  private lazy var stackView = UIStackView()
  private lazy var nameLabel = UILabel()
  private lazy var titleLabel = UILabel()
  private lazy var todayStatusLabel = UILabel()
  private lazy var phoneImageView = UIImageView()
  
  weak var delegate: ColleaguesTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    containerView.backgroundColor = Colors.secondaryBackgroundColor
    containerView.layer.cornerRadius = 5.0
    
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
  
  func configure(with name: String, userImage: String?, todayStatus: String?, title: String, isButtonEnabled: Bool, isMe: Bool) {
    containerView.setShadow()
    
    URL(string: userImage.orEmpty).map(self.userImageView.setImage(with: ))
    
    nameLabel.text = name

    titleLabel.text = title
    titleLabel.isHidden = title.isEmpty

    let todayStatusIsEmpty = todayStatus.orEmpty.isEmpty
    todayStatusLabel.isHidden = todayStatusIsEmpty
    todayStatusLabel.text = todayStatusIsEmpty ? nil : " " + todayStatus.orEmpty + " "

    if isMe {
      phoneImageView.isHidden = true
    } else {
      phoneImageView.isHidden = false
      let image = Images.Colleagues.phone
      
      let gesture = UITapGestureRecognizer(target: self, action: #selector(touchEvent))
      if !isButtonEnabled {
        phoneImageView.removeGestureRecognizer(gesture)
        phoneImageView.image = image.withRenderingMode(.alwaysTemplate)
        phoneImageView.tintColor = .lightGray
      } else {
        phoneImageView.addGestureRecognizer(gesture)
        phoneImageView.isUserInteractionEnabled = true
        phoneImageView.image = image
      }
    }
  }
  
  private func configureViews() {
    [containerView].forEach(self.addSubviewAndDisableMaskTranslate)
    [userImageView, stackView, todayStatusLabel, phoneImageView].forEach(self.containerView.addSubviewAndDisableMaskTranslate)
    stackView.addArrangedSubview(nameLabel)
    stackView.addArrangedSubview(titleLabel)
    
    containerView.snp.makeConstraints { maker in
      maker.edges.equalTo(self).inset(Constants.containerViewInsets)
    }
    
    userImageView.snp.makeConstraints { maker in
      maker.leading.equalTo(containerView).offset(Constants.defaultOffset)
      maker.centerY.equalTo(containerView)
      maker.size.equalTo(Constants.userImageSize)
    }
    
    stackView.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.leading.equalTo(userImageView.snp.trailing).offset(Constants.littleOffset)
      maker.trailing.equalTo(todayStatusLabel.snp.leading).offset(-Constants.littleOffset)
    }
    
    todayStatusLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(stackView.snp.trailing).offset(Constants.littleOffset)
      maker.centerY.equalTo(phoneImageView)
      maker.trailing.equalTo(phoneImageView.snp.leading).offset(-Constants.littleOffset)
    }
    
    phoneImageView.snp.makeConstraints { maker in
      maker.trailing.equalTo(containerView).offset(-Constants.defaultOffset)
      maker.centerY.equalTo(containerView)
      maker.size.equalTo(Constants.phoneImageSize)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.cancelLoad()
  }
  
  @objc func touchEvent() {
    delegate?.touchPhone(self)
  }
}
