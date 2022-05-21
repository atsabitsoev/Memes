//
//  AppCoordinator.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 21.05.2022.
//

import UIKit

final class AppCoordinator {
    func openFromParent(
        vc: UIViewController,
        from fromVC: UIViewController,
        inStack: Bool = true,
        canGoBack: Bool = true,
        presentationStyle: UIModalPresentationStyle = .fullScreen
    ) {
        guard let parent = fromVC.presentingViewController else { return }
        fromVC.dismiss(animated: true) {
            parent.open(vc: vc, inStack: inStack, canGoBack: canGoBack, presentationStyle: presentationStyle)
        }
    }
}
