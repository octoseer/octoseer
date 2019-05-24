//
//  WebhookController.swift
//  App
//
//  Created by Denis Chagin on 02/05/2019.
//

import RxSwift
import Vapor

final class WebhookController {

    func index(_ req: Request) throws -> Future<HTTPStatus> {
        let eventType = req.http.headers["X-Github-Event"]

        print(eventType)

        if eventType.first == "push" { return req.future(.ok) }

        return try req.content.decode(GithubWebhook.self).do { webhook in
            print("TTT")
            DispatchQueue.global().async {
                globalAAA.subject.onNext(webhook)
            }
            print("FFF")
        }.transform(to: .ok)
    }
}

let tokenService = try! JWTTokenService.from(privateKeyPath: "/tmp/app-priv.pem", appID: "27931").get()

class AAA {

    let subject = PublishSubject<GithubWebhook>()
    let bag = DisposeBag()

    init() {
        subject.debug()
            .subscribe(onNext: { webhook in

                if webhook.checkRun != nil {
                    print("CHECK RUN")
                    return
                }

                print("RECEIve")

//                let jwtToken = tokenService.createToken()//createToken(with: .create(for: "27931"))
//                    try? tokenService.flatMap { service in
//                    return service.createToken(with: .create(for: "27931"))
//                    }.get()

//                print("JWT Token", jwtToken)

                let github = GithubService(installationID: webhook.installation.id)

//                let installToken = github.getInstallationToken(jwtToken: jwtToken!,
//                                                               installationID: webhook.installation.id)

//                print("TOKEN", installToken)

//                guard let tok = try? installToken.get() else { return }

                guard let headSha = webhook.checkSuite?.headSha else { return }

                let payload = CheckRunCreateRequest(name: "SwiftLint", headSha: headSha)

                github.createCheckRun(repositoryName: webhook.repository.fullName, checkRun: payload)

            }).disposed(by: bag)
    }

}

let globalAAA = AAA()
