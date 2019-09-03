//
//  ImageManager.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/2/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Foundation

final class ImageManager {
  private lazy var observer: NSObjectProtocol = {
    return NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] notification in
      self?.clearImagesFolder()
    }
  }()
  
  static let shared = ImageManager()
  
  private init() {}
  
  deinit {
    NotificationCenter.default.removeObserver(self.observer)
  }
  
  private let fileManager = FileManager.default
  private func documentDirectoryURL() throws -> URL {
    return try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
  }
  private func imagesDirectoryURL() throws -> URL {
    return URL(fileURLWithPath: try documentDirectoryURL().path + "/Images")
  }
  
  func getImage(with url: URL) -> UIImage? {
    do {
      let imagesDirectory = try imagesDirectoryURL()
      if let data = fileManager.contents(atPath: imagePath(imagesDirectoryURL: imagesDirectory, imageURL: url)) {
        return UIImage(data: data, scale: UIScreen.main.scale)
      }
    } catch let error as NSError {
      print("Could not get image: \(error.debugDescription), for url: \(url)")
    }
    return nil
  }
  
  func saveImage(data: Data, forURL url: URL) {
    do {
      let imagesDirectory = try imagesDirectoryURL()
      checkDirectoryExists(with: imagesDirectory)
      fileManager.createFile(atPath: imagePath(imagesDirectoryURL: imagesDirectory, imageURL: url),
                             contents: data,
                             attributes: nil)
    } catch let error as NSError {
      print("Could not save image: \(error.debugDescription), for url: \(url)")
    }
  }
  
  private func imagePath(imagesDirectoryURL: URL, imageURL: URL) -> String {
    return imagesDirectoryURL.path + "/" + "\(imageURL.lastPathComponent.hashValue)"
  }
  
  private func checkDirectoryExists(with url: URL) {
    if !fileManager.fileExists(atPath: url.path) {
      do {
        try fileManager.createDirectory(at: url,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
      } catch let error as NSError {
        print("Could not create images folder: \(error.debugDescription)")
      }
    }
  }
  
  private func clearImagesFolder() {
    do {
      let imagesDirectory = try imagesDirectoryURL()
      checkDirectoryExists(with: imagesDirectory)
      let filePaths = try fileManager.contentsOfDirectory(atPath: imagesDirectory.path)
      for filePath in filePaths {
        try fileManager.removeItem(atPath: imagesDirectory.path + "/" + filePath)
      }
    } catch let error as NSError {
      print("Could not clear images folder: \(error.debugDescription)")
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
  
  func setImage(with url: URL?) {
    guard let url = url else { return }
    
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
