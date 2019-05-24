//
//  GithubService.swift
//  App
//
//  Created by Denis Chagin on 02/05/2019.
//

import Foundation
import Vapor

enum GithubServiceError: Error {
    case connectionError
    case requestError
}

struct GithubInstallationToken: Content {
    let token: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case token
    }
}

struct CheckRunCreateRequest: Content {
    let name: String
    let headSha: String

    enum CodingKeys: String, CodingKey {
        case headSha = "head_sha"
        case name
    }
}

class GithubService {

    let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let installationID: Int

    var httpClient: EventLoopFuture<HTTPClient> {
        return HTTPClient.connect(scheme: .https,
                                  hostname: "api.github.com",
                                  on: eventLoop)
    }

    init(installationID: Int) {
        self.installationID = installationID
    }

    func getInstallationToken() -> Result<GithubInstallationToken, Error> {
        guard let jwtToken = try? tokenService.createToken().get() else {
            return .failure(GithubServiceError.requestError)
        }

        let headers = makeInstallationTokenRequestHeader(jwtToken: jwtToken)

        let httpRequest = HTTPRequest(method: .POST,
                                      url: "/app/installations/\(installationID)/access_tokens",
                                      headers: HTTPHeaders(headers))

        let tokenResponse = httpClient
            .flatMap { client in
                return client.send(httpRequest)
            }
            .map { response -> Data in
                print(response.body)
                guard let responseData = response.body.data else {
                    throw GithubServiceError.requestError
                }
                return responseData
            }
            .map { rawData -> GithubInstallationToken in
                let decoder = JSONDecoder()
                if #available(OSX 10.12, *) {
                    decoder.dateDecodingStrategy = .iso8601
                }

                return try decoder.decode(GithubInstallationToken.self, from: rawData)
            }

        return Result { try tokenResponse.wait() }
    }

    func createCheckRun(repositoryName: String, checkRun: CheckRunCreateRequest) -> Result<Void, Error> {
        guard let installationToken = try? getInstallationToken().get() else {
            return .failure(GithubServiceError.requestError)
        }

        let headers = makeCheckRunRequestHeader(installationToken: installationToken.token)

        let httpRequest = HTTPRequest(method: .POST,
                                      url: "/repos/\(repositoryName)/check-runs",
                                      headers: HTTPHeaders(headers),
                                      body: try! JSONEncoder().encode(checkRun))

        let response = httpClient.flatMap { $0.send(httpRequest) }

        return Result { let _ = try response.wait() }
    }

    func makeInstallationTokenRequestHeader(jwtToken: String) -> [(String, String)] {
        return  [
            ("Accept","application/vnd.github.machine-man-preview+json"),
            ("Authorization", "Bearer \(jwtToken)")
        ]
    }

    func makeCheckRunRequestHeader(installationToken: String) -> [(String, String)] {
        return  [
            ("Accept","application/vnd.github.antiope-preview+json"),
            ("Authorization", "Bearer \(installationToken)")
        ]
    }
}