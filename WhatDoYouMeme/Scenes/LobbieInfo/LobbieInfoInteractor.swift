//
//  LobbieInfoInteractor.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import Foundation

final class LobbieInfoInteractor {
    let firestore = FirestoreService()


    func loadPlayers(withPaths paths: [String], _ handler: @escaping ([Player]) -> Void) {
        firestore.getPlayers(byPaths: paths, handler)
    }
}
