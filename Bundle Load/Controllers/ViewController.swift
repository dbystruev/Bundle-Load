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
    let versionPath = "http://server.getoutfit.ru:8090/images/version.txt"
    let versionStringKey = "versionStringKey"
    
    // MARK: - Stored Properties
    var loadTime = Date() {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentInitialViewController()
            }
        }
    }
    var presentationTime: Date?
    var version: String?
    
    // MARK: - Methods Inherited from UIViewController
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBundle() { data, error in
            guard let data = data else {
                if let error = error {
                    print(#line, #function, "ERROR: \(error.localizedDescription)")
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
    func loadBundle(completion: @escaping (Data?, Error?) -> Void) {
        guard let versionURL = URL(string: versionPath) else {
            print(#line, #function, "ERROR: Can't create URL from \(versionPath)")
            completion(nil, nil)
            return
        }
        
        let versionSession = URLSession.shared.dataTask(with: versionURL) { data, _, error in
            guard let versionData = data else {
                completion(nil, error)
                return
            }
            
            guard let versionString = String(data: versionData, encoding: .utf8) else {
                print(#line, #function, "ERROR: Can't get string from \(self.versionPath)")
                completion(nil, nil)
                return
            }
            
            let previousVersionString = UserDefaults.standard.string(forKey: self.versionStringKey)
            guard !versionString.isEmpty && previousVersionString != versionString else {
                print(#line, #function, "WARNING: No new version found \(versionString)")
                completion(nil, nil)
                return
            }
            
            self.version = versionString
            
            guard let bundleURL = URL(string: self.bundlePath) else {
                print(#line, #function, "ERROR: Can't create URL from \(self.bundlePath)")
                completion(nil, nil)
                return
            }
            
            let bundleSession = URLSession.shared.dataTask(with: bundleURL) { data, _, error in
                completion(data, error)
            }
            
            bundleSession.resume()
        }
        
        versionSession.resume()
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
        
        guard let viewController = storyboard.instantiateInitialViewController() else {
            print(#line, #function, "ERROR: Can't instantiate initial view controller from \(storyboardName) storyboard of \(bundlePath) bundle")
            return
        }
        dismiss(animated: false)
        present(viewController, animated: false)
        presentationTime = Date()
        if let version = version {
            UserDefaults.standard.set(version, forKey: versionStringKey)
        }
        ParseController.parse(viewController)
    }
    
}

// MARK: - SSZipArchiveDelegate
extension ViewController: SSZipArchiveDelegate {
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        loadTime = Date()
    }
}
