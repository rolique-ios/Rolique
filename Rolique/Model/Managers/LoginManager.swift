//
//  LoginManager.swift
//  Model
//
//  Created by Andrii on 7/31/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import UIKit
import Networking
import SafariServices

public protocol LoginManager {
  func getLoginURL() -> URL?
  func login(redirectUrl: URL, result: ((Result<User, Error>) -> Void)?)
}

//class WindowProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
//  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//    return presentationAnchor
//  }
//
//  let presentationAnchor: ASPresentationAnchor
//
//  init(presentationAnchor: ASPresentationAnchor) {
//    self.presentationAnchor = presentationAnchor
//    super.init()
//  }
//}

public final class LoginManagerImpl: LoginManager {
  
//  let contextProvider: ASWebAuthenticationPresentationContextProviding
  
  public init() {
//    self.contextProvider = WindowProvider(presentationAnchor: presentationAnchor)
  }

  public func getLoginURL() -> URL? {
    return try? SlackLogin().asRequest().url
  }
  
  public func login(redirectUrl: URL, result: ((Result<User, Error>) -> Void)?) {
  
    let query = redirectUrl.query?.components(separatedBy: "=")
    if query![0] == "code" {
      let code = query![1]
       Net.Worker.request(SlackToken(code: code), onSuccess: { jsonResult in
        guard let userSlackId = jsonResult.string("user/id") else {
          DispatchQueue.main.async {
            let error = NSError(domain: "rolique", code: 777, userInfo: [NSLocalizedDescriptionKey: "failed to get string value by keypath: user/id"])
            result?(.failure(error))
          }
          return
        }
        print(userSlackId)
        let getUserWithId = GetUserWithId(userId: userSlackId)
        Net.Worker.request(getUserWithId, onSuccess: { userJson in
          print(userJson)
          //                let user = User(id: id, slackProfile: <#T##SlackProfile#>, birthday: <#T##String#>, dateOfJoining: <#T##String#>, eduPoints: <#T##Int#>, emergencyDays: <#T##Int#>, roles: <#T##[String]#>, vacationData: <#T##[String : Double]#>)
        }, onError: { error in
          print(error)
        })
       }, onError: { error in
        DispatchQueue.main.async {
          result?(.failure(error))
        }
      })
    }
    
  }
  
}
