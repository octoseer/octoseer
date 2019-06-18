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
    let id: Int
    let headSha: String

    enum CodingKeys: String, CodingKey {
        case headSha = "head_sha"
        case id
    }
}

struct CheckSuiteID: Content {
    let id: Int
}

struct CheckRun: Content {
    let id: Int
    let headSha: String
    let name: String
    let checkSuite: CheckSuiteID
    let status: String
    let conclusion: String?

    enum CodingKeys: String, CodingKey {
        case headSha = "head_sha"
        case checkSuite = "check_suite"

        case id
        case name
        case conclusion
        case status
    }
}
