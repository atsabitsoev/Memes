//
//  CreateGameCoordinator.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

final class CreateGameCoordinator {
    private let factory = BigFactory()


    func showLobbieInfoVC(lobbieId: String, fromVC: UIViewController) {
        let lobbieInfoVC = factory.makeLobbieInfoVC(lobbieId: lobbieId)
        fromVC.open(vc: lobbieInfoVC, inStack: true, canGoBack: false)
    }
}
