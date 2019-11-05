//
//  ArrayDiff.swift
//  Utils
//
//  Created by Maksym Ivanyk on 10/31/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public func arrayDiff<T1, T2>(_ first: [T1], _ second: [T2], with compare: (T1, T2) -> Bool) -> ArryDiff<T1, T2> {
  let combinations = first.compactMap { firstElement in (firstElement, second.first { secondElement in compare(firstElement, secondElement) }) }
  let common = combinations.filter { $0.1 != nil }.map { ($0.0, $0.1!) }
  let removed = combinations.filter { $0.1 == nil }.map { ($0.0) }
  let inserted = second.filter { secondElement in !common.contains { compare($0.0, secondElement) } }
  
  return ArryDiff(common: common, removed: removed, inserted: inserted)
}

public struct ArryDiff<T1, T2> {
  public let common: [(T1, T2)]
  public let removed: [T1]
  public let inserted: [T2]
  public init(common: [(T1, T2)] = [], removed: [T1] = [], inserted: [T2] = []) {
    self.common = common
    self.removed = removed
    self.inserted = inserted
  }
}

public struct ArryChanges<T1, T2> {
  public var diff: ArryDiff<T1, T2>
  public var first: [T1]
  public var second: [T2]
  
  public init(_ first: [T1], _ second: [T2], with compare: (T1, T2) -> Bool) {
    self.first = first
    self.second = second
    self.diff = arrayDiff(first, second, with: compare)
  }
}

public typealias Diff<T> = ArryDiff<T, T>
