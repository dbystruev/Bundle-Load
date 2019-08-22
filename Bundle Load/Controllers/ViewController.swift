//
//  ViewController.swift
//  Bundle Load
//
//  Created by Denis Bystruev on 22/08/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let bundleName = "Loadable.bundle"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "http://server.getoutfit.ru:8090/images/Loadable.bundle.zip")!
        loadBundle(from: url) { data, error in
            guard let data = data else {
                if let error = error {
                    print(#line, #function, "ERROR: \(error.localizedDescription)")
                } else {
                    print(#line, #function, "ERROR: Can't load data from \(url.absoluteString)")
                }
                return
            }
            print(#line, #function, "1. Loaded \(data) from \(url.absoluteString)")
            
            let zipFileName = "\(self.bundleName).zip"
            let (returnedURL, error) = FileController.write(data, to: zipFileName)
            guard let zipFileURL = returnedURL else {
                if let error = error {
                    print(#line, #function, "ERROR: \(error.localizedDescription)")
                } else {
                    print(#line, #function,  "ERROR: Can't write data to \(zipFileName)")
                }
                return
            }
            print(#line, #function, "2. Has written data to \(zipFileURL.path)")
            
            let source = zipFileURL.path
            let destination = FileController.url(to: "Bundles").path
            SSZipArchive.unzipFile(atPath: source, toDestination: destination, delegate: self)
        }
    }

    func loadBundle(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let session = URLSession.shared.dataTask(with: url) { data, _, error in
            completion(data, error)
        }
        
        session.resume()
    }

}

extension ViewController: SSZipArchiveDelegate {
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        print(#line, #function, "3. The bundle has been unzipped at \(unzippedPath)")
        
        let bundlePath = "\(unzippedPath)/\(bundleName)"
        guard let bundle = Bundle(path: bundlePath) else {
            print(#line, #function, "ERROR: Can't create bundle from \(bundlePath)")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        guard let viewController = storyboard.instantiateInitialViewController() else {
            print(#line, #function, "ERROR: Can't instantiate initial view controller from Main.Storyboard")
            return
        }
        DispatchQueue.main.async {
            self.present(viewController, animated: true)
        }
    }
}
