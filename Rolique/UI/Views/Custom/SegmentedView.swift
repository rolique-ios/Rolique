//
//  SegmentedView.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/22/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class SegmentedView: UIView {
  struct Constants {
    static let originXOffSet: CGFloat = 5.0
    static let minusWidth: CGFloat = 10.0
  }
  
  var selectedSegmentIndex = -1 {
    didSet {
      if selectedSegmentIndex != oldValue {
        changeIndexIndicator(index: selectedSegmentIndex)
        selectedSegmentDidChanged?(selectedSegmentIndex)
      }
    }
  }
  var selectedSegmentDidChanged: ((Int) -> Void)?
  var indicator: UIView?
  var viewCount: Int?
  var indicatorHeight: CGFloat = 1.0
  
  func configure(with titles: [String], titleColor: UIColor, indicatorHeight: CGFloat, indicatorColor: UIColor) {
    self.viewCount = titles.count
    self.indicatorHeight = indicatorHeight
    let segmentWidth = self.bounds.width / CGFloat(titles.count)
    for (index, text) in titles.enumerated() {
      let segment = UIView()
      segment.frame = CGRect(origin: CGPoint(x: CGFloat(index) * segmentWidth, y: 0.0), size: CGSize(width: segmentWidth, height: self.bounds.height))
      segment.tag = index
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wasChangedSegment(_:)))
      segment.addGestureRecognizer(tapGestureRecognizer)
      segment.isUserInteractionEnabled = true
      let label = UILabel()
      label.text = text
      label.textAlignment = .center
      label.frame = segment.bounds
      label.textColor = titleColor
      segment.addSubview(label)
      self.addSubview(segment)
    }
    let indicator = UIView()
    indicator.frame = CGRect(origin: CGPoint(x: Constants.originXOffSet, y: self.bounds.height - Constants.originXOffSet), size: CGSize(width: segmentWidth - Constants.minusWidth, height: indicatorHeight))
    indicator.backgroundColor = indicatorColor
    indicator.layer.cornerRadius = indicatorHeight / 2
    self.indicator = indicator
    self.addSubview(indicator)
  }
  
  @objc func wasChangedSegment(_ sender: UITapGestureRecognizer) {
    guard let view = sender.view else { return }
    
    selectedSegmentIndex = view.tag
  }
  
  func changeIndexIndicator(index: Int) {
    let segmentWidth = self.bounds.width / CGFloat(viewCount ?? 0)
    
    UIView.animate(withDuration: 0.2) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.indicator?.frame = CGRect(origin: CGPoint(x: Constants.originXOffSet + CGFloat(index) * segmentWidth,
                                                           y: strongSelf.bounds.height - Constants.originXOffSet),
                                           size: CGSize(width: segmentWidth - Constants.minusWidth, height: strongSelf.indicatorHeight))
    }
  }
}
