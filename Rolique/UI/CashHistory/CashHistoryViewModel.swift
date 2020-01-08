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
  var balance: Balance { get }
  var cashOwner: CashOwner { get }
  var isLoadingNextPage: Bool { get }
  var shouldChangeLoadingVisibility: Completion? { get set }

  func getExpenses(for section: Int) -> [Expense]
  func scrolledToBottom()
}

final class CashHistoryViewModelImpl: BaseViewModel, CashHistoryViewModel {
  private(set) var dates: [Date] = []
  private lazy var datesExpenses: [Date: [Expense]] = [:]
  private(set) lazy var isLoadingNextPage = false
  let balance: Balance
  let cashOwner: CashOwner
  var shouldChangeLoadingVisibility: Completion?
  
  init(balance: Balance, cashOwner: CashOwner) {
    self.balance = balance
    self.cashOwner = cashOwner
    
    super.init()
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
      guard let self = self else { return }
      self.isLoadingNextPage = false
      self.shouldChangeLoadingVisibility?()

    }
  }
}
