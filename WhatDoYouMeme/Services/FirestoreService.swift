//
//  FirestoreService.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import FirebaseFirestore

final class FirestoreService {
    private init() {
        db = Firestore.firestore()
        db.settings.isPersistenceEnabled = false
    }
    static let shared = FirestoreService()
    private let db: Firestore


    private var currentLobbieId: String?

    private let currentGameIdKey: String = "currentGameId"
    private(set) var currentGameId: String? {
        get {
            UserDefaults.standard.string(forKey: currentGameIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: currentGameIdKey)
        }
    }

    /// Сохраняется при сворачивании приложения
    private var lastLobbieId: String?


    private var temporaryPlayersArray: [Player] = []


    func getLobbiesList(_ handler: @escaping ([Lobbie]) -> Void) {
        db.collection(CollectionsKeys.lobbies.rawValue)
            .limit(to: 30)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print(error?.localizedDescription ?? "Неизвестная ошибка")
                    handler([])
                    return
                }
                let lobbies = snapshot.documents.compactMap(FirestoreService.documentToLobbie)
                handler(lobbies)
            }
    }

    func getPlayers(byPaths paths: [String], _ handler: @escaping ([Player]) -> Void) {
        temporaryPlayersArray = []
        let playersRefs = paths.map({ db.document($0) })
        playersRefs.enumerated().forEach { (index, playerRef) in
            playerRef.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot else {
                    print(error?.localizedDescription ?? "Неизвестная ошибка")
                    handler([])
                    return
                }
                let id = snapshot.documentID
                let data = snapshot.data() ?? [:]
                let name = data[FieldsKeys.name.rawValue] as? String ?? "Name"
                let player = Player(id: id, name: name)
                self?.temporaryPlayersArray.append(player)
                if paths.count == self?.temporaryPlayersArray.count {
                    handler(self?.temporaryPlayersArray ?? [])
                }
            }
        }
    }

    func createLobbie(withName name: String, _ handler: @escaping (Lobbie?) -> Void) {
        let data: [String: Any] = [
            FieldsKeys.name.rawValue: name,
            FieldsKeys.members.rawValue: [],
            FieldsKeys.readyMembers.rawValue: [DocumentReference]()
        ]
        let newDocumentRef = db.collection(CollectionsKeys.lobbies.rawValue).document()
        newDocumentRef.setData(data) { error in
            guard error == nil else {
                handler(nil)
                return
            }
            let createdLobbie = Lobbie(
                id: newDocumentRef.documentID,
                name: name,
                membersPaths: [],
                readyMembersPaths: [],
                gameId: nil
            )
            handler(createdLobbie)
        }
    }

    func getLobbie(byId id: String, _ handler: @escaping (Lobbie?) -> Void) {
        db.collection(CollectionsKeys.lobbies.rawValue).document(id).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                handler(nil)
                return
            }
            let lobbie = FirestoreService.documentToLobbie(snapshot)
            handler(lobbie)
        }
    }

    func toggleReady(inLobbie lobbieId: String, _ handler: @escaping () -> Void) {
        db.collection(CollectionsKeys.lobbies.rawValue).document(lobbieId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self, let snapshot = snapshot, let data = snapshot.data() else {
                handler()
                return
            }
            var readyMembers = data[FieldsKeys.readyMembers.rawValue] as? [DocumentReference] ?? []
            let readyMembersIds = readyMembers.map(\.documentID)
            guard let userId = UserService.shared.getUserId() else {
                handler()
                return
            }
            if let index = readyMembersIds.firstIndex(of: userId) {
                readyMembers.remove(at: index)
                snapshot.reference.setData([FieldsKeys.readyMembers.rawValue: readyMembers], mergeFields: [FieldsKeys.readyMembers.rawValue])
            } else {
                let currentPlayerRef = strongSelf.db.collection(CollectionsKeys.players.rawValue).document(userId)
                readyMembers.append(currentPlayerRef)
                snapshot.reference.setData([FieldsKeys.readyMembers.rawValue: readyMembers], mergeFields: [FieldsKeys.readyMembers.rawValue])
            }
            handler()
        }
    }

    func quitFromLobbie(saveLastLobbie: Bool = false, _ handler: (() -> Void)? = nil) {
        guard let lobbieId = currentLobbieId else { return }
        db.collection(CollectionsKeys.lobbies.rawValue).document(lobbieId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self, let snapshot = snapshot, let userId = UserService.shared.getUserId() else {
                handler?()
                return
            }
            let members = snapshot.get(FieldsKeys.members.rawValue) as? [DocumentReference] ?? []
            let readyMembers = snapshot.get(FieldsKeys.readyMembers.rawValue) as? [DocumentReference] ?? []
            let currentPlayerRef = strongSelf.db.collection(CollectionsKeys.players.rawValue).document(userId)
            if let memberToRemove = members.first(where: { $0 == currentPlayerRef }) {
                strongSelf.db.runTransaction { transaction, errorPointer in
                    do {
                        let document = try transaction.getDocument(snapshot.reference)
                        let documentData = document.data() ?? [:]
                        let members: [DocumentReference] = documentData.contains(where: { $0.key == FieldsKeys.members.rawValue }) ? documentData[FieldsKeys.members.rawValue] as? [DocumentReference] ?? [] : []
                        if members.count == 1 {
                            transaction.deleteDocument(snapshot.reference)
                        } else {
                            transaction.updateData([FieldsKeys.members.rawValue: FieldValue.arrayRemove([memberToRemove])], forDocument: snapshot.reference)
                            if let memberToRemove = readyMembers.first(where: { $0 == currentPlayerRef }) {
                                transaction.updateData([FieldsKeys.readyMembers.rawValue: FieldValue.arrayRemove([memberToRemove])], forDocument: snapshot.reference)
                            }
                        }
                    } catch {
                        print(error)
                    }
                    return nil
                } completion: { _, _ in
                    handler?()
                }
            }
            strongSelf.currentLobbieId = nil
            strongSelf.lastLobbieId = saveLastLobbie ? lobbieId : nil
        }
    }

    func enterInLobbie(lobbieId: String, _ handler: (() -> Void)? = nil) {
        db.collection(CollectionsKeys.lobbies.rawValue).document(lobbieId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self, let snapshot = snapshot, snapshot.exists, let userId = UserService.shared.getUserId() else {
                handler?()
                return
            }
            var members = snapshot.get(FieldsKeys.members.rawValue) as? [DocumentReference] ?? []
            var readyMembers = snapshot.get(FieldsKeys.readyMembers.rawValue) as? [DocumentReference] ?? []
            let currentPlayerRef = strongSelf.db.collection(CollectionsKeys.players.rawValue).document(userId)
            if !members.contains(currentPlayerRef) {
                members.append(currentPlayerRef)
                snapshot.reference.setData([FieldsKeys.members.rawValue: members], mergeFields: [FieldsKeys.members.rawValue], completion: { _ in handler?() })
            }
            if readyMembers.contains(currentPlayerRef) {
                readyMembers.removeAll(where: { $0 == currentPlayerRef })
                snapshot.reference.setData([FieldsKeys.readyMembers.rawValue: readyMembers], mergeFields: [FieldsKeys.readyMembers.rawValue], completion: { _ in handler?() })
            }
            strongSelf.currentLobbieId = lobbieId
        }
    }

    func createGame(fromLobbie lobbieId: String, _ handler: @escaping () -> Void) {
        db
            .collection(CollectionsKeys.developerData.rawValue)
            .document(DocumentKeys.gamesData.rawValue)
            .getDocument { [weak self] snapshot, error in
                guard let strongSelf = self,
                      let snapshotData = snapshot?.data() else {
                    handler()
                    return
                }

                let allSituations = snapshotData[FieldsKeys.situations.rawValue] as? [String] ?? []
                var allSituations50Random = Set<String>()
                while allSituations50Random.count < 2 {
                    let index = Int.random(in: 0..<allSituations.count)
                    allSituations50Random.insert(allSituations[index])
                }

                let allMemes = snapshotData[FieldsKeys.memes.rawValue] as? [String] ?? []

                strongSelf.db
                    .collection(CollectionsKeys.lobbies.rawValue)
                    .document(lobbieId)
                    .getDocument { snapshot, error in
                        guard let snapshotData = snapshot?.data(),
                              let playersRefs = snapshotData[FieldsKeys.members.rawValue] as? [DocumentReference] else {
                            handler()
                            return
                        }

                        let playersIds = playersRefs.map(\.documentID)
                        guard playersIds.first == UserService.shared.getUserId() else {
                            handler()
                            return
                        }
                        var playersValue: [[String: Any]] = []
                        var takenMemesIndexes: [Int] = []
                        for playersRef in playersRefs {
                            var hand: [String] = []
                            while hand.count < 2 {
                                let memeIndex = Int.random(in: 0..<allMemes.count)
                                if takenMemesIndexes.contains(memeIndex) { continue }
                                let newMeme = allMemes[memeIndex]
                                hand.append(newMeme)
                                takenMemesIndexes.append(memeIndex)
                            }

                            let newPlayer: [String: Any] = [
                                FieldsKeys.isOnline.rawValue: true,
                                FieldsKeys.ref.rawValue: playersRef,
                                FieldsKeys.hand.rawValue: hand
                            ]
                            playersValue.append(newPlayer)
                        }

                        let currentStep: [String: Any] = [
                            FieldsKeys.index.rawValue: 0
                        ]

                        let newGameData: [String: Any] = [
                            FieldsKeys.situations.rawValue: Array(allSituations50Random),
                            FieldsKeys.players.rawValue: playersValue,
                            FieldsKeys.currentStep.rawValue: currentStep
                        ]
                        let newGameRef = strongSelf.db
                            .collection(CollectionsKeys.games.rawValue)
                            .document()
                        let newGameId = newGameRef.documentID
                        newGameRef.setData(newGameData) { error in
                            guard error == nil else {
                                handler()
                                return
                            }

                            let newLobbieData: [String: Any] = [
                                FieldsKeys.gameId.rawValue: newGameId
                            ]
                            let lobbieRef = strongSelf.db
                                .collection(CollectionsKeys.lobbies.rawValue)
                                .document(lobbieId)

                            lobbieRef.setData(newLobbieData, mergeFields: [FieldsKeys.gameId.rawValue]) { _ in
                                lobbieRef.delete { _ in
                                    handler()
                                }
                            }
                        }
                    }
            }
    }

    func loadGame(withId gameId: String, _ handler: @escaping (Game?) -> Void) {
        db
            .collection(CollectionsKeys.games.rawValue)
            .document(gameId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let strongSelf = self,
                      let snapshot = snapshot,
                      let snapshotData = snapshot.data(),
                      let playersData = snapshotData[FieldsKeys.players.rawValue] as? [[String: Any]],
                      let currentStepData = snapshotData[FieldsKeys.currentStep.rawValue] as? [String: Any] else {
                    handler(nil)
                    return
                }

                let players = playersData.map { playerData -> Game.Player in
                    let hand: [String] = playerData[FieldsKeys.hand.rawValue] as? [String] ?? []
                    let isOnline: Bool = playerData[FieldsKeys.isOnline.rawValue] as? Bool ?? false
                    let ref: DocumentReference? = playerData[FieldsKeys.ref.rawValue] as? DocumentReference
                    let refString: String = ref?.path ?? .empty
                    return Game.Player(hand: hand, isOnline: isOnline, playerRef: refString)
                }
                let situations = snapshotData[FieldsKeys.situations.rawValue] as? [String] ?? []

                let index: Int = currentStepData[FieldsKeys.index.rawValue] as? Int ?? .zero
                let steppedPlayersData: [[String: Any]] = currentStepData[FieldsKeys.steppedPlayers.rawValue] as? [[String: Any]] ?? []
                let steppedPlayers = steppedPlayersData.map { steppedPlayerData -> Game.Step.SteppedPlayer in
                    let ref: DocumentReference? = steppedPlayerData[FieldsKeys.ref.rawValue] as? DocumentReference
                    let refPath: String = ref?.path ?? .empty
                    let card: String = steppedPlayerData[FieldsKeys.card.rawValue] as? String ?? .empty
                    return Game.Step.SteppedPlayer(ref: refPath, card: card)
                }
                let currentStep = Game.Step(index: index, steppedPlayers: steppedPlayers)
                let game = Game(
                    id: snapshot.documentID,
                    players: players,
                    situations: situations,
                    currentStep: currentStep
                )
                strongSelf.currentGameId = game.id
                handler(game)
            }
    }

    func quitFromGame(withId gameId: String, _ handler: @escaping (Bool) -> Void) {
        db
            .collection(CollectionsKeys.games.rawValue)
            .document(gameId)
            .getDocument { [weak self] snapshot, error in
                guard let strongSelf = self,
                      let snapshotData = snapshot?.data(),
                      var playersData = snapshotData[FieldsKeys.players.rawValue] as? [[String: Any]],
                      var currentStepData = snapshotData[FieldsKeys.currentStep.rawValue] as? [String: Any] else {
                    handler(false)
                    return
                }

                let userId = UserService.shared.getUserId() ?? .empty
                playersData.removeAll { playerData -> Bool in
                    let ref = playerData[FieldsKeys.ref.rawValue] as? DocumentReference
                    let playerId = ref?.documentID ?? .empty
                    return playerId == userId
                }
                var steppedPlayersData: [[String: Any]] = currentStepData[FieldsKeys.steppedPlayers.rawValue] as? [[String: Any]] ?? []
                steppedPlayersData.removeAll { steppedPlayerData -> Bool in
                    let ref = steppedPlayerData[FieldsKeys.ref.rawValue] as? DocumentReference
                    let playerId = ref?.documentID ?? .empty
                    return playerId == userId
                }
                currentStepData[FieldsKeys.steppedPlayers.rawValue] = steppedPlayersData

                let newData: [String: Any] = [
                    FieldsKeys.players.rawValue: playersData,
                    FieldsKeys.currentStep.rawValue: currentStepData
                ]
                snapshot?.reference.setData(
                    newData,
                    mergeFields: [
                        FieldsKeys.players.rawValue,
                        FieldsKeys.currentStep.rawValue
                    ],
                    completion: { error in
                        if error == nil {
                            strongSelf.currentGameId = nil
                            if playersData.isEmpty {
                                strongSelf.removeGame(withId: gameId, handler: handler)
                            } else {
                                handler(true)
                            }
                        } else {
                            handler(false)
                        }
                    }
                )
            }
    }

    func setOnlineInCurrentGame(_ isOnline: Bool) {
        guard let currentGameId = currentGameId else { return }

        let currentGameRef = db
            .collection(CollectionsKeys.games.rawValue)
            .document(currentGameId)

        currentGameRef.getDocument { snapshot, error in
            guard let snapshotData = snapshot?.data() else { return }
            guard var players = snapshotData[FieldsKeys.players.rawValue] as? [[String: Any]] else { return }
            guard let userId = UserService.shared.getUserId() else { return }

            let currentPlayerIndex = players.firstIndex { playerData -> Bool in
                let playerRef = playerData[FieldsKeys.ref.rawValue] as? DocumentReference
                guard let playerId = playerRef?.documentID else { return false }
                return playerId == userId
            }
            guard let currentPlayerIndex = currentPlayerIndex else { return }

            var currentPlayer = players[currentPlayerIndex]
            currentPlayer[FieldsKeys.isOnline.rawValue] = isOnline
            players[currentPlayerIndex] = currentPlayer

            let newData: [String: Any] = [
                FieldsKeys.players.rawValue: players
            ]
            snapshot?.reference.setData(newData, mergeFields: [FieldsKeys.players.rawValue])
        }
    }

    func enterLastLobbie() {
        guard let lastLobbieId = lastLobbieId else {
            return
        }
        enterInLobbie(lobbieId: lastLobbieId)
    }
}


// MARK: - Private
private extension FirestoreService {
    static func documentToLobbie(_ document: DocumentSnapshot) -> Lobbie? {
        guard let data = document.data() else { return nil }
        let id = document.documentID
        let name = data[FieldsKeys.name.rawValue] as? String ?? "Name"
        let membersRefs = data[FieldsKeys.members.rawValue] as? [DocumentReference] ?? []
        let membersPaths = membersRefs.map(\.path)
        let readyMembersRefs = data[FieldsKeys.readyMembers.rawValue] as? [DocumentReference] ?? []
        let readyMembersPaths = readyMembersRefs.map(\.path)
        let gameId = data[FieldsKeys.gameId.rawValue] as? String
        return Lobbie(id: id, name: name, membersPaths: membersPaths, readyMembersPaths: readyMembersPaths, gameId: gameId)
    }


    func removeGame(withId gameId: String, handler: @escaping (Bool) -> Void) {
        db
            .collection(CollectionsKeys.games.rawValue)
            .document(gameId)
            .delete { error in
                handler(error == nil)
            }
    }
}


fileprivate enum CollectionsKeys: String {
    case lobbies
    case players
    case games
    case developerData
}

fileprivate enum DocumentKeys: String {
    case gamesData
}

fileprivate enum FieldsKeys: String {
    case name
    case members
    case readyMembers
    case situations
    case memes
    case players
    case hand
    case isOnline
    case ref
    case steppedPlayers
    case card
    case index
    case currentStep
    case gameId
}
