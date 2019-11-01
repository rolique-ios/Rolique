//
//  RemoteUserService.swift
//  RemoteTodayExtension
//
//  Created by Maksym Ivanyk on 11/1/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

private struct Constants {
  static var lowerBoundHour: Int { return 6 }
  static var upperBoundHour: Int { return 21 }
}

final class RemoteUserServiceImpl: UserServiceImpl {
  override func getTodayUsersForRecordType(_ recordType: RecordType, onLocal: ((Result<[User], Error>) -> Void)?, onFetch: ((Result<[User], Error>) -> Void)?) {
    let context = CoreDataController.shared.backgroundContext()
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self = self else { return }
      
      do {
        let moUsers = try self.coreDataManager.getManagedObjects(context: context)
        let users = moUsers.compactMap { User($0) }
        DispatchQueue.main.async {
          onLocal?(.success(users))
        }
      } catch {
        DispatchQueue.main.async {
          onLocal?(.failure(error))
        }
      }
    }
    
    let calendar = Calendar.current
    let currentDate = Date()
    let lowerBound = calendar.date(bySettingHour: Constants.lowerBoundHour, minute: 00, second: 0, of: currentDate).orCurrent
    let upperBound = calendar.date(bySettingHour: Constants.upperBoundHour, minute: 00, second: 0, of: currentDate).orCurrent
    
    guard currentDate > lowerBound && currentDate < upperBound else { return }

    userManager.getTodayUsersForRecordType(recordType) { [weak self] usersResult in
      switch usersResult {
      case .success(let array):
        self?.coreDataManager.clearCoreData()
        self?.coreDataManager.saveToCoreData(array, context: context)
        onFetch?(.success(array))
      case .failure(let error):
        onFetch?(.failure(error))
      }
    }
  }
}
