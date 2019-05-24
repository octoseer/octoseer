//
//  JWTTokenService.swift
//  App
//
//  Created by Denis Chagin on 02/05/2019.
//

import Crypto
import JWT

enum JWTTokenServiceError: Error {
    case invalidKeyPath
    case invalidKeyData
    case rawKeyDataEncodingError
}

class JWTTokenService {

    private let privateKey: RSAKey
    private let appID: String
    private let jwtSigner: JWTSigner


    init(privateKey: RSAKey, appID: String) {
        self.privateKey = privateKey
        self.appID = appID
        self.jwtSigner = JWTSigner.rs256(key: privateKey)
    }

    static func from(privateKeyPath: String, appID: String) -> Result<JWTTokenService, Error> {
        guard let keyData = FileManager().contents(atPath: privateKeyPath) else {
            return .failure(JWTTokenServiceError.invalidKeyPath)
        }

        guard let key = try? RSAKey.private(pem: keyData) else { return .failure(JWTTokenServiceError.invalidKeyData) }

        return .success(JWTTokenService(privateKey: key, appID: appID))
    }

    func createToken(with payload: GithubJWTToken) -> Result<String, Error> {
        let rawSignature = Result { try jwtSigner.sign(JWT(header: .init(), payload: payload)) }

        return rawSignature.flatMap { rawData in
            guard let encodedData = String(bytes: rawData, encoding: .utf8) else {
                return .failure(JWTTokenServiceError.rawKeyDataEncodingError)
            }

            return .success(encodedData)
        }
    }

    func createToken() -> Result<String, Error> {
        return createToken(with: .create(for: appID))
    }
}

