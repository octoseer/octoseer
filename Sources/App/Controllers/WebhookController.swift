//
//  WebhookController.swift
//  App
//
//  Created by Denis Chagin on 02/05/2019.
//

import RxSwift
import Vapor

final class WebhookController {

    var lock = NSLock()

    func index(_ req: Request) throws -> Future<HTTPStatus> {
        let eventType = req.http.headers["X-Github-Event"]

        print(eventType)

        if eventType.first == "push" { return req.future(.ok) }

        return try req.content.decode(GithubWebhook.self).do { webhook in
            print("TTT")

            
            DispatchQueue.global().async { [weak self] in
                self?.lock.lock()
                globalAAA.subject.onNext(webhook)
                self?.lock.unlock()
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
            .subscribe(onNext: { [weak self] webhook in
                self?.processWebHook(webhook: webhook)
            }).disposed(by: bag)
    }

    func processWebHook(webhook: GithubWebhook) {

        let github = GithubService(installationID: webhook.installation.id)

        if let checkrun = webhook.checkRun {
            print("CHECK RUN")
            print("CHECK ID: ", checkrun.id)
            print("CHECK NAME: ", checkrun.name)
            print("CHECK SHA: ", checkrun.headSha)

            guard let output = self.processCheckRun(checkRun: checkrun) else {
                print("ERROR WITH OUTPUT")
                return
            }

            github.updateCheckRun(repositoryName: webhook.repository.fullName,
                                  checkRun: checkrun,
                                  output: output)

            return
        }

        print("RECEIVE")

        guard let headSha = webhook.checkSuite?.headSha else { return }

        kTrials.forEach { trial in
            let payload = CheckRunCreateRequest(name: trial.name, headSha: headSha)
            _ = github.createCheckRun(repositoryName: webhook.repository.fullName, checkRun: payload)
        }

    }

    func processCheckRun(checkRun: CheckRun) -> CheckRunOutput? {
        guard let trial = kTrials.first(where: { $0.name == checkRun.name }) else {
            print("Trial with name `\(checkRun.name)` not found.")
            return nil
        }

        print("STARTING TRIAL: ", trial.name)

        let output = Result { try Process.execute(trial.execPath, ["--start"]) }

        print("TRIAL OUTPUT: ", try? output.get())

        switch output {
        case .success(let data):
            guard let checkRunOutput = try? JSONDecoder().decode(CheckRunOutput.self, from: data) else { return nil }

            print("CHECK RUN OUTPUT:", checkRunOutput)

            return checkRunOutput

        case .failure(let error):
            print("PLUGIN ERROR: ", error)
            return nil
        }

    }

}

let globalAAA = AAA()
