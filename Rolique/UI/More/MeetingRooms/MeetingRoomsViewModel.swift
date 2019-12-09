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

private struct Constants {
  static var startHour: Int { return 9 }
  static var minutesStep: Int { return 30 }
  static var defaultCellHeight: CGFloat { return 40.0 }
  static var defaultOffset: CGFloat { return 2.0 }
  static var edgeOffset: CGFloat { return 15.0 }
  static var declined: String { return "declined" }
}

protocol MeetingRoomsViewModel {
  var users: [User] { get }
  var participants: Set<User> { get set }
  var meetingRooms: [MeetingRoom: [Date: [RoomData]]] { get }
  
  func changeDate(with date: Date)
  func changeRoom(with room: MeetingRoom)
}

final class RoomData {
  let room: Room
  var verticalFrame: CGRect?
  var horizontalFrame: CGRect?
  
  init(room: Room) {
    self.room = room
  }
}

final class MeetingRoomsViewModelImpl: BaseViewModel, MeetingRoomsViewModel {
  private var userService: UserService
  private var meetingRoomsManager: MeetingRoomManager
  private(set) var meetingRooms = [MeetingRoom: [Date: [RoomData]]]()
  private(set) var users = [User]()
  private var currentRoom = MeetingRoom.conference
  private var currentDate = Date()
  private var portraitOrientationCVWidth = CGFloat.zero
  private var landScapeOrientationCVWidth = CGFloat.zero
  private var currentOrientation = UIDeviceOrientation.portrait
  var participants = Set<User>()
  
  var onRoomsUpdate: ((MeetingRoom, [RoomData]) -> Void)?
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
  
  func orientationDidChanged(_ orientation: UIDeviceOrientation, collectionViewWidth: CGFloat) {
    currentOrientation = orientation
    if orientation == .portrait {
      portraitOrientationCVWidth = collectionViewWidth
    } else {
      landScapeOrientationCVWidth = collectionViewWidth
    }
    let roomsData = meetingRooms[currentRoom]?[currentDate] ?? []
    calculateRoomsData(roomsData: roomsData)
    onRoomsUpdate?(currentRoom, roomsData)
  }
  
  private func getMeetingRooms() {
    if let roomsData = meetingRooms[currentRoom]?[currentDate] {
      self.calculateRoomsData(roomsData: roomsData)
      onRoomsUpdate?(currentRoom, roomsData)
      return
    }
    
    meetingRoomsManager.getMeetingRooms(meetingRoom: currentRoom, startDate: currentDate.utc, endDate: currentDate.utc) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success(let (request, rooms)):
        guard let room = MeetingRoom(rawValue: request.room) else { return }
        
        let calendar = Calendar.utc
        let sortedRooms = rooms.sorted(by: {
          let firstDateComponents = calendar.dateComponents([.hour, .minute], from: $0.start.dateTime)
          let firstDate = calendar.date(byAdding: firstDateComponents, to: Date().utc).orCurrent
          
          let secondDateComponents = calendar.dateComponents([.hour, .minute], from: $1.start.dateTime)
          let secondDate = calendar.date(byAdding: secondDateComponents, to: Date().utc).orCurrent
          return firstDate < secondDate
        })
        
        let roomsData = self.filterRooms(with: sortedRooms)
        
        if self.meetingRooms[room] != nil {
          self.meetingRooms[room]![request.startDate] = roomsData
        } else {
          self.meetingRooms[room] = [request.startDate: roomsData]
        }
        
        if self.currentDate == request.startDate {
          self.onRoomsUpdate?(room, roomsData)
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  
  private func calculateRoomsData(roomsData: [RoomData]) {
    for (index, roomData) in roomsData.enumerated() {
      if currentOrientation == .portrait, roomData.verticalFrame == nil {
        roomData.verticalFrame = getRect(with: index, roomData: roomData, rooms: roomsData, cvWidth: portraitOrientationCVWidth)
      } else if roomData.horizontalFrame == nil {
        roomData.horizontalFrame = getRect(with: index, roomData: roomData, rooms: roomsData, cvWidth: landScapeOrientationCVWidth)
      }
    }
  }
  
  private func getRect(with index: Int, roomData: RoomData, rooms: [RoomData], cvWidth: CGFloat) -> CGRect {
    let calendar = Calendar.utc
    let startComponents = calendar.dateComponents([.hour, .minute], from: roomData.room.start.dateTime)
    let startHour = startComponents.hour.orZero
    let startMinute = startComponents.minute.orZero
    
    let endComponents = calendar.dateComponents([.hour, .minute], from: roomData.room.end.dateTime)
    let endHour = endComponents.hour.orZero
    let endMinute = endComponents.minute.orZero
    let yPoint = ((CGFloat(startHour - Constants.startHour)) * 2 * Constants.defaultCellHeight + CGFloat(startMinute) / CGFloat(Constants.minutesStep) * Constants.defaultCellHeight) + Constants.defaultCellHeight / 2
    let minutesHeight = abs((CGFloat(endMinute) / CGFloat(Constants.minutesStep) * Constants.defaultCellHeight) - (CGFloat(startMinute) / CGFloat(Constants.minutesStep) * Constants.defaultCellHeight))
    let hoursHeight = CGFloat(endHour - startHour) * 2 * Constants.defaultCellHeight
    let height = abs(hoursHeight - minutesHeight)
    
    let start = calendar.date(byAdding: startComponents, to: Date().utc).orCurrent
    let end = calendar.date(byAdding: endComponents, to: Date().utc).orCurrent
    
    var firstIntersectedIndex: Int?
    let intersects = rooms.enumerated().filter { (filteredIndex, filteredRoomData) in
      guard roomData.room.id != filteredRoomData.room.id else { return false }
      
      let filteredRoomStartComponents = calendar.dateComponents([.hour, .minute], from: filteredRoomData.room.start.dateTime)
      let filteredRoomEndComponents = calendar.dateComponents([.hour, .minute], from: filteredRoomData.room.end.dateTime)
      let filteredRoomStart = calendar.date(byAdding: filteredRoomStartComponents, to: Date().utc).orCurrent
      let filteredRoomEnd = calendar.date(byAdding: filteredRoomEndComponents, to: Date().utc).orCurrent
      
      if start >= filteredRoomStart && start < filteredRoomEnd || filteredRoomStart >= start && filteredRoomStart < end {
        if firstIntersectedIndex == nil {
          firstIntersectedIndex = filteredIndex
        }
        
        return true
      }
      
      return false
    }
    
    let width = intersects.isEmpty ? cvWidth : cvWidth / CGFloat(intersects.count + 1)
    let xPoint: CGFloat
    if intersects.isEmpty {
      xPoint = CGFloat.zero
    } else {
      let firstIntersectedIndex = firstIntersectedIndex.orZero > index ? firstIntersectedIndex.orZero - 1 : firstIntersectedIndex.orZero
      xPoint = CGFloat(index - firstIntersectedIndex) * width
    }
    
    return CGRect(x: xPoint + Constants.defaultOffset,
                  y: yPoint + Constants.defaultOffset,
                  width: xPoint + width == cvWidth ? width - Constants.edgeOffset : width - Constants.defaultOffset * 2,
                  height: height - Constants.defaultOffset * 2)
  }
  
  private func filterRooms(with rooms: [Room]) -> [RoomData] {
    var roomsData = [RoomData]()
    
    for room in rooms {
      let attendee = room.attendees.first(where: { $0.isResource })
      if (attendee?.isResource ?? false) && attendee?.responseStatus == Constants.declined {
        continue
      }
      let roomData = RoomData(room: room)
      roomsData.append(roomData)
    }
    
    for (index, roomData) in roomsData.enumerated() {
      if currentOrientation == .portrait, roomData.verticalFrame == nil {
        roomData.verticalFrame = getRect(with: index, roomData: roomData, rooms: roomsData, cvWidth: portraitOrientationCVWidth)
      } else if roomData.horizontalFrame == nil {
        roomData.horizontalFrame = getRect(with: index, roomData: roomData, rooms: roomsData, cvWidth: landScapeOrientationCVWidth)
      }
    }
    
    return roomsData
  }
}
