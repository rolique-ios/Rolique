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

final class ImageManager {
  static let shared = ImageManager()
  private init() {}
  
  private let fileManager = FileManager.default
  private var documentDirectoryURL: URL {
    return try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
  }
  private var imagesDirectoryURL: URL {
    return URL(fileURLWithPath: documentDirectoryURL.path + "/Images")
  }
  
  func getImage(with url: URL) -> UIImage? {
    createDirectoryIfNeeded(with: imagesDirectoryURL)
    
    return fileManager
      .contents(atPath: imagePath(imagesDirectoryURL: imagesDirectoryURL, imageURL: url))
      .flatMap { UIImage(data: $0, scale: UIScreen.main.scale) }
  }
  
  func saveImage(data: Data, forURL url: URL) {
    createDirectoryIfNeeded(with: imagesDirectoryURL)
    
    fileManager.createFile(atPath: imagePath(imagesDirectoryURL: imagesDirectoryURL, imageURL: url),
                           contents: data,
                           attributes: nil)
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
    if let cachedImage = ImageManager.shared.getImage(with: url) {
      self.image = cachedImage
      return
    }
    
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
