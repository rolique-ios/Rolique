//
//  CashHistoryViewModel.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Networking
import Utils

private struct Constants {
  static var daysStep: Int { 30 }
}

protocol CashHistoryViewModel: ViewModel {
  var dates: [Date] { get }
  var balance: Balance { get }
  var cashOwner: CashOwner { get }
  var isLoadingNextPage: Bool { get }
  var shouldChangeLoadingVisibility: Completion? { get set }
  var shouldReloadData: Completion? { get set }
  var onError: ((String) -> Void)? { get set }

  func getExpenses(for section: Int) -> [Expense]
  func scrolledToBottom()
}

final class CashHistoryViewModelImpl: BaseViewModel, CashHistoryViewModel {
  var dates: [Date] {
    return Array(datesExpenses.keys)
  }
  private lazy var datesExpenses: [Date: [Expense]] = [:]
  private(set) lazy var isLoadingNextPage = false
  private lazy var dateFormatter = DateFormatters.dateFormatter
  private lazy var fetchedAll = false
  let balance: Balance
  let cashOwner: CashOwner
  var shouldChangeLoadingVisibility: Completion?
  var shouldReloadData: Completion?
  var onError: ((String) -> Void)?
  private lazy var endDate = Date()
  private lazy var startDate = Date(timeInterval: -TimeInterval.day * Double(Constants.daysStep), since: Date())
  
  init(balance: Balance, cashOwner: CashOwner) {
    self.balance = balance
    self.cashOwner = cashOwner
    
    super.init()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scrolledToBottom()
  }

  func getExpenses(for section: Int) -> [Expense] {
    datesExpenses[dates[section]] ?? []
  }
  
  func scrolledToBottom() {
    if isLoadingNextPage || fetchedAll {
      return
    }
    
    print("loading next")
    isLoadingNextPage = true
    shouldChangeLoadingVisibility?()
    
    let startDateString = dateFormatter.string(from: startDate)
    let endDateString = dateFormatter.string(from: endDate)
    Net.Worker.request(GetPayments(cashOwner: cashOwner.apiName, startDate: startDateString, endDate: endDateString), onSuccess: { [weak self] json in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        let total = (json.dict()?["total_count"] as? Int) ?? -1
        
        let expenses: [Expense] = json.buildArray() ?? []
        self.endDate = self.startDate
        self.startDate = Date(timeInterval: TimeInterval.day * -Double(Constants.daysStep), since: self.endDate)
        let datesExpenses = self.normalizeExpenses(expenses)
        self.normalizeExpenses(expenses).keys.forEach { date in
          self.datesExpenses[date, default: []].append(contentsOf: datesExpenses[date] ?? [])
        }
        
        self.isLoadingNextPage = false
        self.fetchedAll = total == self.datesExpenses.values
          .map { $0.count }
          .reduce(0, +)
        self.shouldReloadData?()
      }
    }, onError: { [weak self] error in
      DispatchQueue.main.async {
        self?.onError?(error.localizedDescription)
        self?.isLoadingNextPage = false
        self?.shouldChangeLoadingVisibility?()
      }
    })
  }
}

// MARK: - Private
private extension CashHistoryViewModel {
  func normalizeExpenses(_ expenses: [Expense]) -> [Date: [Expense]] {
    var normalizationDictionary = [Date: [Expense]]()
    
    for expense in expenses {
      guard let date = expense.date?.normalized else { continue }
      
      normalizationDictionary[date, default: []].append(expense)
    }
    
    return normalizationDictionary
  }
}
