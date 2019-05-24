//
//  GithubJWTToken.swift
//  App
//
//  Created by Denis Chagin on 02/05/2019.
//

import JWT
import Vapor

struct GithubJWTToken: JWTPayload {

    var iss: IssuerClaim
    var exp: Int
    var iat: Int


    func verify(using signer: JWTSigner) throws {
    }
}

extension GithubJWTToken {

    static func create(for appID: String) -> GithubJWTToken {
        return GithubJWTToken(iss: .init(value: appID),
                              exp: Int(Date.init(timeIntervalSinceNow: 600).timeIntervalSince1970),
                              iat: Int(Date().timeIntervalSince1970))
    }
}
