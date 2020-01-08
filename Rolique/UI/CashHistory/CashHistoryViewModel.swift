//
//  CashHistoryViewModel.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Networking

private struct Constants {
  static var daysStep: Int { 30 }
}

protocol CashHistoryViewModel: ViewModel {
  var dates: [Date] { get }
  var balance: Balance { get }
  var cashOwner: CashOwner { get }
  var isLoadingNextPage: Bool { get }
  var shouldChangeLoadingVisibility: Completion? { get set }
  var onError: ((String) -> Void)? { get set }

  func getExpenses(for section: Int) -> [Expense]
  func scrolledToBottom()
}

final class CashHistoryViewModelImpl: BaseViewModel, CashHistoryViewModel {
  private(set) var dates: [Date] = []
  private lazy var datesExpenses: [Date: [Expense]] = [:]
  private(set) lazy var isLoadingNextPage = false
  private lazy var dateFormatter = DateFormatters.dateFormatter
  let balance: Balance
  let cashOwner: CashOwner
  var shouldChangeLoadingVisibility: Completion?
  var onError: ((String) -> Void)?
  private lazy var endDate = Date()
  private lazy var startDate = Date(timeInterval: TimeInterval.day * Double(Constants.daysStep), since: Date())
  
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
    if isLoadingNextPage {
      return
    }
    
    isLoadingNextPage = true
    shouldChangeLoadingVisibility?()
    
    let startDateString = dateFormatter.string(from: startDate)
    let endDateString = dateFormatter.string(from: endDate)
    Net.Worker.request(GetPayments(cashOwner: cashOwner.apiName, startDate: startDateString, endDate: endDateString), onSuccess: { [weak self] json in
      guard let self = self else { return }
      
      let expenses: [Expense] = json.buildArray() ?? []
      self.endDate = self.startDate
      self.startDate = Date(timeInterval: TimeInterval.day * -Double(Constants.daysStep), since: self.endDate)
      let datesExpenses = self.normalizeExpenses(expenses)
      self.normalizeExpenses(expenses).keys.forEach { date in
        self.datesExpenses[date, default: []].append(contentsOf: datesExpenses[date] ?? [])
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
        guard let self = self else { return }
        self.isLoadingNextPage = false
        self.shouldChangeLoadingVisibility?()
      }
    }, onError: { [weak self] error in
      self?.onError?(error.localizedDescription)
      self?.isLoadingNextPage = false
      self?.shouldChangeLoadingVisibility?()
    })
  }
}

// MARK: - Private
private extension CashHistoryViewModel {
  func normalizeExpenses(_ expenses: [Expense]) -> [Date: [Expense]] {
    var normalizationDictionary = [Date: [Expense]]()
    
    for expense in expenses {
      guard let date = expense.date else { continue }
      
      normalizationDictionary[date, default: []].append(expense)
    }
    
    return normalizationDictionary
  }
}
