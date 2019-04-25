class TrialService {

    private let pluginService = PluginService()

    private var availableTrials = [Trial]()
}

extension TrialService: TrialStorage {

    var trials: [Trial] {
        return availableTrials
    }
}

extension TrialService: TrialLoader {

    func loadTrials() -> Result<Void, Error> {
        let result = pluginService.loadTrials()

        switch result {
        case .success(let trials):
            availableTrials = trials
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
