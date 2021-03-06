//
//  Game.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 21.05.2022.
//

import Foundation

struct Game {
    struct Step {
        struct SteppedPlayer {
            let ref: String
            let card: String
        }

        let index: Int
        let steppedPlayers: [SteppedPlayer]
    }

    struct Player {
        /// Ссылки на фото карт в руке
        let hand: [String]
        let isOnline: Bool
        let playerRef: String
    }

    struct Mark {
        let player: String
        let liked: Bool
        let card: String
    }

    let id: String
    let players: [Player]
    let situations: [String]
    let currentStep: Step
    let marks: [String: [Mark]]
}


extension Game {
    func getMyHand() -> [String] {
        guard let myId = UserService.shared.getUserId() else { return [] }
        return players
            .first(where: { $0.playerRef.components(separatedBy: "/")[1] == myId })
            .map(\.hand) ?? []
    }

    func getMySentCard() -> String? {
        guard let myId = UserService.shared.getUserId() else { return nil }
        return currentStep.steppedPlayers
            .first(where: { $0.ref.components(separatedBy: "/")[1] == myId })?
            .card
    }
}
