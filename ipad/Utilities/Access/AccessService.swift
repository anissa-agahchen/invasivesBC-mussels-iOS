//
//  AccessService.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-24.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import Reachability

class AccessService {
    
    public static let AccessRoleID = 5
    public static let shared = AccessService()
    
    public var hasAppAccess: Bool = false
    
    private let reachability =  try! Reachability()
    
    private init() {
        beginReachabilityNotification()
        setAccess()
    }
    
    // Add listener for when recahbility status changes
    private func beginReachabilityNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    // Handle recahbility status change
    @objc func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else {return}
        switch reachability.connection {
        case .wifi:
            setAccess()
        case .cellular:
            setAccess()
        case .none:
            return
        case .unavailable:
            return
        }
    }
    
    private func setAccess() {
        APIRequest.checkAccess { (hasAccess) in
            self.hasAppAccess = hasAccess
            Settings.shared.setUserHasAppAccess(hasAccess: hasAccess)
        }
    }

    public func hasAccess(completion: @escaping(Bool)->Void) {
        if reachability.connection == .unavailable {
            return completion(Settings.shared.userHasAppAccess())
        }
        APIRequest.checkAccess { (hasAccess) in
            self.hasAppAccess = hasAccess
            Settings.shared.setUserHasAppAccess(hasAccess: hasAccess)
            if (!hasAccess) {
                self.sendAccessRequest()
            }
            return completion(hasAccess)
        }
    }
    
    public func sendAccessRequest(completion: ((Bool)->Void)? = nil) {
        APIRequest.sendAccessRequest { (success) in
            print("Access Request created: \(String(describing: success))")
            if let callback = completion {
                return callback(success ?? false)
            }
        }
    }
    
}
