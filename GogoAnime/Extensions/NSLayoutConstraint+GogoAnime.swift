//
//  NSLayoutConstraint+GogoAnime.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import UIKit

extension NSLayoutConstraint {
    
    func priority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
