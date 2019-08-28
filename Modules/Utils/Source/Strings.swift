//
//  Strings.swift
//  Utils
//
//  Created by Bohdan Savych on 8/1/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation

public struct Strings {
  public struct General {
    public static var ok: String { return "Ok".localized }
    public static var appName: String { return "Rolique".localized }
  }
  
  public struct TabBar {
    public static var profile: String { return "profile".localized }
    public static var stats: String { return "stats".localized }
  }
  
  public struct NavigationTitle {
    public static var colleagues: String { return "Colleagues".localized }
    public static var actions: String { return "Actions".localized }
  }
  
  public struct Actions {
    public static var confirm: String { return "Confirm".localized }
    public static var cancel: String { return "Cancel".localized }
    public static var pochavTitle: String { return "Ready to start working?".localized }
    public static var dopracTitle: String { return "Available actions:".localized }
    public static var now: String { return "Now".localized }
    public static var inAHour: String { return "In a hour".localized }
    public static var customTime: String { return "Custom time".localized }
    public static var chooseTime: String { return "Choose time".localized }
  }
}
