//
//  MainMenuInteractor.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 23.05.2022.
//

import Foundation

final class MainMenuInteractor {
    private let firestore = FirestoreService.shared


    func getCurrentGameId() -> String? {
        firestore.currentGameId
    }
}
