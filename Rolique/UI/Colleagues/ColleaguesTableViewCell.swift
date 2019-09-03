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

class ColleaguesTableViewCell: UITableViewCell {
  private struct Constants {
    static var defaultOffset: CGFloat { return 15.0 }
    static var littleOffset: CGFloat { return 8.0 }
    static var containerViewInsets: UIEdgeInsets { return UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10) }
    static var phoneImageSize: CGFloat { return 30.0 }
    static var userImageSize: CGFloat { return 60.0 }
  }
  private lazy var containerView = ShadowView()
  private lazy var userImageView = UIImageView()
  private lazy var nameLabel = UILabel()
  private lazy var titleLabel = UILabel()
  private lazy var todayStatusLabel = UILabel()
  private lazy var phoneImageView = UIImageView()
  
  weak var delegate: ColleaguesTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .white
    
    userImageView.translatesAutoresizingMaskIntoConstraints = false
    userImageView.layer.cornerRadius = Constants.userImageSize / 2
    userImageView.clipsToBounds = true
    
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.textColor = UIColor.black
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.textColor = UIColor.lightGray
    titleLabel.font = UIFont.italicSystemFont(ofSize: 14.0)
    
    todayStatusLabel.translatesAutoresizingMaskIntoConstraints = false
    todayStatusLabel.textColor = .orange
    todayStatusLabel.layer.borderWidth = 1.0
     todayStatusLabel.layer.borderColor = UIColor.orange.cgColor
    todayStatusLabel.layer.cornerRadius = 4
    todayStatusLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    
    phoneImageView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with user: User) {
    configureViews()
    
    if let optimalImage = user.optimalImage, let url = URL(string: optimalImage) {
      self.userImageView.setImage(with: url)
    }
    
    nameLabel.text = user.slackProfile.realName
    if let todayStatus = user.todayStatus, !todayStatus.isEmpty {
      todayStatusLabel.isHidden = false
      todayStatusLabel.text = " " + todayStatus + " "
    } else {
      todayStatusLabel.isHidden = true
      todayStatusLabel.text = nil
    }
    
    if !user.slackProfile.title.isEmpty {
      titleLabel.text = user.slackProfile.title
    } else {
      titleLabel.removeFromSuperview()
      nameLabel.snp.remakeConstraints { maker in
        maker.leading.equalTo(userImageView.snp.trailing).offset(Constants.littleOffset)
        maker.centerY.equalTo(containerView)
      }
    }
    
    if user.id == UserDefaultsManager.shared.userId {
      phoneImageView.isHidden = true
    } else {
      phoneImageView.isHidden = false
      let image = Images.Colleagues.phone
      
      let isPhoneAbsent = user.slackProfile.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      if isPhoneAbsent {
        phoneImageView.image = image.withRenderingMode(.alwaysTemplate)
        phoneImageView.tintColor = .lightGray
      } else {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchEvent))
        phoneImageView.addGestureRecognizer(gesture)
        phoneImageView.isUserInteractionEnabled = true
        phoneImageView.image = image
      }
    }
  }
  
  private func configureViews() {
    self.addSubview(containerView)
    containerView.addSubview(userImageView)
    containerView.addSubview(nameLabel)
    containerView.addSubview(titleLabel)
    containerView.addSubview(phoneImageView)
    containerView.addSubview(todayStatusLabel)
    
    containerView.snp.makeConstraints { maker in
      maker.edges.equalTo(self).inset(Constants.containerViewInsets)
    }
    
    userImageView.snp.makeConstraints { maker in
      maker.leading.equalTo(containerView).offset(Constants.defaultOffset)
      maker.centerY.equalTo(containerView)
      maker.size.equalTo(Constants.userImageSize)
    }
    
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(userImageView.snp.trailing).offset(Constants.littleOffset)
      maker.bottom.equalTo(containerView).offset(-Constants.defaultOffset)
    }
    
    nameLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(userImageView.snp.trailing).offset(Constants.littleOffset)
      maker.top.equalTo(containerView).offset(Constants.defaultOffset)
    }
    
    todayStatusLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(nameLabel.snp.trailing).offset(Constants.littleOffset)
      maker.leading.equalTo(titleLabel.snp.trailing).offset(Constants.littleOffset)
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
    
    containerView.removeFromSuperview()
    userImageView.cancelLoad()
    userImageView.removeFromSuperview()
    nameLabel.removeFromSuperview()
    titleLabel.removeFromSuperview()
    todayStatusLabel.removeFromSuperview()
    phoneImageView.removeFromSuperview()
  }
  
  @objc func touchEvent() {
    delegate?.touchPhone(self)
  }
}
