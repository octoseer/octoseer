//
//  GithubWebhook.swift
//  App
//
//  Created by Denis Chagin on 02/05/2019.
//

import Vapor

struct GithubWebhook: Content {
    let action: String
    let installation: Installation
    let repository: Repository
    let checkSuite: CheckSuite?
    let checkRun: CheckRun?

    enum CodingKeys: String, CodingKey {
        case checkSuite = "check_suite"
        case checkRun = "check_run"

        case action
        case installation
        case repository
    }
}

struct Repository: Content {
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
    }
}

struct Installation: Content {
    let id: Int
}

struct CheckSuite: Content {
    let headSha: String

    enum CodingKeys: String, CodingKey {
        case headSha = "head_sha"
    }
}

struct CheckRun: Content {
    let id: Int
    let headSha: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case headSha = "head_sha"

        case id
        case name
    }
}
