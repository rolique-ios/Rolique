//
//  CalendarCollectionViewFlowLayout.swift
//  Rolique
//
//  Created by Maks on 10/22/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class CalendarCollectionViewFlowLayout: UICollectionViewFlowLayout {

  private var stickySectionsCount = 0
  private var stickyRowsCount = 0
  private(set) var itemWidth: CGFloat = 100
  private(set) var itemHeight: CGFloat = 100
  
  private var currentIndex = 0
  private var previousContentOffset = CGPoint.zero
  
  func configure(with stickySectionsCount: Int, stickyRowsCount: Int, defaultItemWidth: CGFloat, defaultItemHeight: CGFloat) {
    self.stickySectionsCount = stickySectionsCount
    self.stickyRowsCount = stickyRowsCount
    
    itemWidth = defaultItemWidth
    itemHeight = defaultItemHeight
    
    invalidateLayout()
  }
  
  func updateItemWidth(width: CGFloat) {
    itemWidth = width
    invalidateLayout()
  }
  
  func updateItemHeight(height: CGFloat) {
    itemHeight = height
    invalidateLayout()
  }
  
  let weekdayItemHeight: CGFloat = 25.0
  let stickySectionHeight: CGFloat = 40.0
  let stickyRowWidth: CGFloat = 60.0

  // MARK: - Collection view flow layout methods
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }

  override var collectionViewContentSize: CGSize {
    let contentWidth = CGFloat(rowsCount(in: 0) - stickyRowsCount) * itemWidth + CGFloat(stickyRowsCount) * stickyRowWidth
    let contentHeight = CGFloat(sectionsCount - stickySectionsCount) * itemHeight + CGFloat(stickySectionsCount) * stickySectionHeight
    return CGSize(width: contentWidth, height: contentHeight)
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let insertByDx: CGFloat = previousContentOffset.x != collectionView!.contentOffset.x ? -512 : 0
    let insertByDy: CGFloat = previousContentOffset.y != collectionView!.contentOffset.y ? -512 : 0
    previousContentOffset = collectionView!.contentOffset
    
    let biggerRect = rect.insetBy(dx: insertByDx, dy: insertByDy)
    
    let withoutStickySectionsOriginY = biggerRect.origin.y - (CGFloat(stickySectionsCount) * stickySectionHeight)
    var startIndexY = Int(withoutStickySectionsOriginY / itemHeight)
    startIndexY = startIndexY > 0 ? startIndexY + stickySectionsCount : 0
    
    let withoutStickyRowsOriginX = biggerRect.origin.x - (CGFloat(stickyRowsCount) * stickyRowWidth)
    var startIndexX = Int(withoutStickyRowsOriginX / itemWidth)
    startIndexX = startIndexX > 0 ? startIndexX + stickyRowsCount : 0
    
    let withoutStickySectionsHeight = biggerRect.height - (CGFloat(stickySectionsCount) * stickySectionHeight)
    let numberOfVisibleCellsInRectY = Int((withoutStickySectionsHeight / itemHeight + CGFloat(stickySectionsCount)).rounded(.up)) + startIndexY
    let withoutStickyRowsWidth = biggerRect.width - (CGFloat(stickyRowsCount) * stickyRowWidth)
    let numberOfVisibleCellsInRectX = Int((withoutStickyRowsWidth / itemWidth + CGFloat(stickyRowsCount)).rounded(.up)) + startIndexX
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    for section in startIndexY..<numberOfVisibleCellsInRectY where section >= 0 && section < sectionsCount {
      for item in startIndexX..<numberOfVisibleCellsInRectX where item >= 0 && item < rowsCount(in: 0) {
        if startIndexY >= stickySectionsCount && startIndexX >= stickyRowsCount {
          let cellIndex = IndexPath(item: item - startIndexX, section: section - startIndexY)
          if let attrs = self.layoutAttributesForItem(at: cellIndex) {
            layoutAttributes.append(attrs)
          }
        }
        
        if startIndexY >= stickySectionsCount {
          let cellIndex = IndexPath(item: item, section: section - startIndexY)
          if let attrs = self.layoutAttributesForItem(at: cellIndex) {
            layoutAttributes.append(attrs)
          }
        }
        
        if startIndexX >= stickyRowsCount {
          let cellIndex = IndexPath(item: item - startIndexX, section: section)
          if let attrs = self.layoutAttributesForItem(at: cellIndex) {
            layoutAttributes.append(attrs)
          }
        }
        
        let cellIndex = IndexPath(item: item, section: section)
        if let attrs = self.layoutAttributesForItem(at: cellIndex) {
          layoutAttributes.append(attrs)
        }
      }
    }
    
    return layoutAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let width: CGFloat
    let xPos: CGFloat
    if indexPath.row < stickyRowsCount {
      width = stickyRowWidth
      xPos = CGFloat(indexPath.row) * width
    } else {
      width = itemWidth
      xPos = CGFloat(indexPath.row - stickyRowsCount) * width + CGFloat(stickyRowsCount) * stickyRowWidth
    }
    
    let height: CGFloat
    let yPos: CGFloat
    if indexPath.section < stickySectionsCount {
      height = stickySectionHeight
      yPos = CGFloat(indexPath.section) * height
    } else {
      height = itemHeight
      yPos = CGFloat(indexPath.section - stickySectionsCount) * height + CGFloat(stickySectionsCount) * stickySectionHeight
    }
    
    let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    cellAttributes.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
    
    if indexPath.section < stickySectionsCount {
      var frame = cellAttributes.frame
      frame.origin.y += collectionView!.contentOffset.y
      cellAttributes.frame = frame
    }
    
    if indexPath.row < stickyRowsCount {
      var frame = cellAttributes.frame
      frame.origin.x += collectionView!.contentOffset.x
      cellAttributes.frame = frame
    }
    
    cellAttributes.zIndex = zIndex(for: indexPath.section, row: indexPath.row)
    
    return cellAttributes
  }
  
  // MARK: - Helpers

  private func zIndex(for section: Int, row: Int) -> Int {
    if section < stickySectionsCount && row < stickyRowsCount {
      return ZOrder.staticStickyItem
    } else if section < stickySectionsCount {
      return ZOrder.horizontalStickyItem
    } else if row < stickyRowsCount {
      return ZOrder.verticalStickyItem
    } else {
      return ZOrder.commonItem
    }
  }
  
  // MARK: - Sizing

  private var sectionsCount: Int {
    return collectionView!.numberOfSections
  }

  private func rowsCount(in row: Int) -> Int {
    return collectionView!.numberOfItems(inSection: row)
  }
}

// MARK: - ZOrder

private enum ZOrder {
  static let commonItem = 0
  static let verticalStickyItem = 1
  static let horizontalStickyItem = 2
  static let staticStickyItem = 3
}
