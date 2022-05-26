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
        db.clearPersistence()
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
        guard let userId = UserService.shared.getUserId() else {
            handler()
            return
        }
        let currentLobbieRef = db
            .collection(CollectionsKeys.lobbies.rawValue)
            .document(lobbieId)

        db.runTransaction { [weak self] transaction, _ in
            guard let strongSelf = self,
                  let document = try? transaction.getDocument(currentLobbieRef),
                  let documentData = document.data() else { return nil }
            let readyMembers = documentData[FieldsKeys.readyMembers.rawValue] as? [DocumentReference] ?? []
            if let memberToRemove = readyMembers.first(where: { $0.documentID == userId }) {
                transaction.updateData([FieldsKeys.readyMembers.rawValue: FieldValue.arrayRemove([memberToRemove])], forDocument: currentLobbieRef)
            } else {
                let currentPlayerRef = strongSelf.db.collection(CollectionsKeys.players.rawValue).document(userId)
                transaction.updateData([FieldsKeys.readyMembers.rawValue: FieldValue.arrayUnion([currentPlayerRef])], forDocument: currentLobbieRef)
            }
            return nil
        } completion: { _, _ in
            handler()
        }
    }

    func quitFromLobbie(saveLastLobbie: Bool = false, _ handler: (() -> Void)? = nil) {
        guard let userId = UserService.shared.getUserId(),
              let lobbieId = currentLobbieId else {
            handler?()
            return
        }
        let currentLobbieRef = db
            .collection(CollectionsKeys.lobbies.rawValue)
            .document(lobbieId)
        let currentPlayerRef = db.collection(CollectionsKeys.players.rawValue).document(userId)

        db.runTransaction { transaction, _ in
            guard let document = try? transaction.getDocument(currentLobbieRef) else { return nil }
            let members = document.get(FieldsKeys.members.rawValue) as? [DocumentReference] ?? []
            let readyMembers = document.get(FieldsKeys.readyMembers.rawValue) as? [DocumentReference] ?? []

            guard let memberToRemove = members.first(where: { $0 == currentPlayerRef }) else { return nil  }
            if members.count == 1 {
                transaction.deleteDocument(currentLobbieRef)
            } else {
                transaction.updateData([FieldsKeys.members.rawValue: FieldValue.arrayRemove([memberToRemove])], forDocument: currentLobbieRef)
                if let memberToRemove = readyMembers.first(where: { $0 == currentPlayerRef }) {
                    transaction.updateData([FieldsKeys.readyMembers.rawValue: FieldValue.arrayRemove([memberToRemove])], forDocument: currentLobbieRef)
                }
            }

            return nil
        } completion: { [weak self] _, _ in
            self?.currentLobbieId = nil
            self?.lastLobbieId = saveLastLobbie ? lobbieId : nil
            handler?()
        }
    }

    func enterInLobbie(lobbieId: String, _ handler: (() -> Void)? = nil) {
        guard let userId = UserService.shared.getUserId() else { return }
        let currentPlayerRef = db.collection(CollectionsKeys.players.rawValue).document(userId)

        let currentLobbieRef = db
            .collection(CollectionsKeys.lobbies.rawValue)
            .document(lobbieId)

        db.runTransaction { transaction, _ in
            guard let document = try? transaction.getDocument(currentLobbieRef), document.exists else { return nil }

            let members = document.get(FieldsKeys.members.rawValue) as? [DocumentReference] ?? []
            let readyMembers = document.get(FieldsKeys.readyMembers.rawValue) as? [DocumentReference] ?? []

            if !members.contains(currentPlayerRef) {
                transaction.updateData([FieldsKeys.members.rawValue: FieldValue.arrayUnion([currentPlayerRef])], forDocument: currentLobbieRef)
            }
            if readyMembers.contains(currentPlayerRef) {
                transaction.updateData([FieldsKeys.readyMembers.rawValue: FieldValue.arrayRemove([currentPlayerRef])], forDocument: currentLobbieRef)
            }

            return nil
        } completion: { [weak self] _, _ in
            self?.currentLobbieId = lobbieId
            handler?()
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
                            while hand.count < 3 {
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

                        let newGameData: [String: Any] = [
                            FieldsKeys.situations.rawValue: Array(allSituations50Random),
                            FieldsKeys.players.rawValue: playersValue,
                            FieldsKeys.index.rawValue: 0
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
                      let playersData = snapshotData[FieldsKeys.players.rawValue] as? [[String: Any]] else {
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

                let index: Int = snapshotData[FieldsKeys.index.rawValue] as? Int ?? .zero
                let steppedPlayersData: [[String: Any]] = snapshotData[FieldsKeys.steppedPlayers.rawValue] as? [[String: Any]] ?? []
                let steppedPlayers = steppedPlayersData.map { steppedPlayerData -> Game.Step.SteppedPlayer in
                    let ref: DocumentReference? = steppedPlayerData[FieldsKeys.ref.rawValue] as? DocumentReference
                    let refPath: String = ref?.path ?? .empty
                    let card: String = steppedPlayerData[FieldsKeys.card.rawValue] as? String ?? .empty
                    return Game.Step.SteppedPlayer(ref: refPath, card: card)
                }
                let currentStep = Game.Step(index: index, steppedPlayers: steppedPlayers)

                let sortedPlayers = players.sorted(by: { $0.playerRef < $1.playerRef })

                let marksKeysValues = snapshotData
                    .filter({ $0.key.contains(FieldsKeys.marks.rawValue) })
                    .map { elem -> (key: String, value: [Game.Mark]) in
                        let playerId = elem.key.components(separatedBy: "_")[1]
                        let playerMarksData = elem.value as? [[String: Any]] ?? []
                        let playerMarks = playerMarksData.map({ playerMarkData -> Game.Mark in
                            let player: String = (playerMarkData[FieldsKeys.player.rawValue] as? DocumentReference)?.documentID ?? .empty
                            let liked: Bool = playerMarkData[FieldsKeys.liked.rawValue] as? Bool ?? false
                            let card: String = playerMarkData[FieldsKeys.card.rawValue] as? String ?? .empty
                            return Game.Mark(player: player, liked: liked, card: card)
                        })
                        return (key: playerId, value: playerMarks)
                    }
                let marks = Dictionary(uniqueKeysWithValues: marksKeysValues)

                let game = Game(
                    id: snapshot.documentID,
                    players: sortedPlayers,
                    situations: situations,
                    currentStep: currentStep,
                    marks: marks
                )
                strongSelf.currentGameId = game.id
                handler(game)
            }
    }

    func quitFromGame(withId gameId: String, _ handler: @escaping (Bool) -> Void) {
        let userId = UserService.shared.getUserId()
        let currentGameRef = db
            .collection(CollectionsKeys.games.rawValue)
            .document(gameId)

        db.runTransaction { [weak self] transaction, _ in
            guard let document = try? transaction.getDocument(currentGameRef),
                  let documentData = document.data(),
                  let playersData = documentData[FieldsKeys.players.rawValue] as? [[String: Any]] else { return nil }

            guard playersData.count > 1 else {
                self?.removeGame(withId: gameId, handler: handler)
                return nil
            }
            let playerToRemove = playersData.first { playerData -> Bool in
                let ref = playerData[FieldsKeys.ref.rawValue] as? DocumentReference
                let playerId = ref?.documentID ?? .empty
                return playerId == userId
            }
            let steppedPlayersData: [[String: Any]] = documentData[FieldsKeys.steppedPlayers.rawValue] as? [[String: Any]] ?? []
            let steppedPlayerToRemove = steppedPlayersData.first { steppedPlayerData -> Bool in
                let ref = steppedPlayerData[FieldsKeys.ref.rawValue] as? DocumentReference
                let playerId = ref?.documentID ?? .empty
                return playerId == userId
            }

            guard let playerToRemove = playerToRemove else { return nil }
            let playersNewData = [
                FieldsKeys.players.rawValue: FieldValue.arrayRemove([playerToRemove])
            ]
            transaction.updateData(playersNewData, forDocument: currentGameRef)

            if let steppedPlayerToRemove = steppedPlayerToRemove {
                let steppedPlayersNewData = [
                    FieldsKeys.steppedPlayers.rawValue: FieldValue.arrayRemove([steppedPlayerToRemove])
                ]
                transaction.updateData(steppedPlayersNewData, forDocument: currentGameRef)
            }

            return nil
        } completion: { [weak self] transaction, pointer in
            if pointer == nil {
                self?.currentGameId = nil
                handler(true)
            } else {
                handler(false)
            }
        }
    }

    func setOnlineInCurrentGame(_ isOnline: Bool) {
        guard let currentGameId = currentGameId,
              let userId = UserService.shared.getUserId() else { return }

        let currentGameRef = db
            .collection(CollectionsKeys.games.rawValue)
            .document(currentGameId)

        db.runTransaction { transaction, _ in
            guard let document =  try? transaction.getDocument(currentGameRef),
                  let documentData = document.data(),
                  let oldPlayers = documentData[FieldsKeys.players.rawValue] as? [[String: Any]] else { return nil }
            let currentPlayerIndex = oldPlayers.firstIndex { oldPlayerData -> Bool in
                let playerRef = oldPlayerData[FieldsKeys.ref.rawValue] as? DocumentReference
                guard let playerId = playerRef?.documentID else { return false }
                return playerId == userId
            }

            guard let currentPlayerIndex = currentPlayerIndex else { return nil }
            let oldPlayer = oldPlayers[currentPlayerIndex]
            var newPlayer = oldPlayer
            newPlayer[FieldsKeys.isOnline.rawValue] = isOnline

            transaction.updateData([
                FieldsKeys.players.rawValue: FieldValue.arrayRemove([oldPlayer])
            ], forDocument: currentGameRef)
            transaction.updateData([
                FieldsKeys.players.rawValue: FieldValue.arrayUnion([newPlayer])
            ], forDocument: currentGameRef)

            return nil
        } completion: { _, _ in }

    }

    func enterLastLobbie() {
        guard let lastLobbieId = lastLobbieId else {
            return
        }
        enterInLobbie(lobbieId: lastLobbieId)
    }


    func makeStep(
        gameId: String,
        card: String,
        handler: (() -> Void)?
    ) {
        guard let userId = UserService.shared.getUserId() else { return }
        let currentGameRef = db
            .collection(CollectionsKeys.games.rawValue)
            .document(gameId)
        let currentPlayerRef = db.collection(CollectionsKeys.players.rawValue).document(userId)

        db.runTransaction { transaction, _ in
            guard let document = try? transaction.getDocument(currentGameRef),
                  let documentData = document.data(),
                  let playersData = documentData[FieldsKeys.players.rawValue] as? [[String: Any]] else { return nil }
            let steppedPlayersData = documentData[FieldsKeys.steppedPlayers.rawValue] as? [[String: Any]] ?? []
            guard !steppedPlayersData.compactMap({ ($0[FieldsKeys.ref.rawValue] as? DocumentReference)?.documentID }).contains(userId) else { return nil }

            let newSteppedPlayer: [String: Any] = [
                FieldsKeys.ref.rawValue: currentPlayerRef,
                FieldsKeys.card.rawValue: card
            ]

            let newData: [String: Any] = [
                FieldsKeys.steppedPlayers.rawValue: FieldValue.arrayUnion([newSteppedPlayer])
            ]
            let newDataIncrement: [String: Any] = [
                FieldsKeys.index.rawValue: FieldValue.increment(Int64(1))
            ]

            guard let oldPlayerData = playersData.first(where: { ($0[FieldsKeys.ref.rawValue] as? DocumentReference) == currentPlayerRef }) else { return nil }
            let oldHand = oldPlayerData[FieldsKeys.hand.rawValue] as? [String] ?? []
            var newPlayerData = oldPlayerData
            var newHand = oldHand
            newHand.removeAll(where: { $0 == card })
            newPlayerData[FieldsKeys.hand.rawValue] = newHand

            let shouldIncrementIndex = playersData.count - 1 == steppedPlayersData.count
            transaction.updateData(newData, forDocument: currentGameRef)
            if shouldIncrementIndex {
                transaction.updateData(newDataIncrement, forDocument: currentGameRef)
            }

            transaction.updateData([
                FieldsKeys.players.rawValue: FieldValue.arrayRemove([oldPlayerData])
            ], forDocument: currentGameRef)
            transaction.updateData([
                FieldsKeys.players.rawValue: FieldValue.arrayUnion([newPlayerData])
            ], forDocument: currentGameRef)
            return nil
        } completion: { _, _ in
            handler?()
        }
    }


    func setMark(toCard card: String, liked: Bool) {
        guard let currentGameId = currentGameId,
              let userId = UserService.shared.getUserId() else { return }
        let currentGameRef = db
            .collection(CollectionsKeys.games.rawValue)
            .document(currentGameId)
        let currentPlayerRef = db
            .collection(CollectionsKeys.players.rawValue)
            .document(userId)

        db.runTransaction { transaction, _ in
            guard let gameDocument = try? transaction.getDocument(currentGameRef),
            let gameData = gameDocument.data() else { return nil }

            let newMark: [String: Any] = [
                FieldsKeys.card.rawValue: card,
                FieldsKeys.player.rawValue: currentPlayerRef,
                FieldsKeys.liked.rawValue: liked
            ]

            let myMarksKey = FieldsKeys.marks.rawValue + userId
            if let myMarks = gameData[myMarksKey] as? [[String: Any]] {
                if let markToRemove = myMarks
                    .compactMap({ $0[FieldsKeys.card.rawValue] as? String })
                    .first(where: { $0 == card }) {
                    transaction.updateData([myMarksKey: FieldValue.arrayRemove([markToRemove])], forDocument: currentGameRef)
                }
                transaction.updateData([myMarksKey: FieldValue.arrayUnion([newMark])], forDocument: currentGameRef)
            } else {
                transaction.setData([myMarksKey: [newMark]], forDocument: currentGameRef)
            }
            return nil
        } completion: { _, _ in }
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
    case player
    case players
    case hand
    case isOnline
    case ref
    case steppedPlayers
    case card
    case index = "currentStepIndex"
    case currentStep
    case gameId
    case marks = "marks_"
    case liked
}
