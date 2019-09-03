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
    public static var profile: String { return "Profile".localized }
    public static var stats: String { return "stats".localized }
  }
  
  public struct NavigationTitle {
    public static var colleagues: String { return "Colleagues".localized }
    public static var actions: String { return "Actions".localized }
  }
  
  public struct Collegues {
    public static var showOptions: String { return "Show options".localized }
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
    public static var remoteTitle: String { return "Please select an option:".localized }
    public static var today: String { return "Today".localized }
    public static var tomorrow: String { return "Tomorrow".localized }
    public static var customDates: String { return "Custom dates".localized }
    public static var remoteDates: String { return "Your remote dates".localized }
    public static var startTitle: String { return "Start: ".localized }
    public static var endTitle: String { return "End: ".localized }
    public static var doneTitle: String { return "Done".localized }
    public static var nextTitle: String { return "Next".localized }
    public static var dateFormatterPlaceholder: String { return "YYYY-MM-DD" }
    public struct Error {
      public static var chooseStart: String { return "Choose start date".localized }
      public static var chooseEnd: String { return "Choose end date".localized }
      public static var startLargerEnd: String { return "Start date should be less than end date".localized }
    }
    public static var lateTitle: String { return "So you are late.. When to expect you?".localized }
    public static var fromNow: String { return "From now".localized }
    public static var from10Oclock: String { return "From 10:00".localized }
    public static var in30minutes: String { return "in 30 minutes".localized }
    public static var in1hour: String { return "in 1 hour".localized }
    public static var orChooseTime: String { return "..or choose time".localized }
  }
  
  public struct Profile {
    public static var logOutTitle: String { return "Log out".localized }
    public static var logOutQuestion: String { return "Log out?".localized }
    public static var logOutMessage: String { return "Are you sure?".localized }
    public static var clearCache: String { return "Clear cache".localized }
  }
}
