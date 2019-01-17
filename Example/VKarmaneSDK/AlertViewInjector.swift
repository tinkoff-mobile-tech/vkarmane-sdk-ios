//
//  AlertViewInjector.swift
//  VKarmaneSDK_Example
//
//  Created by a.kulabukhov on 17/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

// A bit of dark magic just for example project

fileprivate enum AlertViewInjector {
    
    static func injectView(_ view: UIView, into controller: UIAlertController, heightPoints: Int) -> (() -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false

        var textFields = [UIView]()
        (0..<heightPoints).forEach { _ in
            controller.addTextField { textFields.append($0) }
        }
        
        return { [unowned controller] in
            if let superview = commonSuperview(for: textFields) {
                controller.view.addSubview(view)
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
                superview.isHidden = true
            }
        }
    }
    
    private static func commonSuperview(for views: [UIView]) -> UIView? {
        var views = views
        for _ in 0... {
            views = views.compactMap { $0.superview }
            let superviews = Set(views)
            if superviews.isEmpty {
                return nil
            }
            else if superviews.count == 1 {
                return superviews.first!
            }
        }
        return nil
    }
    
}

extension UIAlertController {
    
    func setContentView(_ view: UIView, heightPoints: Int) -> () -> Void {
        return AlertViewInjector.injectView(view, into: self, heightPoints: heightPoints)
    }
    
}
