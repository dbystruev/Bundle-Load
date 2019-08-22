//
//  FileController.swift
//  Bundle Load
//
//  Created by Denis Bystruev on 22/08/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import Foundation

class FileController {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func url(to fileName: String) -> URL {
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    static func write(_ data: Data, to fileName: String) -> (URL?, Error?) {
        let url = documentsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: [.noFileProtection])
            return (url, nil)
        } catch let error {
            return (nil, error)
        }
    }
}
