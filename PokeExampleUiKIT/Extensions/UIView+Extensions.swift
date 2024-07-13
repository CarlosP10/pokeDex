//
//  UIView+Extensions.swift
//  PokeExampleUiKIT
//
//  Created by Carlos Paredes on 12/7/24.
//

import UIKit

extension UIView {
    /// Add multiple Views
    /// - Parameter views: Collections of views
    func addSubviews(_ views: UIView...) {
        views.forEach({
            self.addSubview($0)
        })
    }
}
