//
//  GameInteractor.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 21.05.2022.
//

import Foundation

final class GameInteractor {
    private let firestore: FirestoreService = FirestoreService.shared


    func loadGame(withId gameId: String, _ handler: @escaping (Game?) -> Void) {
        firestore.loadGame(withId: gameId, handler)
    }

    func quitGame(withId gameId: String, _ handler: @escaping (Bool) -> Void) {
        firestore.quitFromGame(withId: gameId, handler)
    }

    func makeStep(
        gameId: String,
        card: String,
        handler: (() -> Void)?
    ) {
        firestore.makeStep(gameId: gameId, card: card, handler: handler)
    }
}
