//
//  ViewController.swift
//  Bundle Load
//
//  Created by Denis Bystruev on 22/08/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Constant Properties
    let bundleName = "Loadable.bundle"
    let bundlePath = "http://server.getoutfit.ru:8090/images/Loadable.bundle.zip"
    
    // MARK: - Variable Properties
    var loadTime = Date() {
        didSet {
            presentInitialViewController()
        }
    }
    var presentationTime: Date?

    // MARK: - Methods Inherited from UIViewController
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: bundlePath) else {
            print(#line, #function, "ERROR: Can't create URL from \(bundlePath)")
            return
        }
        
        loadBundle(from: url) { data, error in
            guard let data = data else {
                if let error = error {
                    print(#line, #function, "ERROR: \(error.localizedDescription)")
                } else {
                    print(#line, #function, "ERROR: Can't load data from \(url.absoluteString)")
                }
                return
            }
            
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
            
            let source = zipFileURL.path
            let destination = FileController.url(to: "Bundles").path
            SSZipArchive.unzipFile(atPath: source, toDestination: destination, delegate: self)
        }
    }

    // MARK: - Own Methods
    func loadBundle(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let session = URLSession.shared.dataTask(with: url) { data, _, error in
            completion(data, error)
        }
        
        session.resume()
    }
    
    func presentInitialViewController(storyboardName: String = "Main", bundlePath: String? = nil) {
        guard presentationTime == nil || presentationTime! < loadTime else {
            return
        }
        
        let bundlePath = bundlePath ?? "\(FileController.url(to: "Bundles").path)/\(bundleName)"
        
        print(#line, #function, bundlePath)
        
        guard let bundle = Bundle(path: bundlePath) else {
            print(#line, #function, "ERROR: Can't create bundle from \(bundlePath)")
            return
        }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        
        DispatchQueue.main.async {
            guard let viewController = storyboard.instantiateInitialViewController() else {
                print(#line, #function, "ERROR: Can't instantiate initial view controller from \(storyboardName) storyboard of \(bundlePath) bundle")
                return
            }
            self.dismiss(animated: false)
            self.presentationTime = Date()
            self.present(viewController, animated: false)
        }
    }

}

// MARK: - SSZipArchiveDelegate
extension ViewController: SSZipArchiveDelegate {
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        loadTime = Date()
    }
}
