//
//  DigiIDLegacySites.swift
//  DigiByte
//
//  Created by Julian Jäger on 21.07.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import Foundation

fileprivate let DIGI_ID_LEGACY_PAGES_SEPERATOR = "|∆|"

class DigiIDLegacySites {
    var sites: [String] = {
        return UserDefaults.legacyDigiIdSites.components(separatedBy: DIGI_ID_LEGACY_PAGES_SEPERATOR).filter({ $0 != ""
        })
    }()
    
    func save() {
        UserDefaults.legacyDigiIdSites = sites.filter({ $0 != "" }).joined(separator: DIGI_ID_LEGACY_PAGES_SEPERATOR)
    }
    
    func test(url: URL?) -> Bool {
        guard let url = url, let host = url.host else { return false }
        return lsites.contains(host.lowercased())
    }
    
    func test(string: String) -> Bool {
        return lsites.contains(string.lowercased())
    }
    
    private var lsites: [String] {
        return sites.map({ $0.lowercased() })
    }
    
    static var `default`: DigiIDLegacySites = {
        return DigiIDLegacySites()
    }()
    
    private init() {
        
    }
}
