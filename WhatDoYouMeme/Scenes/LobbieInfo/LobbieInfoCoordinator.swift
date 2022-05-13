//
//  LobbieInfoCoordinator.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class LobbieInfoCoordinator {
    private let factory = BigFactory()


    func showGameVC(from fromVC: UIViewController) {
        let gameVC = factory.makeGameVC()
        fromVC.open(vc: gameVC, inStack: false)
    }
}
