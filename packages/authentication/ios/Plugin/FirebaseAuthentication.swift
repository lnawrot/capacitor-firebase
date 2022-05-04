import Foundation
import Capacitor
import FirebaseCore
import FirebaseAuth

public typealias AuthStateChangedObserver = () -> Void

let ERROR_CODES = [
    AuthErrorCode.invalidCustomToken: "invalid-custom-token",
    AuthErrorCode.customTokenMismatch: "custom-token-mismatch",
    AuthErrorCode.invalidCredential: "invalid-credential",
    AuthErrorCode.userDisabled: "user-disabled",
    AuthErrorCode.operationNotAllowed: "operation-not-allowed",
    AuthErrorCode.emailAlreadyInUse: "email-already-in-use",
    AuthErrorCode.invalidEmail: "invalid-email",
    AuthErrorCode.wrongPassword: "wrong-password",
    AuthErrorCode.tooManyRequests: "too-many-requests",
    AuthErrorCode.userNotFound: "user-not-found",
    AuthErrorCode.accountExistsWithDifferentCredential: "account-exists-with-different-credential",
    AuthErrorCode.requiresRecentLogin: "requires-recent-login",
    AuthErrorCode.providerAlreadyLinked: "provider-already-linked",
    AuthErrorCode.noSuchProvider: "no-such-provider",
    AuthErrorCode.invalidUserToken: "invalid-user-token",
    AuthErrorCode.networkError: "network-request-failed",
    AuthErrorCode.userTokenExpired: "user-token-expired",
    AuthErrorCode.invalidAPIKey: "invalid-api-key",
    AuthErrorCode.userMismatch: "user-mismatch",
    AuthErrorCode.credentialAlreadyInUse: "credential-already-in-use",
    AuthErrorCode.weakPassword: "weak-password",
    AuthErrorCode.appNotAuthorized: "app-not-authorized",
    AuthErrorCode.expiredActionCode: "expired-action-code",
    AuthErrorCode.invalidActionCode: "invalid-action-code",
    AuthErrorCode.invalidMessagePayload: "invalid-message-payload",
    AuthErrorCode.invalidSender: "invalid-sender",
    AuthErrorCode.invalidRecipientEmail: "invalid-recipient-email",
    AuthErrorCode.missingEmail: "invalid-email",
    AuthErrorCode.missingIosBundleID: "missing-ios-bundle-id",
    AuthErrorCode.missingAndroidPackageName: "missing-android-pkg-name",
    AuthErrorCode.unauthorizedDomain: "unauthorized-domain",
    AuthErrorCode.invalidContinueURI: "invalid-continue-uri",
    AuthErrorCode.missingContinueURI: "missing-continue-uri",
    AuthErrorCode.missingPhoneNumber: "missing-phone-number",
    AuthErrorCode.invalidPhoneNumber: "invalid-phone-number",
    AuthErrorCode.missingVerificationCode: "missing-verification-code",
    AuthErrorCode.invalidVerificationCode: "invalid-verification-code",
    AuthErrorCode.missingVerificationID: "missing-verification-id",
    AuthErrorCode.invalidVerificationID: "invalid-verification-id",
    AuthErrorCode.missingAppCredential: "missing-app-credential",
    AuthErrorCode.invalidAppCredential: "invalid-app-credential",
    AuthErrorCode.sessionExpired: "code-expired",
    AuthErrorCode.quotaExceeded: "quota-exceeded",
    AuthErrorCode.missingAppToken: "missing-apns-token",
    AuthErrorCode.notificationNotForwarded: "notification-not-forwarded",
    AuthErrorCode.appNotVerified: "app-not-verified",
    AuthErrorCode.captchaCheckFailed: "captcha-check-failed",
    AuthErrorCode.webContextAlreadyPresented: "cancelled-popup-request",
    AuthErrorCode.webContextCancelled: "popup-closed-by-user",
    AuthErrorCode.appVerificationUserInteractionFailure: "app-verification-user-interaction-failure",
    AuthErrorCode.invalidClientID: "invalid-oauth-client-id",
    AuthErrorCode.webNetworkRequestFailed: "network-request-failed",
    AuthErrorCode.webInternalError: "internal-error",
    AuthErrorCode.nullUser: "null-user",
    AuthErrorCode.keychainError: "keychain-error",
    AuthErrorCode.internalError: "internal-error",
    AuthErrorCode.malformedJWT: "malformed-jwt",
]

@objc public class FirebaseAuthentication: NSObject {
    public let errorDeviceUnsupported = "Device is not supported. At least iOS 13 is required."
    public let errorCustomTokenSkipNativeAuth = "signInWithCustomToken cannot be used in combination with skipNativeAuth."
    public var authStateObserver: AuthStateChangedObserver?
    private let plugin: FirebaseAuthenticationPlugin
    private let config: FirebaseAuthenticationConfig
    private var appleAuthProviderHandler: AppleAuthProviderHandler?
    private var facebookAuthProviderHandler: FacebookAuthProviderHandler?
    private var googleAuthProviderHandler: GoogleAuthProviderHandler?
    private var oAuthProviderHandler: OAuthProviderHandler?
    private var phoneAuthProviderHandler: PhoneAuthProviderHandler?
    private var savedCall: CAPPluginCall?

    init(plugin: FirebaseAuthenticationPlugin, config: FirebaseAuthenticationConfig) {
        self.plugin = plugin
        self.config = config
        super.init()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.initAuthProviderHandlers(config: config)
        Auth.auth().addStateDidChangeListener {_, _ in
            self.authStateObserver?()
        }
    }

    @objc func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }

    @objc func getIdToken(_ forceRefresh: Bool, completion: @escaping (String?, Error?) -> Void) {
        let user = self.getCurrentUser()
        user?.getIDTokenResult(forcingRefresh: forceRefresh, completion: { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(result?.token, nil)
        })
    }

    @objc func setLanguageCode(_ languageCode: String) {
        Auth.auth().languageCode = languageCode
    }

    @objc func signInWithApple(_ call: CAPPluginCall) {
        self.savedCall = call
        self.appleAuthProviderHandler?.signIn(call: call)
    }

    @objc func signInWithFacebook(_ call: CAPPluginCall) {
        self.savedCall = call
        self.facebookAuthProviderHandler?.signIn(call: call)
    }

    @objc func signInWithGithub(_ call: CAPPluginCall) {
        self.savedCall = call
        self.oAuthProviderHandler?.signIn(call: call, providerId: "github.com")
    }

    @objc func signInWithGoogle(_ call: CAPPluginCall) {
        self.savedCall = call
        self.googleAuthProviderHandler?.signIn(call: call)
    }

    @objc func signInWithMicrosoft(_ call: CAPPluginCall) {
        self.savedCall = call
        self.oAuthProviderHandler?.signIn(call: call, providerId: "microsoft.com")
    }

    @objc func signInWithPhoneNumber(_ call: CAPPluginCall) {
        self.savedCall = call
        self.phoneAuthProviderHandler?.signIn(call: call)
    }

    @objc func signInWithTwitter(_ call: CAPPluginCall) {
        self.savedCall = call
        self.oAuthProviderHandler?.signIn(call: call, providerId: "twitter.com")
    }

    @objc func signInWithYahoo(_ call: CAPPluginCall) {
        self.savedCall = call
        self.oAuthProviderHandler?.signIn(call: call, providerId: "yahoo.com")
    }

    @objc func signInWithCustomToken(_ call: CAPPluginCall) {
        if config.skipNativeAuth == true {
            call.reject(self.errorCustomTokenSkipNativeAuth)
            return
        }

        let token = call.getString("token", "")

        self.savedCall = call
        Auth.auth().signIn(withCustomToken: token) { _, error in
            if let error = error {
                self.handleFailedSignIn(message: nil, error: error)
                return
            }
            guard let savedCall = self.savedCall else {
                return
            }
            let user = self.getCurrentUser()
            let result = FirebaseAuthenticationHelper.createSignInResult(credential: nil, user: user, idToken: nil, nonce: nil, accessToken: nil)
            savedCall.resolve(result)
        }
    }

    @objc func sendSignInLinkToEmail(_ call: CAPPluginCall) {
        let jsActionCodeSettings = call.getObject("settings")!
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: jsActionCodeSettings["url"] as? String ?? "")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setAndroidPackageName((jsActionCodeSettings["android"] as? JSObject ?? [:])["packageName"] as? String ?? "",
                                                installIfNotAvailable: false,
                                                minimumVersion: (jsActionCodeSettings["android"] as? JSObject ?? [:])["minimumVersion"] as? String ?? "1")

        let email = call.getString("email") ?? ""
        self.savedCall = call
        Auth.auth().sendSignInLink(toEmail: email,
                        actionCodeSettings: actionCodeSettings) { error in
            guard let savedCall = self.savedCall else {
                return
            }
            if let error = error as NSError? {
                let errorMessage = error.localizedDescription
                let authError = error as NSError
                let code = ERROR_CODES[AuthErrorCode(rawValue: authError.code)!] ?? "unknown-error"
                savedCall.reject(errorMessage, code, error)
                return
            }
            savedCall.resolve()
        }
    }

    @objc func signInWithEmailLink(_ call: CAPPluginCall) {
        let url = call.getString("url", "")
        let email = call.getString("email", "")

        self.savedCall = call
        Auth.auth().signIn(withEmail: email, link: url) { _, error in
            guard let savedCall = self.savedCall else {
                return
            }
            if let error = error {
                let errorMessage = error.localizedDescription
                let authError = error as NSError
                let code = ERROR_CODES[AuthErrorCode(rawValue: authError.code)!] ?? "unknown-error"
                savedCall.reject(errorMessage, code, error)
                return
            }
            let user = self.getCurrentUser()
            let result = FirebaseAuthenticationHelper.createSignInResult(credential: nil, user: user, idToken: nil, nonce: nil, accessToken: nil)
            savedCall.resolve(result)
        }
    }

    @objc func signOut(_ call: CAPPluginCall) {
        do {
            try Auth.auth().signOut()
            googleAuthProviderHandler?.signOut()
            facebookAuthProviderHandler?.signOut()
            call.resolve()
        } catch let signOutError as NSError {
            call.reject("Error signing out: \(signOutError)")
        }
    }

    @objc func useAppLanguage() {
        Auth.auth().useAppLanguage()
    }

    @objc func useEmulator(_ host: String, _ port: Int) {
        Auth.auth().useEmulator(withHost: host, port: port)
    }

    func handleSuccessfulSignIn(credential: AuthCredential, idToken: String?, nonce: String?, accessToken: String?) {
        if config.skipNativeAuth == true {
            guard let savedCall = self.savedCall else {
                return
            }
            let result = FirebaseAuthenticationHelper.createSignInResult(credential: credential, user: nil, idToken: idToken, nonce: nonce, accessToken: accessToken)
            savedCall.resolve(result)
            return
        }
        Auth.auth().signIn(with: credential) { (_, error) in
            if let error = error {
                self.handleFailedSignIn(message: nil, error: error)
                return
            }
            guard let savedCall = self.savedCall else {
                return
            }
            let user = self.getCurrentUser()
            let result = FirebaseAuthenticationHelper.createSignInResult(credential: credential, user: user, idToken: idToken, nonce: nonce, accessToken: accessToken)
            savedCall.resolve(result)
        }
    }

    func handleFailedSignIn(message: String?, error: Error?) {
        guard let savedCall = self.savedCall else {
            return
        }
        let errorMessage = message ?? error?.localizedDescription ?? ""
        savedCall.reject(errorMessage, nil, error)
    }

    func getPlugin() -> FirebaseAuthenticationPlugin {
        return self.plugin
    }

    private func initAuthProviderHandlers(config: FirebaseAuthenticationConfig) {
        if config.providers.contains("apple.com") {
            self.appleAuthProviderHandler = AppleAuthProviderHandler(self)
        }
        if config.providers.contains("facebook.com") {
            self.facebookAuthProviderHandler = FacebookAuthProviderHandler(self)
        }
        if config.providers.contains("google.com") {
            self.googleAuthProviderHandler = GoogleAuthProviderHandler(self)
        }
        if config.providers.contains("phone") {
            self.phoneAuthProviderHandler = PhoneAuthProviderHandler(self)
        }
        self.oAuthProviderHandler = OAuthProviderHandler(self)
    }
}
