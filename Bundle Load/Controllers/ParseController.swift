//
//  ParseController.swift
//  Bundle Load
//
//  Created by Denis Bystruev on 23/08/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit

class ParseController {
    // MARK: - Stored Properties
    private static var parseBuffer = ""
    private static var parseLevel = 0
    
    // MARK: - Computed Properties
    private static var parseTabs: String {
        return String(repeating: "\t", count: parseLevel)
    }
    
    // MARK: - Custom Methods
    static func parse(_ viewController: UIViewController) {
        if parseLevel == 0 {
            parseBuffer = "\(#line) \(#function) \(#file)\n"
        }
        parseBuffer = "\(parseBuffer)\(parseTabs)\(viewController)\n"
        parseLevel += 1
        
        switch viewController {
            
        case let collectionViewController as UICollectionViewController:
            parse(collectionViewController.collectionView)
            
        case let navigationController as UINavigationController:
            for childController in navigationController.viewControllers {
                parse(childController)
            }
            
        case let pageViewController as UIPageViewController:
            for childController in pageViewController.viewControllers ?? [] {
                parse(childController)
            }
            
        case let searchContainerViewController as UISearchContainerViewController:
            parse(searchContainerViewController.searchController)
            
        case let searchController as UISearchController:
            parse(searchController.searchBar)
            
        case let splitViewController as UISplitViewController:
            for childController in splitViewController.viewControllers {
                parse(childController)
            }
            
        case let tabBarController as UITabBarController:
            for childController in tabBarController.viewControllers ?? [] {
                parse(childController)
            }
            
        case let tableViewController as UITableViewController:
            parse(tableViewController.tableView)
            
        default:
            parse(viewController.view)
        }
        
        parseLevel -= 1
        if parseLevel == 0 {
            print(parseBuffer)
        }
    }
    
    static func parse(_ view: UIView) {
        parseBuffer = "\(parseBuffer)\(parseTabs)\(view)\n"
        parseLevel += 1
        
        switch view {
            
        case let stackView as UIStackView:
            for subview in stackView.arrangedSubviews {
                parse(subview)
            }
            
        default:
            for subview in view.subviews {
                parse(subview)
            }
            
        }
        
        parseLevel -= 1
    }
}
