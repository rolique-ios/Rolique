//
//  CalendarViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/1/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

protocol CalendarViewModel: ViewModel {
  var users: [User] { get }
  var startDate: Date { get }
  var endDate: Date { get }
  var events: [Date: [String: [RecordType]]] { get }
  var onUsersSuccess: (([User]) -> Void)? { get set }
  var onEventsSuccess: (([Date: [String: [RecordType]]]) -> Void)? { get set }
  var onError: ((String) -> Void)? { get set }
  var onUpdateDates: ((Date, Date) -> Void)? { get set }
  
  func getUsers()
  func getMoreEvents(direction: Direction)
}

final class CalendarViewModelImpl: BaseViewModel, CalendarViewModel {
  private let userService: UserService
  private let attendanceManager: AttendanceManager
  
  var users: [User] = []
  var onUsersSuccess: (([User]) -> Void)?
  var onEventsSuccess: (([Date: [String: [RecordType]]]) -> Void)?
  var onError: ((String) -> Void)?
  
  var startDate: Date
  var endDate: Date
  var events = [Date: [String: [RecordType]]]()
  var onUpdateDates: ((Date, Date) -> Void)?
  
  private let threeMonth = TimeInterval.month * 3
  
  init(userService: UserService, attendanceManager: AttendanceManager) {
    self.userService = userService
    self.attendanceManager =  attendanceManager
    let mondayOfWeek = Date().mondayOfWeek.utc
    startDate = Date(timeInterval: -threeMonth, since: mondayOfWeek).utc
    endDate = Date(timeInterval: threeMonth, since: mondayOfWeek).utc
  }
  
  func getMoreEvents(direction: Direction) {
    let start = direction == .toLeft ? Date(timeInterval: -threeMonth, since: startDate) : endDate
    let end = direction == .toRight ? Date(timeInterval: threeMonth, since: endDate) : startDate
    startDate = start < startDate ? start : startDate
    endDate = end > endDate ? end : endDate
    onUpdateDates?(startDate, endDate)
    getEvents(startDate: start, endDate: end)
  }
  
  override func viewDidLoad() {
    getUsers()
    
    getEvents(startDate: startDate, endDate: endDate)
  }
  
  func getUsers() {
    userService.getAllUsers(sortDecrciptors: nil,
                            onLocal: handleUsersResult(result:),
                            onFetch: handleUsersResult(result:))
  }
  
  private func getEvents(startDate: Date, endDate: Date) {
    attendanceManager.getAttandancy(startDate: startDate, endDate: endDate,
                                    limit: nil, offset: nil,
                                    result: handleEventsResult(result:))
  }
  
  private func handleUsersResult(result: Result<[User], Error>) {
    switch result {
    case .success(let users):
      let users = users.sorted(by: {$0.slackProfile.realName < $1.slackProfile.realName})
      self.users = users
      onUsersSuccess?(users)
    case .failure(let error):
      onError?(error.localizedDescription)
    }
  }
  
  private func handleEventsResult(result: Result<[AttendanceRecord], Error>) {
    switch result {
    case .success(let attendanceRecords):
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        guard let self = self else { return }
        
        let calendar = Calendar.current
        for attendance in attendanceRecords {
          var startDate = attendance.startDate.utc
          while startDate <= attendance.endDate {
            if let recordType = RecordType(rawValue: attendance.type) {
              if self.events[startDate] != nil {
                if self.events[startDate]![attendance.userSlackId] != nil {
                  self.events[startDate]![attendance.userSlackId]!.append(recordType)
                } else {
                  self.events[startDate]![attendance.userSlackId] = [recordType]
                }
              } else {
                self.events[startDate] = [attendance.userSlackId: [recordType]]
              }
            }
            
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
          }
        }
        
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          self.onEventsSuccess?(self.events)
        }
      }
    case .failure(let error):
      onError?(error.localizedDescription)
    }
  }
}
