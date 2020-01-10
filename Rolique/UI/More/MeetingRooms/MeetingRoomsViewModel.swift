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

struct TimeInterspace: Comparable {
  let startTime: Date
  var endTime = Date()
  
  static func < (lhs: TimeInterspace, rhs: TimeInterspace) -> Bool {
    return lhs.startTime < rhs.endTime
  }
}

protocol MeetingRoomsViewModel {
  var users: [User] { get }
  var participants: Set<User> { get }
  var title: String? { get }
  var meetingRooms: [MeetingRoom: [Date: [RoomData]]] { get }
  var currentTimeInterspace: TimeInterspace? { get }
  
  var onRoomsUpdate: ((MeetingRoom, [RoomData]) -> Void)? { get set }
  var onChangeDate: Completion? { get set }
  var onChangeMeetingRoom: ((MeetingRoom) -> Void)? { get set }
  var onFinishBooking: Completion? { get set }
  var onError: ((String) -> Void)? { get set }
  
  func changeDate(with date: Date)
  func changeRoom(with room: MeetingRoom)
  
  func bookMeetingRoom(with title: String?)
  func setCurrentTimeInterspace(_ timeInterspace: TimeInterspace)
  func finishBooking()
  func addParticipant(_ participant: User)
  func removeParticipant(_ participant: User)
  func changeTitle(_ title: String?)
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
  private(set) var currentTimeInterspace: TimeInterspace?
  private(set) var participants = Set<User>()
  private(set) var title: String?
  
  var onRoomsUpdate: ((MeetingRoom, [RoomData]) -> Void)?
  var onChangeDate: Completion?
  var onChangeMeetingRoom: ((MeetingRoom) -> Void)?
  var onFinishBooking: Completion?
  var onError: ((String) -> Void)?
  
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
    switch orientation {
    case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
      portraitOrientationCVWidth = collectionViewWidth
    default:
      landScapeOrientationCVWidth = collectionViewWidth
    }
    let roomsData = meetingRooms[currentRoom]?[currentDate] ?? []
    calculateRoomsData(roomsData: roomsData)
    onRoomsUpdate?(currentRoom, roomsData)
  }
  
  func setCurrentTimeInterspace(_ timeInterspace: TimeInterspace) {
    self.currentTimeInterspace = timeInterspace
  }
  
  func finishBooking() {
    self.currentTimeInterspace = nil
    self.title = nil
    self.participants.removeAll()
  }
  
  func addParticipant(_ participant: User) {
    self.participants.insert(participant)
  }
  
  func removeParticipant(_ participant: User) {
    self.participants.remove(participant)
  }
  
  func changeTitle(_ title: String?) {
    self.title = title
  }
  
  func bookMeetingRoom(with title: String?) {
    guard let timeInterspace = currentTimeInterspace else { return }
    
    var participants = self.participants.map { (email: $0.slackProfile.email, displayName: $0.slackProfile.realName) }
    participants.append((email: userService.currentUser.slackProfile.email, displayName: userService.currentUser.slackProfile.realName))
    
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: timeInterspace.startTime).orCurrent
    let startTime = DateFormatters.withCurrentTimeZoneFormatter().string(from: startDate)
    
    let endDate = calendar.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: timeInterspace.endTime).orCurrent
    let endTime = DateFormatters.withCurrentTimeZoneFormatter().string(from: endDate)
    
    meetingRoomsManager.bookMeetingRoom(meetingRoom: currentRoom,
                                        startTime: startTime,
                                        endTime: endTime,
                                        timeZone: TimeZone.current.identifier,
                                        summary: title,
                                        participants: participants) { [weak self] result in
                                          guard let self = self else { return }
                                          
                                          switch result {
                                          case .success(let room):
                                            let sortedRooms: [RoomData]
                                            if self.meetingRooms[self.currentRoom]?[self.currentDate] != nil {
                                              self.meetingRooms[self.currentRoom]![self.currentDate]!.append(RoomData(room: room))
                                              sortedRooms = self.sortRoomsAndInvalidateFrame(rooms: self.meetingRooms[self.currentRoom]![self.currentDate]!)
                                              self.calculateRoomsData(roomsData: sortedRooms)
                                            } else {
                                              let rooms = [RoomData(room: room)]
                                              self.meetingRooms[self.currentRoom] = [self.currentDate: rooms]
                                              sortedRooms = rooms
                                              self.calculateRoomsData(roomsData: sortedRooms)
                                            }
                                            self.onRoomsUpdate?(self.currentRoom, sortedRooms)
                                            self.onFinishBooking?()
                                          case .failure(let error):
                                            self.onFinishBooking?()
                                            self.onError?(error.localizedDescription)
                                          }
    }
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
      switch currentOrientation {
      case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
        roomData.verticalFrame = getRect(with: index, roomData: roomData, rooms: roomsData, cvWidth: portraitOrientationCVWidth)
      default:
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
    let height = endMinute == 0 ? abs(hoursHeight - minutesHeight) : hoursHeight + minutesHeight
    
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
      let x = CGFloat(index - firstIntersectedIndex) * width
      xPoint = x >= cvWidth ? cvWidth / 2 : x
    }
    
    let frame = CGRect(x: xPoint + Constants.defaultOffset,
                       y: yPoint + Constants.defaultOffset,
                       width: xPoint + width == cvWidth ? width - Constants.edgeOffset : width - Constants.defaultOffset * 2,
                       height: height - Constants.defaultOffset * 2)
    return frame
  }
  
  private func filterRooms(with rooms: [Room]) -> [RoomData] {
    var roomsData = [RoomData]()
    
    for room in rooms {
      let attendee = room.attendees.first(where: { $0.isResource })
      if (attendee?.isResource ?? false) && attendee?.responseStatus == Constants.declined {
        continue
      }
      
      roomsData.append(RoomData(room: room))
    }
    
    calculateRoomsData(roomsData: roomsData)
    
    return roomsData
  }
  
  private func sortRoomsAndInvalidateFrame(rooms: [RoomData]) -> [RoomData] {
    let calendar = Calendar.utc
    return rooms.sorted(by: {
      $0.verticalFrame = nil
      $0.horizontalFrame = nil

      let firstDateComponents = calendar.dateComponents([.hour, .minute], from: $0.room.start.dateTime)
      let firstDate = calendar.date(byAdding: firstDateComponents, to: Date().utc).orCurrent
      
      let secondDateComponents = calendar.dateComponents([.hour, .minute], from: $1.room.start.dateTime)
      let secondDate = calendar.date(byAdding: secondDateComponents, to: Date().utc).orCurrent
      return firstDate < secondDate
    })
  }
}
