//
//  UITableView+Extension.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

extension UITableView {
    func deselectAllRows() {
        if let indexPaths = indexPathsForVisibleRows {
            indexPaths.forEach({ deselectRow(at: $0, animated: true) })
        }
    }
}
