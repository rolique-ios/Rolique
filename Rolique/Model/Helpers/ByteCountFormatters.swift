//
//  ByteCountFormatters.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/3/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

final class ByteCountFormatters {
  static var fileSizeFormatter: ByteCountFormatter = {
    let byteCountFormatter = ByteCountFormatter()
    byteCountFormatter.allowedUnits = .useMB
    byteCountFormatter.countStyle = .file
    
    return byteCountFormatter
  }()
}
