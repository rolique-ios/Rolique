//
//  CashHistoryViewModel.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

protocol CashHistoryViewModel: ViewModel {
  var dates: [Date] { get }
  var isLoadingNextPage: Bool { get }
  var shouldChangeLoadingVisibility: Completion? { get set }

  func getExpenses(for section: Int) -> [Expense]
  func scrolledToBottom()
}

final class CashHistoryViewModelImpl: BaseViewModel, CashHistoryViewModel {
  private(set) var dates: [Date] = ExpenseDummer.getDates()
  private lazy var datesExpenses: [Date: [Expense]] = ExpenseDummer.getDatesExpenses()
  private(set) lazy var isLoadingNextPage = false
  var shouldChangeLoadingVisibility: Completion?

  func getExpenses(for section: Int) -> [Expense] {
    datesExpenses[dates[section]] ?? []
  }
  
  func scrolledToBottom() {
    if isLoadingNextPage {
      return
    }
    
    isLoadingNextPage = true
    shouldChangeLoadingVisibility?()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
      guard let self = self else { return }
      self.isLoadingNextPage = false
      self.shouldChangeLoadingVisibility?()

    }
  }
}

private final class ExpenseDummer {
  static func getDates() -> [Date] {
    return [Date().normalized, Date(timeInterval: -TimeInterval.day, since: Date()).normalized, Date(timeInterval: -TimeInterval.day * 2, since: Date()).normalized, Date(timeInterval: -TimeInterval.day * 3, since: Date()).normalized]
  }
  static func getDatesExpenses() -> [Date: [Expense]] {
    return [Date().normalized: [Expense(value: -140, date: Date(), description: "Chipsi lays"),
                     Expense(value: -33.434, date: Date(), description: "Tapochki"),
                     Expense(value: 33.434, date: Date(), description: "Trip to Egypt"),
                     Expense(value: 1403823.22, date: Date(), description: "Very long text just two test two lines, Very long text just two test two lines, Very long text just two test two lines")],
            
            Date(timeInterval: -TimeInterval.day, since: Date()).normalized: [Expense(value: -140, date: Date(timeInterval: -TimeInterval.day, since: Date()), description: "Chipsi lays"),
                                                                   Expense(value: -33.434, date: Date(timeInterval: -TimeInterval.day, since: Date()), description: "Tapochki"),
                                                                   Expense(value: 33.434, date: Date(timeInterval: -TimeInterval.day, since: Date()), description: "Trip to Egypt"),
                                                                   Expense(value: 1403823.22, date: Date(timeInterval: -TimeInterval.day, since: Date()), description: "Very long text just two test two lines, Very long text just two test two lines, Very long text just two test two lines")],
            
            Date(timeInterval: -2 * TimeInterval.day, since: Date()).normalized: [Expense(value: -140, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Chipsi lays"),
                                                                       Expense(value: -33.434, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Tapochki"),
                                                                       Expense(value: 33.434, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Trip to Egypt"),
                                                                       Expense(value: 1403823.22, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Very long text just two test two lines, Very long text just two test two lines, Very long text just two test two lines"),
                                                                       Expense(value: -140, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Chipsi lays"),
                                                                       Expense(value: -33.434, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Tapochki"),
                                                                       Expense(value: 33.434, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Trip to Egypt"),
                                                                       Expense(value: 1403823.22, date: Date(timeInterval: -2 * TimeInterval.day, since: Date()), description: "Very long text just two test two lines, Very long text just two test two lines, Very long text just two test two lines")],
    
            Date(timeInterval: -3 * TimeInterval.day, since: Date()).normalized: [Expense(value: -140, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Chipsi lays"),
                                                                       Expense(value: -33.434, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Tapochki"),
                                                                       Expense(value: 33.434, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Trip to Egypt"),
                                                                       Expense(value: 1403823.22, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Very long text just two test two lines, Very long text just two test two lines, Very long text just two test two lines"),
                                                                       Expense(value: -140, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Chipsi lays"),
                                                                       Expense(value: -33.434, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Tapochki"),
                                                                       Expense(value: 33.434, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Trip to Egypt"),
                                                                       Expense(value: 1403823.22, date: Date(timeInterval: -3 * TimeInterval.day, since: Date()), description: "Very long text just two test two lines, Very long text just two test two lines, Very long text just two test two lines")]]
  }
}
