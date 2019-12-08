//
//  AssetHelper.swift
//  DigiByte
//
//  Created by Julian Jäger on 01.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import Foundation
import Storez

// http://api.digiassets.net/assetmetadata/Ua4MneDXdFP8eNEiN1fzJE8AjfuJ5RU3bBuRvq/00419a512d02265013d127baba6749798603b33604a53c878ed90692637be1a0:0

// https://forums.swift.org/t/using-unsafe-pointers-to-manipulate-a-json-encoder/11013/6
public enum JSON : Codable {
    case null
    case number(NSNumber)
    case string(String)
    case array([JSON])
    case dictionary([String : JSON])
    
    public var value: Any? {
        switch self {
        case .null: return nil
        case .number(let number): return number
        case .string(let string): return string
        case .array(let array): return array.map { $0.value }
        case .dictionary(let dictionary): return dictionary.mapValues { $0.value }
        }
    }
    
    public init?(_ value: Any?) {
        guard let value = value else {
            self = .null
            return
        }
        
        if let int = value as? Int {
            self = .number(NSNumber(value: int))
        } else if let double = value as? Double {
            self = .number(NSNumber(value: double))
        } else if let string = value as? String {
            self = .string(string)
        } else if let array = value as? [Any] {
            var mapped = [JSON]()
            for inner in array {
                guard let inner = JSON(inner) else {
                    return nil
                }
                
                mapped.append(inner)
            }
            
            self = .array(mapped)
        } else if let dictionary = value as? [String : Any] {
            var mapped = [String : JSON]()
            for (key, inner) in dictionary {
                guard let inner = JSON(inner) else {
                    return nil
                }
                
                mapped[key] = inner
            }
            
            self = .dictionary(mapped)
        } else {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else {
            self = .null
            return
        }
        
        if let int = try container.decodeIfMatched(Int.self) {
            self = .number(NSNumber(value: int))
        } else if let double = try container.decodeIfMatched(Double.self) {
            self = .number(NSNumber(value: double))
        } else if let string = try container.decodeIfMatched(String.self) {
            self = .string(string)
        } else if let array = try container.decodeIfMatched([JSON].self) {
            self = .array(array)
        } else if let dictionary = try container.decodeIfMatched([String : JSON].self) {
            self = .dictionary(dictionary)
        } else {
            throw DecodingError.typeMismatch(JSON.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode JSON as any of the possible types."))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .null: try container.encodeNil()
            case .number(let number):
                if number.objCType.pointee == 0x64 /* 'd' */ {
                    try container.encode(number.doubleValue)
                } else {
                    try container.encode(number.intValue)
                }
            case .string(let string): try container.encode(string)
            case .array(let array): try container.encode(array)
            case .dictionary(let dictionary): try container.encode(dictionary)
        }
    }
}

fileprivate extension SingleValueDecodingContainer {
    func decodeIfMatched<T : Decodable>(_ type: T.Type) throws -> T? {
        do {
            return try self.decode(T.self)
        } catch DecodingError.typeMismatch {
            return nil
        }
    }
}

struct UrlModel: Codable {
    let name: String?
    let url: String?
    let mimeType: String?
    let dataHash: String?
}

struct AssetProperties: Codable {
    let assetName: String?
    let issuer: String?
    let description: String?
    let urls: [UrlModel]?
    let userData: JSON?
}

struct AssetIssuanceMetadataModel: Codable {
    let data: AssetProperties?
}

struct AssetModel: Codable {
    let assetId: String
    let firstBlock: Int
//    let someUtxo: String
    
    let divisibility: Int
    let aggregationPolicy: String
    let lockStatus: Bool
    let numOfIssuance: Int
    let numOfTransfers: Int
    let totalSupply: Int
    let numOfHolders: Int
    
    let issuanceTxid: String?
    let issueAddress: String?
    let metadataOfIssuence: AssetIssuanceMetadataModel?
    
    let sha2Issue: String?
    
    func getAssetInfo() -> String {
        var res = [String]()
        
        res.append("\(S.Assets.totalSupply): \(totalSupply)")
        res.append("\(S.Assets.numberOfHolders): \(numOfHolders)")
        res.append("\(S.Assets.lockStatus): \(lockStatus ? S.Assets.locked : S.Assets.unlocked)")
        
        return res.joined(separator: ", ")
    }
    
    func getIssuer() -> String {
        guard let meta = metadataOfIssuence else { return "Asset with no metadata" }
        guard let data = meta.data else { return "Asset with no data" }
        return data.issuer ?? "Asset without issuer"
    }
    
    func getAssetName() -> String {
        guard let meta = metadataOfIssuence else { return "Asset with no metadata" }
        guard let data = meta.data else { return "Asset with no data" }
        return data.assetName ?? "Asset without name"
    }
    
    func getImage() -> UrlModel? {
        guard let urls = getURLs() else { return nil }
        if let index = urls.firstIndex(where: { $0.name == "icon" }) {
            return urls[index]
        } else if let index = urls.firstIndex(where: { $0.name == "large_icon" }) {
            return urls[index]
        } else {
            return nil
        }
    }
    
    func getBigImage() -> UrlModel? {
        guard let urls = getURLs() else { return nil }
        if let index = urls.firstIndex(where: { $0.name == "large_icon" }) {
            return urls[index]
        } else if let index = urls.firstIndex(where: { $0.name == "icon" }) {
            return urls[index]
        } else {
            return nil
        }
    }
    
    func getDescription() -> String? {
        guard let meta = metadataOfIssuence else { return nil }
        guard let data = meta.data else { return nil }
        return data.description
    }
    
    private func getURLs() -> [UrlModel]? {
        guard let meta = metadataOfIssuence else { return nil }
        guard let data = meta.data else { return nil }
        guard let urls = data.urls else { return nil }
        return urls
    }
    
    static func dummy() -> AssetModel {
        return AssetModel(assetId: "?", firstBlock: 0, divisibility: 0, aggregationPolicy: "?", lockStatus: false, numOfIssuance: 0, numOfTransfers: 0, totalSupply: 0, numOfHolders: 0, issuanceTxid: nil, issueAddress: nil, metadataOfIssuence: nil, sha2Issue: nil)
    }
}

struct AssetInfoModel: Codable {
    let assetId: String
    let amount: Int
    let issueTxid: String
}

struct AssetUtxoModel: Codable {
    let address: String
    let index: Int
    let txid: String
    let value: Int // Satoshis
    let assets: [AssetInfoModel]
}

// /addressinfo endpoint response
struct AddressInfoModel: Codable {
    let address: String
    let utxos: [AssetUtxoModel]
}

class DigiAssetsUrlWrapper {
    private static let DIGIASSETS_HOST_1: String = "https://api.digiassets.net/v3/"
    
    private var urls: [String] = [
        DigiAssetsUrlWrapper.DIGIASSETS_HOST_1,
    ]
    
    var currentURL: String = ""
    
    init() {
        assert(urls.count > 0)
        self.currentURL = urls[0]
    }
    
    func nextUrl(oldURL: String) {
        // Change will be seen by all operations.
        // Change will be dependant on the old URL
        guard oldURL == currentURL else { return }
        guard let index = urls.firstIndex(of: oldURL) else { return }
        let newIndex = index + 1;
        currentURL = urls[newIndex % urls.count]
    }
}

class FetchAddressOperation: Operation {
    private let state: AssetResolver.AssetResolveState
    private let urlWrapper: DigiAssetsUrlWrapper
    
    init(url: DigiAssetsUrlWrapper, state: AssetResolver.AssetResolveState) {
        self.urlWrapper = url
        self.state = state
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    var _isFinished: Bool = false
    var _isExecuting: Bool = false
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        
        get {
            return _isFinished
        }
    }
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
        
        get {
            return _isExecuting
        }
    }
    
    func execute() {
        let session = URLSession.shared
        let urlStr = urlWrapper.currentURL
        let url = URL(string: "\(urlStr)/addressinfo/\(state.walletAddress)")!
        
        let dataTask = session.dataTask(with: url) { (data, resp, err) in
            if err != nil {
                self.urlWrapper.nextUrl(oldURL: urlStr)
                self.isExecuting = false
                self.isFinished = true
                self.state.failed = true
                return
            }
            
            guard let data = data else {
                self.isExecuting = false
                self.isFinished = true
                self.state.failed = true
                return
            }
            
            guard let addressInfoModel = try? JSONDecoder().decode(AddressInfoModel.self, from: data) else {
                self.isExecuting = false
                self.isFinished = true
                return
            }
            
            self.state.addressInfoModel = addressInfoModel
            
            // Create new sub operation queue
            let subqueue = OperationQueue()
            subqueue.maxConcurrentOperationCount = 3
            
            // Process all utxos that contain assets
            addressInfoModel.utxos.forEach { (utxoModel) in
                utxoModel.assets.forEach { (assetInfoModel) in
                    guard utxoModel.address == self.state.walletAddress else { return }
                    
                    if self.state.txIDFilter != nil, self.state.txIDFilter != utxoModel.txid { return }
                    
                    print("AssetResolver: Adding MetadataOperation for \(assetInfoModel.assetId) (txID = \(utxoModel.txid):\(utxoModel.index))")
                    let subOperation = FetchMetadataOperation(url: self.urlWrapper, state: self.state, assetID: assetInfoModel.assetId, txID: utxoModel.txid, index: utxoModel.index)
                    subqueue.addOperation(subOperation)
                }
            }
            
            subqueue.waitUntilAllOperationsAreFinished()
            print("AssetResolver: Finished FetchAddressOperation for \(self.state.walletAddress)")
            self.isExecuting = false
            self.isFinished = true
        }
        
        dataTask.resume()
    }
    
    override func start() {
        isExecuting = true
        execute()
    }
}

class FetchMetadataOperation: Operation {
    private let state: AssetResolver.AssetResolveState
    private let urlWrapper: DigiAssetsUrlWrapper
    
    private let assetID: String
    private let txID: String
    private let index: Int
    
    init(url: DigiAssetsUrlWrapper, state: AssetResolver.AssetResolveState, assetID: String, txID: String, index: Int) {
        self.urlWrapper = url
        self.state = state
        
        self.assetID = assetID
        self.txID = txID
        self.index = index
    }
    
    override var isAsynchronous: Bool { return true }
    var _isFinished: Bool = false
    var _isExecuting: Bool = false
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        
        get { return _isFinished }
    }
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
        
        get { return _isExecuting }
    }
    
    func execute() {
        let session = URLSession(configuration: .default)
        let urlStr = urlWrapper.currentURL
        
        let url = URL(string: "\(urlStr)/assetmetadata/\(self.assetID)/\(self.txID):\(self.index)")!
        
        let dataTask = session.dataTask(with: url) { (data, resp, err) in
            if err != nil {
                print("AssetResolver: error in response for asset: \(self.assetID): \(err!)")
                self.urlWrapper.nextUrl(oldURL: urlStr)
                self.isExecuting = false
                self.isFinished = true
                self.state.failed = true
                return
            }
            
            guard let data = data else {
                print("AssetResolver: No data in response for asset: \(self.assetID)")
                self.isExecuting = false
                self.isFinished = true
                self.state.failed = true
                return
            }
                
            if let decodedAssetModel = try? JSONDecoder().decode(AssetModel.self, from: data) {
                self.state.resolvedModels.append(decodedAssetModel)
                print("AssetResolver: resolved assetModel: \(decodedAssetModel.assetId)")
                self.state.failed = false
                self.state.resolved = true
                
            } else {
                print("AssetResolver: could not resolve asset: \(self.assetID)/\(self.txID):\(self.index)")
                self.state.failed = true
            }
            
            self.isExecuting = false
            self.isFinished = true
        }
        
        dataTask.resume()
    }
    
    override func start() {
        guard !state.failed, state.addressInfoModel != nil else {
            print("AssetResolver: FetchMetadataOperation for assetID=\(assetID), txID=\(txID):\(index) can not be launched")
            isFinished = true
            return
        }
        
        isExecuting = true
        execute()
    }
}

class AssetResolver {
    private var addr = Set<String>()
    private let callback: ([AssetResolveState]) -> Void
    private let queue = OperationQueue()
    private let filter: String?
    
    class AssetResolveState {
        let walletAddress: String
        var resolved: Bool = false
        var failed: Bool = false
        
        var txIDFilter: String?
        
        var addressInfoModel: AddressInfoModel? = nil
        var resolvedModels: [AssetModel] = []
        
        init(address: String, txIDFilter: String? = nil) {
            self.txIDFilter = txIDFilter
            self.walletAddress = address
        }
    }
    
    var states = [AssetResolveState]()
    var stateMap = [String: AssetResolveState]()
    
    init(publicWalletAddresses: [String], txIDFilter: String?, callback: @escaping ([AssetResolveState]) -> Void) {
        self.callback = callback
        self.filter = txIDFilter
        
        publicWalletAddresses.filter({ $0 != "" }).forEach({
            self.addr.insert($0)
        })
    
        states.reserveCapacity(self.addr.count)
        self.addr.forEach { (address) in
            let state = AssetResolveState(address: address, txIDFilter: txIDFilter)
            states.append(state)
            stateMap[address] = state
        }
        
        configureQueue()
        launchFetchers()
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
    
    private func configureQueue() {
        queue.maxConcurrentOperationCount = 2
    }
    
    private func launchFetchers() {
        let urlWrapper = DigiAssetsUrlWrapper()
        
        let completionOperation = BlockOperation {
            print("AssetResolver: All operations completed")
            self.callback(self.states)
        }
        
        for address in self.addr {
            let state = self.stateMap[address]!
            print("AssetResolver: Launching FetchAddressOperation for walletAddress = \(address) (filter=\(state.txIDFilter ?? "none"))")
            let fetchAddressOperation = FetchAddressOperation(url: urlWrapper, state: state)
            completionOperation.addDependency(fetchAddressOperation)
            queue.addOperation(fetchAddressOperation)
        }
        
        queue.addOperation(completionOperation)
    }
}

class AssetNotificationCenter {
    static let instance = NotificationCenter()
    
    enum notifications {
        static let newAssetData = Notification.Name("newAssetData")
        static let fetchingAssets = Notification.Name("fetchingAssets")
        static let fetchedAssets = Notification.Name("fetchedAssets")
        static let assetsRecalculated = Notification.Name("assetsRecalculated")
    }
    
    private init() {}
}

class AssetHelper {
    typealias AssetBalance = Int
    private static let store = UserDefaultsStore(suite: nil)
    
    private static var needsReindex = true
    private static var _allAssets = [String]()
    private static var _allBalances = [String: AssetBalance]()
    static var allBalances: [String: AssetBalance] {
        reindexAssetsIfNeeded()
        return _allBalances
    }
    static var allAssets: [String] {
        reindexAssetsIfNeeded()
        return _allAssets
    }
    
    private static var assetAddressList = pullAssetAddressList()
    private static var needsAddressListUpdate: Bool = false
    private static var assetAddressListKey = "da_allAddresses"
    
    private static func reindexAssetsIfNeeded() {
        guard needsReindex else { return }
        _allAssets = []
        _allBalances = [:]
        
        assetAddressList.forEach { (address) in
            guard let infoModel = getAddressInfoModel(address: address) else { return }
            infoModel.utxos.forEach { utxo in
                utxo.assets.forEach { infoModel in
                    _allBalances[infoModel.assetId] = (_allBalances[infoModel.assetId] ?? 0) + infoModel.amount
                }
            }
        }
        
        _allAssets = _allBalances.keys.map({ return $0 })
        needsReindex = false
        
        AssetNotificationCenter.instance.post(name: AssetNotificationCenter.notifications.assetsRecalculated, object: nil)
    }
    
    private static func pullAssetAddressList() -> [String] {
        let key = Key<GlobalNamespace, [String]>(id: assetAddressListKey, defaultValue: [])
        let ret: [String] = store.get(key)
        return ret
    }
    
    private static func putAssetAddressList() {
        let key = Key<GlobalNamespace, [String]>(id: assetAddressListKey, defaultValue: [])
        store.set(key, value: assetAddressList)
        needsAddressListUpdate = false
    }
    
    static func getAssetModel(assetID: String) -> AssetModel? {
        // ToDo: build and check cache
        let key = Key<GlobalNamespace, AssetModel?>(id: assetID, defaultValue: nil)
        return store.get(key)
    }
    
    static func getAddressInfoModel(address: String) -> AddressInfoModel? {
        let key = Key<GlobalNamespace, AddressInfoModel?>(id: address, defaultValue: nil)
        return store.get(key)
    }
    
    static func saveAssetModel(assetModel: AssetModel) {
        let key = Key<GlobalNamespace, AssetModel?>(id: assetModel.assetId, defaultValue: nil)
        store.set(key, value: assetModel)
        needsReindex = true
    }
    
    static func saveAddressInfoModel(addressInfoModel: AddressInfoModel) {
        let address = addressInfoModel.address
        
        if !assetAddressList.contains(address) {
            assetAddressList.append(address)
            needsAddressListUpdate = true
        }
        
        let key = Key<GlobalNamespace, AddressInfoModel?>(id: address, defaultValue: nil)
        store.set(key, value: addressInfoModel)
        needsReindex = true
    }
    
    static func getAssetUtxos(for tx: Transaction) -> [AssetUtxoModel]? {
        let txHash = tx.hash
        guard let address = tx.toAddress else { return [] }
        
        guard let model = getAddressInfoModel(address: address) else { return nil }
        return model.utxos.filter { utxo -> Bool in
            return utxo.txid == txHash
        }
    }
    
    static func hasAllAssetModels(for utxoModel: AssetUtxoModel) -> Bool {
        return utxoModel.assets.reduce(true) { (res, model) -> Bool in
            if !res { return false }
            return getAssetModel(assetID: model.assetId) != nil
        }
    }
    
    static func resolveAsset(for addresses: [String], txIDFilter: String? = nil, callback: (([AssetUtxoModel]) -> Void)?) -> AssetResolver? {
        AssetNotificationCenter.instance.post(name: AssetNotificationCenter.notifications.fetchingAssets, object: nil)
        let resolver = AssetResolver(publicWalletAddresses: addresses, txIDFilter: txIDFilter) { states in
            states.forEach { state in
                guard state.resolved, !state.failed else { return }
                state.resolvedModels.forEach({ saveAssetModel(assetModel: $0) })
                saveAddressInfoModel(addressInfoModel: state.addressInfoModel!)
            }
            
            var relevantItems = [AssetUtxoModel]()
                
            states.forEach { state in
                // Only add resolved assets
                guard state.resolved, !state.failed else { return }
                guard let infoModel = state.addressInfoModel else { return }
                
                // Only add the infomodel if it was requested
                relevantItems.append(contentsOf: infoModel.utxos.filter({ txIDFilter == nil || $0.txid == txIDFilter }))
            }
            
            if needsAddressListUpdate {
                putAssetAddressList()
            }
            
            DispatchQueue.main.async {
                AssetNotificationCenter.instance.post(name: AssetNotificationCenter.notifications.newAssetData, object: nil)
                AssetNotificationCenter.instance.post(name: AssetNotificationCenter.notifications.fetchedAssets, object: nil)
                callback?(relevantItems)
            }
        }
        
        return resolver
    }
    
    static func resolveAsset(for tx: Transaction, callback: (([AssetUtxoModel]) -> Void)?) -> AssetResolver? {
        guard let address = tx.toAddress else {
            callback?([])
            return nil
        }
        
        return resolveAsset(for: [address], txIDFilter: tx.hash, callback: callback)
    }
    
    static func resolveAssets(for transactions: [Transaction], callback: ((Bool) -> Void)?) -> AssetResolver? {
        var addresses = [String]()
        
        transactions.forEach({ (tx) in
            if tx.isAssetTx, let address = tx.toAddress {
                // Append address and load 'dem DigiAssets
                if !addresses.contains(address) { addresses.append(address) }
            } else {
                // Ignore transaction as it does not contain an asset
                // ...
            }
        })
        
        // No assets to be fetched, return existing assets
        if addresses.count == 0 {
            callback?(false)
            return nil
        }
        
        return resolveAsset(for: addresses) { models in
            callback?(models.count > 0)
        }
        
//        AssetNotificationCenter.instance.post(name: AssetNotificationCenter.notifications.fetchingAssets, object: nil)
//
//        let resolver = AssetResolver(publicWalletAddresses: addresses, txIDFilter: nil) { states in
//            states.forEach { state in
//                guard state.resolved, !state.failed else { return }
//                state.resolvedModels.forEach({ saveAssetModel(assetModel: $0) })
//                saveAddressInfoModel(addressInfoModel: state.addressInfoModel!)
//            }
//
//            var relevantItems = [AssetUtxoModel]()
//
//            states.forEach { state in
//                // Only add resolved assets
//                guard state.resolved, !state.failed else { return }
//                guard let infoModel = state.addressInfoModel else { return }
//
//                // Add all utxos to result
//                relevantItems.append(contentsOf: infoModel.utxos)
//            }
//
//            DispatchQueue.main.async {
//                AssetNotificationCenter.instance.post(name: AssetNotificationCenter.notifications.newAssetData, object: nil)
//                AssetNotificationCenter.instance.post(name: AssetNotificationCenter.notifications.fetchedAssets, object: nil)
//                callback?(relevantItems.count > 0)
//            }
//        }
//
//        return resolver
    }
    
    static func reset() {
        store.clear()
    }
}
