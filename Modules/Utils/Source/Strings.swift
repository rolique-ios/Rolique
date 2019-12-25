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
    public static var calendar: String { return "Calendar".localized }
  }
  
  public struct NavigationTitle {
    public static var colleagues: String { return "Colleagues".localized }
    public static var actions: String { return "Actions".localized }
    public static var more: String { return "More".localized }
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
    public static func vacationDays(args: CVarArg...) -> String {
      return String(format: "%.2f days left".localized, arguments: args)
    }
    public static func vacationDaysFromPreviousYear(args: CVarArg...) -> String {
      return String(format: "Also %.2f from previous year".localized, arguments: args)
    }
    public static var phoneNumber: String { return "Phone number".localized }
    public static var email: String { return "Email".localized }
    public static var skype: String { return "Skype".localized }
    public static var vacationDays: String { return "Vacation days".localized }
    public static var eduPoints: String { return "Education points".localized }
    public static var dateOfJoining: String { return "Date of joining".localized }
    public static var emergencyDays: String { return "Emergency days".localized }
    public static var birthday: String { return "Date of birth".localized }
    public static var roles: String { return "Roles".localized }
    public static var copied: String { return "Copied".localized }
    public static var additionalInfoPlaceholder: String { return "Write some additional information about yourself".localized }
    public static var openSlack: String { return "Open slack".localized }
    public static var call: String { return "Call".localized }
    public static var sendEmail: String { return "Send email".localized }
    public static var openSkype: String { return "Open skype".localized }
  }
  
  public struct More {
    public static var meetingRooms: String { return "Meeting rooms".localized }
    public static var cashTracker: String { return "Cash Tracker".localized }
  }
  
  public struct MeetingRooms {
    public static var edit: String { return "Edit".localized }
    public static var done: String { return "Done".localized }
    public static var noTitle: String { return "No title".localized }
  }
}
