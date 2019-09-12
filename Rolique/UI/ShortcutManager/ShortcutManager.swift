//
//  ShortcutManager.swift
//  UI
//
//  Created by Bohdan Savych on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Utils

public final class ShortcutManager {
  public enum Action: Int, CaseIterable {
    case dopracNow,
    late1hour,
    pochav,
    remoteTomorrow,
    sickToday
    
    var title: String {
      switch self {
      case .dopracNow:
        return "Doprac"
      case .remoteTomorrow:// .remoteTomorrow:
        return "Remote"
      case .late1hour:
        return "Late"
      case .sickToday:
        return "Sick"
      case .pochav:
        return "Pochav"
      }
    }
    
    var subtitle: String {
      switch self {
      case .dopracNow:
        return "Now"
//      case .remoteToday:
//        return "Today"
      case .remoteTomorrow:
        return "Tomorrow"
      case .late1hour:
        return "1 hour"
      case .sickToday:
        return "Today"
      case .pochav:
        return ""
      }
    }
    
    init(shortcutItem: UIApplicationShortcutItem) {
      self = Action(rawValue: Int(shortcutItem.type)!)!
    }
    
    var shortcutItem: UIApplicationShortcutItem {
      return UIApplicationShortcutItem(type: String(self.rawValue), localizedTitle: self.title, localizedSubtitle: self.subtitle, icon: nil, userInfo: nil)
    }
  }
  
  public static let shared = ShortcutManager()
  private init() {
  }
  
  public func buildShortcutItems() -> [UIApplicationShortcutItem] {
    return Action.allCases.map { $0.shortcutItem }
  }
  
  private func handleResult(_ result: Result<ActionResult, Error>) {
    let text = result.value?.error ?? "Successfully sent"
    UIResultNotifier.shared.showAndHideAfterTime(text: text)
  }
  
  public func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
    let action = Action(shortcutItem: shortcutItem)
    let am: ActionManger = ActionMangerImpl()
    
    switch action {
    case .late1hour:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionLate(sender: userId, from: "now", value: "1_h")
        am.sendAction(action) { [weak self] result in
          self?.handleResult(result)
        }
      }
    case .pochav:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionPochav(sender: userId)
        am.sendAction(action) { [weak self] result in
          self?.handleResult(result)
        }
      }
      
//    case .remoteToday:
//      if let userId = UserDefaultsManager.shared.userId {
//        let action = ActionRemote(sender: userId, value: "today")
//        am.sendAction(action) { [weak self] result in
//          self?.handleResult(result)
//        }
//      }
    case .remoteTomorrow:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionRemote(sender: userId, value: "tomorrow")
        am.sendAction(action) { [weak self] result in
          self?.handleResult(result)
        }
      }
    case .dopracNow:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionDoprac(sender: userId, value: "now")
        am.sendAction(action) { [weak self] result in
          self?.handleResult(result)
        }
      }
    default:
      break
    }
    return true
  }
}
