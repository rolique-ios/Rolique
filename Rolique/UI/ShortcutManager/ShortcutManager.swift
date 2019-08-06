//
//  ShortcutManager.swift
//  UI
//
//  Created by Bohdan Savych on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Model
import Utils

public final class ShortcutManager {
  public enum Action: Int, CaseIterable {
    case dopracNow,
    late1hour,
    remoteToday,
    remoteTomorrow,
    sickToday
    
    var title: String {
      switch self {
      case .dopracNow:
        return "Doprac"
      case .remoteToday, .remoteTomorrow:
        return "Remote"
      case .late1hour:
        return "Late"
      case .sickToday:
        return "Sick"
      }
    }
    
    var subtitle: String {
      switch self {
      case .dopracNow:
        return "Now"
      case .remoteToday:
        return "Today"
      case .remoteTomorrow:
        return "Tomorrow"
      case .late1hour:
        return "1 hour"
      case .sickToday:
        return "Today"
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
  
  public func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
    let action = Action(shortcutItem: shortcutItem)
    let am: ActionManger = ActionMangerImpl()
    
    switch action {
    case .late1hour:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionLate(sender: userId, from: "now", value: "1_h")
        am.sendAction(action) { result in
          
        }
      }
    case .remoteToday:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionRemote(sender: userId, value: "today")
        am.sendAction(action) { result in
          
        }
      }
    case .remoteTomorrow:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionRemote(sender: userId, value: "tomorrow")
        am.sendAction(action) { result in
          
        }
      }
    case .dopracNow:
      if let userId = UserDefaultsManager.shared.userId {
        let action = ActionDoprac(sender: userId, value: "now")
        am.sendAction(action) { result in
          
        }
      }
    default:
      break
    }
    return true
  }
}
