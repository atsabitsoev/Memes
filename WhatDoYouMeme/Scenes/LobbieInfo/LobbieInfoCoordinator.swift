//
//  LobbieInfoCoordinator.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class LobbieInfoCoordinator {
    private let factory = BigFactory()
    private let appCoordinator = AppCoordinator()


    func showGameVC(gameId: String, from fromVC: UIViewController) {
        let gameVC = factory.makeGameVC(gameId: gameId, withNavigator: true)
        appCoordinator.openFromParent(vc: gameVC, from: fromVC, inStack: false)
    }
}
