//
//  ImageManager.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/2/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Foundation
import Utils

private struct Constants {
  static var cacheCountLimit: Int { return 1000 } // arbitrary count
}

enum ImageManagerError: LocalizedError {
  case imageNotFound
}

extension ImageManagerError {
  var errorDescription: String? {
    switch self {
    case .imageNotFound:
      return "Image not found"
    }
  }
}

final class ImageManager {
  private lazy var cache: NSCache<NSURL, UIImage> = {
    let cache = NSCache<NSURL, UIImage>()
    cache.countLimit = Constants.cacheCountLimit
    return cache
  }()
  private let lock = NSLock()
  private lazy var observer: NSObjectProtocol = {
    return NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] notification in
      self?.cache.removeAllObjects()
    }
  }()
  
  static let shared = ImageManager()
  private init() {}
  
  deinit {
    NotificationCenter.default.removeObserver(self.observer)
  }
  
  private let fileManager = FileManager.default
  private var documentDirectoryURL: URL {
    return try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
  }
  private var imagesDirectoryURL: URL {
    return URL(fileURLWithPath: documentDirectoryURL.path + "/Images")
  }
  
  func getImage(with url: URL, completion: @escaping (Result<UIImage?, ImageManagerError>) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self = self else { return }
      
      let image = self.lock
        .do({ [weak self] in self?.dataInCache(forKey: url) })

      if let unwrappedImage = image {
        DispatchQueue.main.async {
          completion(.success(unwrappedImage))
        }
        
        return
      }
      
      self.createDirectoryIfNeeded(with: self.imagesDirectoryURL)
      self.fileManager
        .contents(atPath: self.imagePath(imagesDirectoryURL: self.imagesDirectoryURL, imageURL: url)).flatMap { [weak self] data in
          let image = self?.convertDataIntoImage(data: data)
          self?.lock.do { [weak self] in self?.saveInCache(image: image, forKey: url) }
          DispatchQueue.main.async {
            completion(image)
        .contents(atPath: self.imagePath(imagesDirectoryURL: self.imagesDirectoryURL, imageURL: url))
        .flatMap { [weak self] data in
          let image = self?.convertDataIntoImage(data: data)
          self?.lock
            .do { [weak self] in self?.saveInCache(image: image, forKey: url) }
          DispatchQueue.main.async {
            image == nil ? completion(.failure(.imageNotFound)) : completion(.success(image))
          }
      }
    }
  }
  
  func saveImage(data: Data, forURL url: URL) {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self = self else { return }
      
      self.lock
        .do({ [weak self] in self?.saveInCache(image: self?.convertDataIntoImage(data: data), forKey: url) })
      
      self.createDirectoryIfNeeded(with: self.imagesDirectoryURL)
      self.fileManager
        .createFile(atPath: self.imagePath(imagesDirectoryURL: self.imagesDirectoryURL, imageURL: url),
                    contents: data,
                    attributes: nil)
    }
  }
  
  func findImagesDirectorySize() -> UInt64 {
    return findDirectorySize(path: imagesDirectoryURL.path)
  }
  
  func clearImagesFolder() {
    guard let filePaths = try? fileManager.contentsOfDirectory(atPath: imagesDirectoryURL.path) else {
      return
    }
    
    filePaths
      .map { imagesDirectoryURL.path + "/" + $0 }
      .forEach(fileManager.safeRemove(atPath:))
  }
  
  private func findDirectorySize(path: String) -> UInt64 {
    guard let files = try? fileManager.subpathsOfDirectory(atPath: path) else { return 0 }
    
    return files
      .map { (try? fileManager.attributesOfItem(atPath: path + "/" + $0)[FileAttributeKey.size] as? NSNumber)?.uint64Value ?? 0 }
      .reduce(0, { $0 + $1 })
  }
  
  private func imagePath(imagesDirectoryURL: URL, imageURL: URL) -> String {
    return imagesDirectoryURL.path + "/" + "\(imageURL.lastPathComponent)"
  }
  
  private func createDirectoryIfNeeded(with url: URL) {
    if !fileManager.fileExists(atPath: url.path) {
      try! fileManager.createDirectory(at: url,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
    }
  }
  
  private func dataInCache(forKey key: URL) -> UIImage? {
    return self.cache.object(forKey: key as NSURL)
  }
  
  private func saveInCache(image: UIImage?, forKey key: URL) {
    image.map { self.cache.setObject($0, forKey: key as NSURL) }
  }
  
  private func convertDataIntoImage(data: Data) -> UIImage? {
    return UIImage(data: data, scale: UIScreen.main.scale)
  }
}

extension UIImageView {
  private static var taskKey = 0
  private static var urlKey = 0
  
  private var currentTask: URLSessionTask? {
    get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
    set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  private var currentURL: URL? {
    get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
    set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  func cancelLoad() {
    self.currentTask?.cancel()
    self.currentTask = nil
    self.image = nil
  }
  
  func setImage(with url: URL) {
    ImageManager.shared.getImage(with: url) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success(let cachedImage):
        self.image = cachedImage
      case .failure:
        self.currentURL = url
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
          guard let data = data, let downloadedImage = UIImage(data: data, scale: UIScreen.main.scale) else {
            return
          }
          
          ImageManager.shared.saveImage(data: data, forURL: url)
          
          if url == self?.currentURL {
            DispatchQueue.main.async {
              self?.image = downloadedImage
            }
          }
        }
        
        self.currentTask = task
        task.resume()
      }
    }
  }
}
