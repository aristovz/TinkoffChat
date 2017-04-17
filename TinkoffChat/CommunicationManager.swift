//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 09.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

var manager: CommunicationManager!

struct Peer {
    var peerID: MCPeerID?
    var name: String?
    var messages = [Message]()
    var online: Bool
    var hasUnreadMessage: Bool
    var session: MCSession?
    
    var id: String? {
        get {
            return self.peerID?.displayName
        }
    }
    
    var lastMessage: Message? {
        get {
            return messages.max { mes1, mes2 in mes1.date < mes2.date }
        }
    }
    
    mutating func setSession(session: MCSession) {
        self.session = session
    }
}

struct Message {
    enum MessageType: Int {
        case Incoming = 0
        case Outgoing = 1
    }
    
    var text: String
    var date: Date
    var type: MessageType?
}

@objc protocol CommunicationManagerDelegate: class {
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
    
    @objc optional func didFoundUser(userID: String, userName: String?)
    @objc optional func didLostUser(userID: String)
    @objc optional func failedToStartBrowsingForUsers(error: Error)
    @objc optional func failedToStartAdvertising(error: Error)
}

class CommunicationManager: NSObject {
    var foundedPeers = [Peer]()
    
    weak var delegate: CommunicationManagerDelegate?
    
    var communicator: MultipeerCommunicator!
    
    init(delegate: CommunicationManagerDelegate) {
        super.init()
        
        self.delegate = delegate
        
        communicator = MultipeerCommunicator(delegate: self)
    }
    
    func start() {
        communicator.browser.startBrowsingForPeers()
        communicator.advertiser.startAdvertisingPeer()
    }
    
    func stop() {
        communicator.browser.stopBrowsingForPeers()
        communicator.advertiser.stopAdvertisingPeer()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())) {
        for k in 0..<manager.foundedPeers.count {
            if manager.foundedPeers[k].id == userID {
                let message = Message(text: string, date: Date(), type: .Outgoing)
                
                manager.foundedPeers[k].messages.append(message)
                manager.foundedPeers[k].hasUnreadMessage = true
            }
        }
        
        communicator.sendMessage(string: string, to: userID, completionHandler: completionHandler)
    }
    
    func getPeer(userID: String) -> Peer? {
        for k in 0..<manager.foundedPeers.count {
            if manager.foundedPeers[k].id == userID {
                return manager.foundedPeers[k]
            }
        }
        
        return nil
    }
    
    func invitePeer(peer: MCPeerID) {
        for k in 0..<manager.foundedPeers.count {
            if manager.foundedPeers[k].id == peer.displayName {
                manager.foundedPeers[k].session = communicator.invitePeer(peer: peer)
                return
            }
        }
    }
}

extension CommunicationManager: CommunicatorDelegate {
    func failedToStartBrowsingForUsers(error: Error) {
        delegate?.failedToStartBrowsingForUsers?(error: error)
    }

    func failedToStartAdvertising(error: Error) {
        delegate?.failedToStartAdvertising?(error: error)
    }
    
    func didFoundUser(peer: MCPeerID, userName: String?) {
        guard foundedPeers.first(where: {$0.id == peer.displayName}) == nil else {
            return
        }
        
        let peer = Peer(peerID: peer, name: userName, messages: [], online: true, hasUnreadMessage: false, session: nil)
        foundedPeers.append(peer)
        
        delegate?.didFoundUser?(userID: peer.id!, userName: userName)
    }
    
    func didLostUser(userID: String) {
        if let index = foundedPeers.index(where: { $0.id == userID }) {
            foundedPeers.remove(at: index)
        }
        
        delegate?.didLostUser?(userID: userID)
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        for k in 0..<manager.foundedPeers.count {
            if manager.foundedPeers[k].id == fromUser {
                let message = Message(text: text, date: Date(), type: .Incoming)
                
                manager.foundedPeers[k].messages.append(message)
                manager.foundedPeers[k].hasUnreadMessage = true
            }
        }
        
        delegate?.didReceiveMessage(text: text, fromUser: fromUser, toUser: toUser)
    }
}
