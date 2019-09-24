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
  func remote(type: RemoteType)
  func late(type: LateType)
  func openSlackForBot()
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
    case .now, .hour:
      action = ActionDoprac(sender: UserDefaultsManager.shared.userId ?? "", value: type.param)
    case .custom(let date):
      action = ActionDoprac(sender: UserDefaultsManager.shared.userId ?? "", value: type.param, custom: DateFormatters.dopracDateFormatter.string(from: date))
    }
    
    sendRequest(with: action)
  }
  
  func remote(type: RemoteType) {
    let action: ActionRemote
    switch type {
    case .today, .tommorow:
      action = ActionRemote(sender: UserDefaultsManager.shared.userId ?? "", value: type.param)
    case .custom(let start, let end):
      action = ActionRemote(sender: UserDefaultsManager.shared.userId ?? "",
                            value: type.param,
                            startDate: DateFormatters.remoteDateFormatter.string(from: start),
                            endDate: DateFormatters.remoteDateFormatter.string(from: end))
    }
    
    sendRequest(with: action)
  }
  
  func late(type: LateType) {
    let action: ActionLate
    switch type {
    case .in30minutes(let from):
      action = ActionLate(sender: UserDefaultsManager.shared.userId ?? "", from: from.param, value: type.param)
    case .in1hour(let from):
      action = ActionLate(sender: UserDefaultsManager.shared.userId ?? "", from: from.param, value: type.param)
    case .choosen(let from, _):
      action = ActionLate(sender: UserDefaultsManager.shared.userId ?? "", from: from.param, value: type.param)
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
  
  func openSlackForBot() {
    let urlString = "slack://user?team=\(UserDefaultsManager.shared.teamId ?? "no-team-id")&id=\(UserDefaultsManager.shared.botId ?? "no-bot-id")"
    guard let url = URL(string: urlString) ,UIApplication.shared.canOpenURL(url) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}

