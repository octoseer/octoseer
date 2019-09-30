//
//  TrialLoader.swift
//  App
//
//  Created by Denis Chagin on 30.09.2019.
//

protocol TrialLoader {

    func loadTrials() -> Result<Void, Error>
}
