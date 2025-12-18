//
//  NetworkConstants.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 04/12/25.
//

import Foundation
import Alamofire

func isConnectedToInternet() -> Bool {
    if let value = NetworkReachabilityManager()?.isReachable {
        return value
    }
    return true
}

func isReachableUsingWifi() -> Bool {
    if let value = NetworkReachabilityManager()?.isReachableOnEthernetOrWiFi {
        return value
    }
    return true
}

func isReachableUsingCellular() -> Bool {
    if let value = NetworkReachabilityManager()?.isReachableOnCellular {
        return value
    }
    return true
}
