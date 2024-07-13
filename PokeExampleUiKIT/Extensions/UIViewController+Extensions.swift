//
//  UIViewController+Extensions.swift
//  PokeExampleUiKIT
//
//  Created by Carlos Paredes on 12/7/24.
//

import UIKit
import SwiftUI

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertViewController, animated: true)
    }
    
    func showMessage(title: String, message: String, messageType: MessageType) {
        
        let hostingController = UIHostingController(rootView: MessageView(title: title, message: message, messageType: messageType))
        
        guard let messageView = hostingController.view else { return }
        
        view.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        addChild(hostingController)
        hostingController.didMove(toParent: self)
        
        messageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            messageView.removeFromSuperview()
        }
    }
}
