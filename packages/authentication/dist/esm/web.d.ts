import { WebPlugin } from '@capacitor/core';
import type { ActionCodeSettings } from 'firebase/auth';
import type { FirebaseAuthenticationPlugin, GetCurrentUserResult, GetIdTokenResult, SetLanguageCodeOptions, SignInResult, SignInWithCustomTokenOptions, SignInWithPhoneNumberOptions, UseEmulatorOptions } from './definitions';
export declare class FirebaseAuthenticationWeb extends WebPlugin implements FirebaseAuthenticationPlugin {
    constructor();
    getCurrentUser(): Promise<GetCurrentUserResult>;
    getIdToken(): Promise<GetIdTokenResult>;
    setLanguageCode(options: SetLanguageCodeOptions): Promise<void>;
    signInWithApple(): Promise<SignInResult>;
    signInWithFacebook(): Promise<SignInResult>;
    signInWithGithub(): Promise<SignInResult>;
    signInWithGoogle(): Promise<SignInResult>;
    signInWithMicrosoft(): Promise<SignInResult>;
    signInWithPlayGames(): Promise<SignInResult>;
    signInWithTwitter(): Promise<SignInResult>;
    signInWithYahoo(): Promise<SignInResult>;
    signInWithPhoneNumber(_options: SignInWithPhoneNumberOptions): Promise<SignInResult>;
    signInWithCustomToken(options: SignInWithCustomTokenOptions): Promise<SignInResult>;
    sendSignInLinkToEmail(options: {
        email: string;
        settings: ActionCodeSettings;
    }): Promise<void>;
    signInWithEmailLink({ email, url }: {
        email: string;
        url: string;
    }): Promise<SignInResult>;
    signOut(): Promise<void>;
    useAppLanguage(): Promise<void>;
    useEmulator(options: UseEmulatorOptions): Promise<void>;
    private handleAuthStateChange;
    private createSignInResult;
    private createUserResult;
    private createCredentialResult;
}
