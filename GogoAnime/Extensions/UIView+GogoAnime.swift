//
//  UIView+GogoAnime.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import UIKit

extension UIView {
    
    func addAutoLayoutSubviews(_ views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
}
