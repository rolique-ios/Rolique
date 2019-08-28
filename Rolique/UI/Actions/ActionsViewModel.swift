//
//  ActionsViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Utils

protocol ActionsViewModel: ViewModel {
  var onResponse: ((String) -> Void)? { get set }
  func pochav()
  func doprac(type: DopracType)
}

final class ActionsViewModelImpl: BaseViewModel, ActionsViewModel {
  var onResponse: ((String) -> Void)?
  
  let actionManager: ActionManger
  init(actionManager: ActionManger) {
    self.actionManager = actionManager
  }
  
  func pochav() {
    let action = ActionPochav(sender: UserDefaultsManager.shared.userId ?? "")
    sendRequest(with: action)
  }
  
  func doprac(type: DopracType) {
    let action: ActionDoprac
    switch type {
    case .now:
      action = ActionDoprac(sender: UserDefaultsManager.shared.userId ?? "", value: type.description)
    case .hour(let date):
      if let date = date {
        action = ActionDoprac(sender: UserDefaultsManager.shared.userId ?? "", value: type.description, custom: dateFormatter.string(from: date))
      } else {
        action = ActionDoprac(sender: UserDefaultsManager.shared.userId ?? "", value: type.description)
      }
    }
    
    sendRequest(with: action)
  }
  
  private func sendRequest(with action: Action) {
    actionManager.sendAction(action) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let actionResult):
        let text: String
        if let error = actionResult.error {
          text = error
        } else {
          text = "Successfully sent"
        }
        self.onResponse?(text)
      case .failure(let error):
        self.onResponse?(error.localizedDescription)
      }
    }
  }
  
  private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter
  }()
}

