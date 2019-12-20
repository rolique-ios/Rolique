//
//  Route.swift
//  Networking
//
//  Created by Andrii on 7/31/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public class Route {
  
  public enum Method: String {
    case get, post, put, patch, delete
    var value: String { return self.rawValue.uppercased() }
  }
  
  public typealias Headers = [String: String]
  public typealias Params = [String: String]
  
  public let endpoint: String
  public let method: Route.Method
  public let headers: Route.Headers?
  public let urlParams: Route.Params
  public let body: [String: Any]?
  public var customUrl: URL?
  
  init (endpoint: String, method: Route.Method, headers: Route.Headers? = nil, urlParams: Route.Params = [:], body: [String: Any]? = nil) {
    self.endpoint = endpoint
    self.method = method
    self.headers = headers
    self.urlParams = urlParams
    self.body = body
  }
  
  private func makeURL() -> URL? {
    let urlString = "https://" + Env.apiUrl + endpoint
    print("url \(urlString)")
    let url = URL(string: urlString)
    return url
  }
  
  private func makeAuthHeaders() -> Headers {
    return [
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": Env.apiToken]
  }
  
  public func asRequest() throws -> URLRequest {
    guard var url = customUrl ?? makeURL() else { throw NSError(domain: "rolique", code: 700, userInfo: [NSLocalizedFailureReasonErrorKey: "Failed to make url"]) }
    if urlParams.keys.count > 0 {
      urlParams.keys.forEach { url = url.appending($0, value: urlParams[$0]) }
    }
    var request = URLRequest(url: url,
                             cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                             timeoutInterval: 30)
    request.allHTTPHeaderFields = headers ?? makeAuthHeaders()
    request.httpMethod = method.value
    if let body = body {
      request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
    }
    
    return request
  }
}

extension URL {
  func appending(_ queryItem: String, value: String?) -> URL {
    guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
    var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
    let queryItem = URLQueryItem(name: queryItem, value: value)
    queryItems.append(queryItem)
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }
}
