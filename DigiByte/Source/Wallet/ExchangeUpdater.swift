//
//  ExchangeUpdater.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-01-27.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation

class ExchangeUpdater : Subscriber {

    //MARK: - Public
    init(store: BRStore, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        store.subscribe(self,
                        selector: { $0.defaultCurrencyCode != $1.defaultCurrencyCode },
                        callback: { state in
                            guard let currentRate = state.rates.first( where: { $0.code == state.defaultCurrencyCode }) else { return }
                            self.store.perform(action: ExchangeRates.setRate(currentRate))
        })
    }
    
    private func bringtToTop(rates: [Rate], symbol: String) -> [Rate] {
        guard let idx = rates.firstIndex(where: { $0.code == symbol }) else {
            return rates
        }
        var rates = rates
        let rate = rates.remove(at: idx)
        rates.insert(rate, at: 0)
        return rates
    }

    func refresh(completion: @escaping () -> Void) {
        walletManager.apiClient?.exchangeRates { [weak self] rates, error in
            guard let myself = self else { completion(); return }
            
            let dgb = Rate(code: "DGB", name: "DigiByte", rate: 1.0)
            
            let currentRate = rates.first( where: { $0.code == myself.store.state.defaultCurrencyCode }) ?? dgb
            
            // add dgb
            var rates = rates
            rates.insert(dgb, at: 0)
            
            // remove bch
            let ratesRemovedBCH = rates.filter { $0.code != "BCH" }
            
            // sort it
            var sorted = ratesRemovedBCH.sorted { (a, b) -> Bool in
                return a.code < b.code
            }
            
            sorted = myself.bringtToTop(rates: sorted, symbol: "DGB")
            sorted = myself.bringtToTop(rates: sorted, symbol:  "LTC")
            sorted = myself.bringtToTop(rates: sorted, symbol: "BTC")
            
            myself.store.perform(action: ExchangeRates.setRates(currentRate: currentRate, rates: sorted))
            
            completion()
        }
    }

    //MARK: - Private
    let store: BRStore
    let walletManager: WalletManager
}
