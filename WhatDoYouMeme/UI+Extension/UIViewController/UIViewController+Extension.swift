//
//  UIViewController+Extension.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

extension UIViewController {
    func open(vc: UIViewController, inStack: Bool = true, presentationStyle: UIModalPresentationStyle = .fullScreen) {
        if inStack, let navigator = navigationController {
            navigator.show(vc, sender: nil)
        } else {
            vc.modalPresentationStyle = presentationStyle
            present(vc, animated: true)
        }
    }

    func navigated(by navigator: UINavigationController) -> UIViewController {
        navigator.viewControllers = [self]
        return navigator
    }


    func addCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onCloseTap)
        )
    }

    @objc
    func onCloseTap() {
        dismiss(animated: true)
    }
}
