//
//  DaysCollectionViewFlowLayout.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

private struct Constants {
  static var weekdayCellHeigth: CGFloat { return 20.0 }
  static var dayCellHeigth: CGFloat { return 40.0 }
  static var pageItems: Int { return 7 }
  static var weeksInMonth: Int { return 5 }
}

final class DaysCollectionViewFlowLayout: UICollectionViewFlowLayout {
  private(set) var itemWidth: CGFloat = 100
  private(set) var itemHeight: CGFloat = 100
  
  private var cachedAttributes = [[UICollectionViewLayoutAttributes]]()
  private var sixMonthOffset: CGFloat {
    return CGFloat(Constants.pageItems * 6 * Constants.weeksInMonth) * itemWidth
  }

  private var previousLeftBoundX = 0
  private var previousRightBoundX = 0
  
  func configure(itemWidth: CGFloat, itemHeight: CGFloat) {
    self.itemWidth = itemWidth
    self.itemHeight = itemWidth
    
    self.minimumLineSpacing = 0.0
    self.minimumInteritemSpacing = 0.0
    
    reloadCache()
    invalidateLayout()
  }
  
  func updateItemWidth(width: CGFloat) {
    itemWidth = width
    
    reloadCache()
    invalidateLayout()
  }

  // MARK: - Collection view flow layout methods
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return cachedAttributes.count > 0 ? !(cachedAttributes[0][0].frame.origin.x < newBounds.origin.x && cachedAttributes[0][cachedAttributes[0].count - 1].frame.origin.x - newBounds.width > newBounds.origin.x) : true
  }

  override var collectionViewContentSize: CGSize {
    let contentWidth = CGFloat(rowsCount(in: 0)) * itemWidth
    let contentHeight = Constants.weekdayCellHeigth + Constants.dayCellHeigth
    return CGSize(width: contentWidth, height: contentHeight)
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var startIndexY = Int(rect.origin.y / (Constants.weekdayCellHeigth + Constants.dayCellHeigth))
    startIndexY = startIndexY < 0 ? 0 : startIndexY
    var startIndexX = Int(rect.origin.x / itemWidth)
    startIndexX = startIndexX < 0 ? 0 : startIndexX
    
    var numberOfVisibleCellsInRectY = Int((rect.height / (Constants.weekdayCellHeigth + Constants.dayCellHeigth)).rounded(.up)) + startIndexY
    
    var numberOfVisibleCellsInRectX = Int((rect.width / itemWidth).rounded(.up)) + startIndexX
    
    numberOfVisibleCellsInRectY = numberOfVisibleCellsInRectY > sectionsCount ? sectionsCount : numberOfVisibleCellsInRectY
    numberOfVisibleCellsInRectX = numberOfVisibleCellsInRectX > rowsCount(in: 0) ? rowsCount(in: 0) : numberOfVisibleCellsInRectX
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    if cachedAttributes.count >= numberOfVisibleCellsInRectY {
      for rowAttrs in cachedAttributes[startIndexY..<numberOfVisibleCellsInRectY] {
        for itemAttrs in rowAttrs where rect.intersects(itemAttrs.frame) {
          layoutAttributes.append(itemAttrs)
        }
      }
    }
    
    return layoutAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let width = itemWidth
    let xPos = CGFloat(indexPath.row) * width
    
    let height: CGFloat
    let yPos: CGFloat
    if indexPath.section < 1 {
      height = Constants.weekdayCellHeigth
      yPos = CGFloat(indexPath.section) * height
    } else {
      height = Constants.dayCellHeigth
      yPos = CGFloat(indexPath.section - 1) * height + Constants.weekdayCellHeigth
    }
    
    let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    cellAttributes.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
    
    return cellAttributes
  }
  
  override func prepare() {
    super.prepare()
    loadCache()
  }
  
  func reloadCache() {
    previousLeftBoundX = 0
    previousRightBoundX = 0
    cachedAttributes.removeAll()
    loadCache()
  }
  
  private func loadCache() {
    if cachedAttributes.count == sectionsCount {
      cachedAttributes.count > 0 &&
      !(cachedAttributes[0][0].frame.origin.x < collectionView!.contentOffset.x && cachedAttributes[0][cachedAttributes[0].count - 1].frame.origin.x - collectionView!.frame.width > collectionView!.contentOffset.x) ? updateCache() : nil
    } else {
      calculateCache()
    }
  }
  
  private func calculateCache() {
    let leftBoundX = collectionView!.contentOffset.x - sixMonthOffset
    let rightBoundX = collectionView!.contentOffset.x + sixMonthOffset
    
    var leftBoundIndexX = Int(leftBoundX / itemWidth)
    leftBoundIndexX = leftBoundIndexX < 0 ? 0 : leftBoundIndexX
    var rightBoundIndexX = Int(rightBoundX / itemWidth)
    rightBoundIndexX = rightBoundIndexX > rowsCount(in: 0) ? rowsCount(in: 0) : rightBoundIndexX
    
    guard previousLeftBoundX != leftBoundIndexX && previousRightBoundX != rightBoundIndexX else { return }
    
    var section = 0
    var item = 0
    while section < sectionsCount {
      var rowAttrs: [UICollectionViewLayoutAttributes] = []
      item = leftBoundIndexX
      while item < rightBoundIndexX {
        let cellIndex = IndexPath(item: item, section: section)
        if let attrs = self.layoutAttributesForItem(at: cellIndex) {
          rowAttrs.append(attrs)
        }
        
        item += 1
      }
      
      cachedAttributes.append(rowAttrs)
      section += 1
    }
    
    previousLeftBoundX = leftBoundIndexX
    previousRightBoundX = rightBoundIndexX
  }
  
  private func updateCache() {
    let leftBoundX = collectionView!.contentOffset.x - sixMonthOffset
    let rightBoundX = collectionView!.contentOffset.x + sixMonthOffset
    
    var leftBoundIndexX = Int(leftBoundX / itemWidth)
    leftBoundIndexX = leftBoundIndexX < 0 ? 0 : leftBoundIndexX
    var rightBoundIndexX = Int(rightBoundX / itemWidth)
    rightBoundIndexX = rightBoundIndexX > rowsCount(in: 0) ? rowsCount(in: 0) : rightBoundIndexX
    
    guard previousLeftBoundX != leftBoundIndexX && previousRightBoundX != rightBoundIndexX else { return }
    
    let removeRange = cachedAttributes[0].count / 2
    
    var section = 0
    var item = 0
    
    while section < sectionsCount {
      var cachedRows = cachedAttributes[section]
      
      let itemsCount: Int
      if leftBoundIndexX < previousLeftBoundX {
        item = leftBoundIndexX
        cachedRows.removeSubrange(cachedRows.count - removeRange..<cachedRows.count)
        itemsCount = leftBoundIndexX + (cachedRows[0].indexPath.row - leftBoundIndexX)
      } else {
        item = previousRightBoundX
        cachedRows.removeSubrange(0..<removeRange)
        itemsCount = previousRightBoundX + removeRange
      }

      while item < itemsCount {
        let cellIndex = IndexPath(item: item, section: section)
        if leftBoundIndexX < previousLeftBoundX {
          if let attrs = self.layoutAttributesForItem(at: cellIndex) {
            cachedRows.insert(attrs, at: item - leftBoundIndexX)
          }
        } else {
          if let attrs = self.layoutAttributesForItem(at: cellIndex) {
            cachedRows.append(attrs)
          }
        }

        item += 1
      }
      
      cachedAttributes[section] = cachedRows
      section += 1
    }
    
    previousLeftBoundX = leftBoundIndexX
    previousRightBoundX = rightBoundIndexX
  }
  
  // MARK: - Sizing

  private var sectionsCount: Int {
    return collectionView!.numberOfSections
  }

  private func rowsCount(in row: Int) -> Int {
    return collectionView!.numberOfItems(inSection: row)
  }
}
