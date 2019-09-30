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

    private let trialStorage = AppAssembly.shared.resolve(TrialStorage.self)

    init() {
        subject.debug()
            .subscribe(onNext: { [weak self] webhook in
                self?.processWebHook(webhook: webhook)
            }).disposed(by: bag)
    }

    func processWebHook(webhook: GithubWebhook) {

        let github = GithubService(installationID: webhook.installation.id)

        print("ACTION: ", webhook.action)

        if let checkrun = webhook.checkRun {
            print("CHECK RUN")
            print("STATUS: ", checkrun.status)
            print("CONCLUSION: ", checkrun.conclusion)

            print("HSA CHECK SUITE: ", webhook.checkSuite)
            print("CHECK ID: ", checkrun.id)
            print("CHECK NAME: ", checkrun.name)
            print("CHECK SHA: ", checkrun.headSha)

            guard checkrun.status == "queued" || webhook.action == "rerequested" else { return }
            guard checkrun.conclusion == nil || webhook.action == "rerequested" else { return }

            guard let token = try? github.getInstallationToken().get() else {
                print("Failed to get installation token for CheckRun")
                return
            }

            github.setCheckRunAsInProgress(repositoryName: webhook.repository.fullName,
                                           checkRun: checkrun)

            guard let output = self.processCheckRun(checkRun: checkrun,
                                                    repoName: webhook.repository.fullName,
                                                    installationToken: token.token) else {
                print("ERROR WITH OUTPUT")
                return
            }

            let res = github.updateCheckRun(repositoryName: webhook.repository.fullName,
                                            checkRun: checkrun,
                                            output: output)

            switch res {
            case .failure(let error):
                print("ERROR: ", error)
            case .success(let data):
                print("DATA: ", data)
            }

            return
        }

        print("RECEIVE")

        guard let headSha = webhook.checkSuite?.headSha else { return }

        trialStorage.trials.forEach { trial in
            let payload = CheckRunCreateRequest(name: trial.name, headSha: headSha)
            _ = github.createCheckRun(repositoryName: webhook.repository.fullName, checkRun: payload)
        }

    }

    func processCheckRun(checkRun: CheckRun, repoName: String, installationToken: String) -> CheckRunOutput? {


        let workDir = prepareWorkDir(for: repoName, with: installationToken, with: checkRun)
        return runTrial(for: checkRun, in: workDir)
    }

    func prepareWorkDir(for repoName: String, with token: String, with check: CheckRun) -> String {

        let uuid = UUID().uuidString
        let dirPath = "/tmp/\(uuid)"
        let execArgs = [
            "clone",
            "https://x-auth-token:\(token)@github.com/\(repoName)",
            dirPath
        ]

        print(execArgs)

        let output = Result { try Process.execute("git", execArgs) }
        let output3 = Result { try Process.execute("git", "-C", "\(dirPath)", "reset", "--hard", "\(check.headSha)") }

        switch output {
        case .failure(let error):
            print("ERROR: ", error)
        case .success(let data):
            print("DATA: ", data)
        }

        switch output3 {
        case .failure(let error):
            print("ERROR: ", error)
        case .success(let data):
            print("DATA: ", data)
        }

        print(try? output.get())

        return dirPath
    }

    func runTrial(for checkRun: CheckRun, in workDir: String) -> CheckRunOutput? {
        guard let trial = trialStorage.trials.first(where: { $0.name == checkRun.name }) else {
            print("Trial with name `\(checkRun.name)` not found.")
            return nil
        }

        print("STARTING TRIAL: ", trial.name)

        let output = Result { try Process.execute(trial.execPath, ["--start", workDir]) }

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
