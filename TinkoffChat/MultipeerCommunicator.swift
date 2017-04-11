//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 09.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler:((_ success: Bool, _ error: Error?) -> ()))
    weak var delegate: CommunicatorDelegate? { get set }
    var online: Bool { get set }
}

protocol CommunicatorDelegate: class {
    //discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}

class MultipeerCommunicator: NSObject, Communicator {
    static let shared = MultipeerCommunicator()
    
    private let tinkoffServiceType = "tinkoff-chat"
    
    var peer: MCPeerID!
    
    var advertiser : MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    weak var delegate: CommunicatorDelegate?
    var online: Bool = true
    
    var sessions = [String: MCSession]()
    
    private override init() {
        super.init()

        peer = MCPeerID(displayName: UIDevice.current.identifierForVendor!.uuidString)
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: ["userName" : Global.currentUser!.name], serviceType: tinkoffServiceType)
        self.advertiser.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: peer, serviceType: tinkoffServiceType)
        self.browser.delegate = self
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())) {
        let dict = ["eventType": "TextMessage",
                    "messageId": generateMessageId(),
                    "text": string]
        
        if let currentSession = sessions[userID] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                try currentSession.send(jsonData, toPeers: currentSession.connectedPeers, with: .reliable)
            }
            catch {
                completionHandler(false, error)
            }
        }
        
        completionHandler(true, nil)
    }
    
    func invitePeer(userID: String, to session: MCSession) {
        sessions[userID] = session
        
        self.browser.invitePeer(MCPeerID(displayName: userID), to: session, withContext: nil, timeout: 30)
    }
    
    private func generateMessageId() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        
        return string!
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let currentSession = sessions[peerID.displayName] {
            invitationHandler(true, currentSession)
        }
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        delegate?.didFoundUser(userID: peerID.displayName, userName: info?["userName"])
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.didLostUser(userID: peerID.displayName)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
}

