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
  func login(result: ((Result<User, Error>) -> Void)?)
}

public final class LoginManagerImpl: LoginManager {
  private var authSession: SFAuthenticationSession?
  
  public init() {
  }

  private func getLoginURL() -> URL? {
    return try? SlackLogin().asRequest().url
  }
  
  public func login(result: ((Result<User, Error>) -> Void)?) {
    guard let url = getLoginURL() else { return }
    
    self.authSession = SFAuthenticationSession(url: url, callbackURLScheme: "rolique", completionHandler: { (redirectUrl, error) in
      if error == nil {
        guard let redirectUrl = redirectUrl else { print("no redirect url"); return }
        self.login(redirectUrl: redirectUrl, result: { res in
          DispatchQueue.main.async {
            result?(res)
          }
        })
      } else {
        DispatchQueue.main.async {
          result?(.failure(error!))
        }
      }
    })
    
    self.authSession?.start()
  }
  
  func login(redirectUrl: URL, result: ((Result<User, Error>) -> Void)?) {
    let query = redirectUrl.query?.components(separatedBy: "=")
    if query![0] == "code" {
      let code = query![1]
      Net.Worker.request(SlackToken(code: code), onSuccess: { jsonResult in
        guard let userSlackId = jsonResult.string("user/id") else {
          DispatchQueue.main.async {
            result?(.failure(Err.general(masg: "failed to get string value by keypath: user/id")))
          }
          return
        }
        
        let getUserWithId = GetUserWithId(userId: userSlackId)
        Net.Worker.request(getUserWithId, onSuccess: { userJson in
          guard let userBody = userJson.json("body") else {
            DispatchQueue.main.async {
              result?(.failure(Err.general(masg: "response does not contain body")))
            }
            return
          }
          guard let data = userBody.stringValue.data(using: .utf8) else {
            DispatchQueue.main.async {
              result?(.failure(Err.general(masg: "failed to serialize user body")))
            }
            return
          }
          guard let user = try? JSONDecoder().decode(User.self, from: data) else {
            DispatchQueue.main.async {
              result?(.failure(Err.general(masg: "failed to decode user")))
            }
            return
          }
          result?(.success(user))
        }, onError: { error in
          DispatchQueue.main.async {
            result?(.failure(error))
          }
        })
      }, onError: { error in
        DispatchQueue.main.async {
          result?(.failure(error))
        }
      })
    }
  }
}
