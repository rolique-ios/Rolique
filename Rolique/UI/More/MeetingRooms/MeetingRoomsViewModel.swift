//
//  MeetingRoomsViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/8/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Utils
import Networking

protocol MeetingRoomsViewModel {
  var users: [User] { get }
  var participants: Set<User> { get set }
  var meetingRooms: [MeetingRoom: [Date: [Room]]] { get }
  
  func changeDate(with date: Date)
  func changeRoom(with room: MeetingRoom)
}

final class MeetingRoomsViewModelImpl: BaseViewModel, MeetingRoomsViewModel {
  private var userService: UserService
  private var meetingRoomsManager: MeetingRoomManager
  private(set) var meetingRooms = [MeetingRoom: [Date: [Room]]]()
  private(set) var users = [User]()
  private var currentRoom = MeetingRoom.conference
  private var currentDate = Date()
  var participants = Set<User>()
  
  var onRoomsUpdate: ((MeetingRoom, [Room]) -> Void)?
  var onChangeDate: Completion?
  var onChangeMeetingRoom: ((MeetingRoom) -> Void)?
  
  init(userService: UserService, meetingRoomsManager: MeetingRoomManager) {
    self.userService = userService
    self.meetingRoomsManager = meetingRoomsManager
  }
  
  override func viewDidLoad() {
    userService.getAllUsersFromLocal { [weak self] users in
      self?.users = users.sorted(by: {$0.slackProfile.realName < $1.slackProfile.realName})
    }
  }
  
  func changeDate(with date: Date) {
    currentDate = date
    onChangeDate?()
    getMeetingRooms()
  }
  
  func changeRoom(with room: MeetingRoom) {
    currentRoom = room
    onChangeMeetingRoom?(room)
    getMeetingRooms()
  }
  
  private func getMeetingRooms() {
    if let rooms = meetingRooms[currentRoom]?[currentDate] {
      onRoomsUpdate?(currentRoom, rooms)
      return
    }
    
    meetingRoomsManager.getMeetingRooms(meetingRoom: currentRoom, startDate: currentDate.utc, endDate: currentDate.utc) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success(let (request, rooms)):
        guard let room = MeetingRoom(rawValue: request.room) else { return }
        
        let fileteredRooms = rooms.filter {
          let attendee = $0.attendees.first(where: { $0.isResource })
          if (attendee?.isResource ?? false) && attendee?.responseStatus == "declined" {
            return false
          }
          
          return true
        }
        
        let calendar = Calendar.utc
        let sortedRooms = fileteredRooms.sorted(by: {
          let firstDateComponents = calendar.dateComponents([.hour, .minute], from: $0.start.dateTime)
          let firstDate = calendar.date(byAdding: firstDateComponents, to: Date().utc).orCurrent
          
          let secondDateComponents = calendar.dateComponents([.hour, .minute], from: $1.start.dateTime)
          let secondDate = calendar.date(byAdding: secondDateComponents, to: Date().utc).orCurrent
          return firstDate < secondDate
        })
        
        if self.meetingRooms[room] != nil {
          self.meetingRooms[room]![request.startDate] = sortedRooms
        } else {
          self.meetingRooms[room] = [request.startDate: sortedRooms]
        }
        
        if self.currentDate == request.startDate {
          self.onRoomsUpdate?(room, sortedRooms)
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}
