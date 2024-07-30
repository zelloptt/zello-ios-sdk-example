import Combine
import ZelloSDK

class RecentsViewModel: ObservableObject, ConnectivityProvider {
  @Published var recents: [ZelloRecentEntry] = []
  @Published var connectionViewState: ConnectionViewState
  @Published var statusMessage: String?
  @Published var showImagePopup = false
  @Published var showTextPopup = false
  @Published var showLocationPopup = false
  @Published var showAlertPopup = false
  @Published var incomingImageMessage: ZelloImageMessage?
  @Published var incomingTextMessage: ZelloTextMessage?
  @Published var incomingAlertMessage: ZelloAlertMessage?
  @Published var incomingLocationMessage: ZelloLocationMessage?
  @Published var accountStatus: ZelloAccountStatus?

  private var cancellables: Set<AnyCancellable> = []

  var isConnected: Bool {
    connectionViewState.connectionState == .connected
  }

  var isConnecting: Bool {
    connectionViewState.connectionState == .connecting
  }

  init() {
    connectionViewState = ConnectionViewState(connectionState: ZelloRepository.instance.connectionState)
    ZelloRepository.instance.$connectionState
      .sink { [weak self] connectionState in
        guard let weakSelf = self else { return }
        var state = weakSelf.connectionViewState
        state.connectionState = connectionState
        weakSelf.connectionViewState = state
      }
      .store(in: &cancellables)

    recents = ZelloRepository.instance.recents
    ZelloRepository.instance.$recents
      .sink { [weak self] recents in
        self?.recents = recents
      }
      .store(in: &cancellables)

    statusMessage = ZelloRepository.instance.statusMessage
    ZelloRepository.instance.$statusMessage
      .sink { [weak self] statusMessage in
        self?.statusMessage = statusMessage
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingImageMessage
      .sink { [weak self] incomingImageMessage in
        self?.incomingImageMessage = incomingImageMessage
        self?.showImagePopup = incomingImageMessage != nil
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingTextMessage
      .sink { [weak self] incomingTextMessage in
        self?.incomingTextMessage = incomingTextMessage
        self?.showTextPopup = incomingTextMessage != nil
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingLocationMessage
      .sink { [weak self] incomingLocationMessage in
        self?.incomingLocationMessage = incomingLocationMessage
        self?.showLocationPopup = incomingLocationMessage != nil
      }
      .store(in: &cancellables)

    ZelloRepository.instance.$lastIncomingAlertMessage
      .sink { [weak self] incomingAlertMessage in
        self?.incomingAlertMessage = incomingAlertMessage
        self?.showAlertPopup = incomingAlertMessage != nil
      }
      .store(in: &cancellables)

    accountStatus = ZelloRepository.instance.accountStatus
    ZelloRepository.instance.$accountStatus
      .sink { [weak self] accountStatus in
        self?.accountStatus = accountStatus
      }
      .store(in: &cancellables)
  }

  func connect(credentials: ZelloCredentials) {
    ZelloRepository.instance.sdk.connect(credentials: credentials)
  }

  func disconnect() {
    ZelloRepository.instance.sdk.disconnect()
  }

  func setAccountStatus(status: ZelloAccountStatus) {
    ZelloRepository.instance.sdk.setAccountStatus(status: status)
  }
}
