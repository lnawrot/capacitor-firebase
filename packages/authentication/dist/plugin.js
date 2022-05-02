var capacitorFirebaseAuthentication = (function (exports, core, auth) {
    'use strict';

    const FirebaseAuthentication = core.registerPlugin('FirebaseAuthentication', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.FirebaseAuthenticationWeb()),
    });

    class FirebaseAuthenticationWeb extends core.WebPlugin {
        constructor() {
            super();
            const auth$1 = auth.getAuth();
            auth$1.onAuthStateChanged(user => this.handleAuthStateChange(user));
        }
        async getCurrentUser() {
            const auth$1 = auth.getAuth();
            const userResult = this.createUserResult(auth$1.currentUser);
            const result = {
                user: userResult,
            };
            return result;
        }
        async getIdToken() {
            var _a;
            const auth$1 = auth.getAuth();
            const idToken = await ((_a = auth$1.currentUser) === null || _a === void 0 ? void 0 : _a.getIdToken());
            const result = {
                token: idToken || '',
            };
            return result;
        }
        async setLanguageCode(options) {
            const auth$1 = auth.getAuth();
            auth$1.languageCode = options.languageCode;
        }
        async signInWithApple() {
            const provider = new auth.OAuthProvider('apple.com');
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithPopup(auth$1, provider);
            const credential = auth.OAuthProvider.credentialFromResult(result);
            return this.createSignInResult(result.user, credential);
        }
        async signInWithFacebook() {
            const provider = new auth.FacebookAuthProvider();
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithPopup(auth$1, provider);
            const credential = auth.FacebookAuthProvider.credentialFromResult(result);
            return this.createSignInResult(result.user, credential);
        }
        async signInWithGithub() {
            const provider = new auth.OAuthProvider('github.com');
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithPopup(auth$1, provider);
            const credential = auth.OAuthProvider.credentialFromResult(result);
            return this.createSignInResult(result.user, credential);
        }
        async signInWithGoogle() {
            const provider = new auth.GoogleAuthProvider();
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithPopup(auth$1, provider);
            const credential = auth.GoogleAuthProvider.credentialFromResult(result);
            return this.createSignInResult(result.user, credential);
        }
        async signInWithMicrosoft() {
            const provider = new auth.OAuthProvider('microsoft.com');
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithPopup(auth$1, provider);
            const credential = auth.OAuthProvider.credentialFromResult(result);
            return this.createSignInResult(result.user, credential);
        }
        async signInWithPlayGames() {
            throw new Error('Not available on web.');
        }
        async signInWithTwitter() {
            const provider = new auth.OAuthProvider('twitter.com');
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithPopup(auth$1, provider);
            const credential = auth.OAuthProvider.credentialFromResult(result);
            return this.createSignInResult(result.user, credential);
        }
        async signInWithYahoo() {
            const provider = new auth.OAuthProvider('yahoo.com');
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithPopup(auth$1, provider);
            const credential = auth.OAuthProvider.credentialFromResult(result);
            return this.createSignInResult(result.user, credential);
        }
        async signInWithPhoneNumber(_options) {
            throw new Error('Not implemented on web.');
        }
        async signInWithCustomToken(options) {
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithCustomToken(auth$1, options.token);
            return this.createSignInResult(result.user, null);
        }
        async sendSignInLinkToEmail(options) {
            const auth$1 = auth.getAuth();
            return auth.sendSignInLinkToEmail(auth$1, options.email, options.settings);
        }
        async signInWithEmailLink({ email, url }) {
            const auth$1 = auth.getAuth();
            const result = await auth.signInWithEmailLink(auth$1, email, url);
            return this.createSignInResult(result.user, null);
        }
        async signOut() {
            const auth$1 = auth.getAuth();
            await auth$1.signOut();
        }
        async useAppLanguage() {
            const auth$1 = auth.getAuth();
            auth$1.useDeviceLanguage();
        }
        async useEmulator(options) {
            const auth$1 = auth.getAuth();
            const port = options.port || 9099;
            auth.connectAuthEmulator(auth$1, `${options.host}:${port}`);
        }
        handleAuthStateChange(user) {
            const userResult = this.createUserResult(user);
            const change = {
                user: userResult,
            };
            this.notifyListeners('authStateChange', change);
        }
        createSignInResult(user, credential) {
            const userResult = this.createUserResult(user);
            const credentialResult = this.createCredentialResult(credential);
            const result = {
                user: userResult,
                credential: credentialResult,
            };
            return result;
        }
        createUserResult(user) {
            if (!user) {
                return null;
            }
            const result = {
                displayName: user.displayName,
                email: user.email,
                emailVerified: user.emailVerified,
                isAnonymous: user.isAnonymous,
                phoneNumber: user.phoneNumber,
                photoUrl: user.photoURL,
                providerId: user.providerId,
                tenantId: user.tenantId,
                uid: user.uid,
            };
            return result;
        }
        createCredentialResult(credential) {
            if (!credential) {
                return null;
            }
            const result = {
                providerId: credential.providerId,
            };
            if (credential instanceof auth.OAuthCredential) {
                result.accessToken = credential.accessToken;
                result.idToken = credential.idToken;
                result.secret = credential.secret;
            }
            return result;
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        FirebaseAuthenticationWeb: FirebaseAuthenticationWeb
    });

    exports.FirebaseAuthentication = FirebaseAuthentication;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

}({}, capacitorExports, firebaseAuthExports));
//# sourceMappingURL=plugin.js.map
