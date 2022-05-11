//
//  UIBarButton+Extension.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

extension UIBarButtonItem {
    static func settings(target: Any?, action: Selector?) -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: target,
            action: action
        )
    }
}
