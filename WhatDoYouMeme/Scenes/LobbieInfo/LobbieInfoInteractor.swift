//
//  LobbieInfoInteractor.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import Foundation

final class LobbieInfoInteractor {
    let firestore = FirestoreService.shared
    let userService = UserService.shared


    func loadPlayers(withPaths paths: [String], _ handler: @escaping ([Player]) -> Void) {
        firestore.getPlayers(byPaths: paths, handler)
    }

    func loadLobbie(byId id: String, _ handler: @escaping (Lobbie?) -> Void) {
        firestore.getLobbie(byId: id, handler)
    }

    func toggleReady(lobbieId: String, _ handler: @escaping () -> Void) {
        firestore.toggleReady(inLobbie: lobbieId, handler)
    }

    func getUserId() -> String? {
        userService.getUserId()
    }

    func enterInLobbie(lobbieId: String, _ handler: @escaping () -> Void) {
        firestore.enterInLobbie(lobbieId: lobbieId, handler)
    }

    func quitFromLobbie(_ handler: (() -> Void)? = nil) {
        firestore.quitFromLobbie(handler)
    }
}
