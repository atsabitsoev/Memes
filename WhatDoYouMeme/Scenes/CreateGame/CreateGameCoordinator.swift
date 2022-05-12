//
//  CreateGameCoordinator.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

final class CreateGameCoordinator {
    private let factory = BigFactory()


    func showLobbieInfoVC(lobbie: Lobbie, fromVC: UIViewController) {
        let lobbieInfoVC = factory.makeLobbieInfoVC(lobbie: lobbie)
        fromVC.open(vc: lobbieInfoVC, inStack: true, canGoBack: false)
    }
}
