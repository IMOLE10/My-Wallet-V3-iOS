// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import ErrorsUI
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import UIComponentsKit

private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.CreateAccount
private typealias AccessibilityIdentifier = AccessibilityIdentifiers.CreateAccountScreen

struct CreateAccountViewStepTwo: View {

    private let store: Store<CreateAccountStepTwoState, CreateAccountStepTwoAction>
    @ObservedObject private var viewStore: ViewStore<CreateAccountStepTwoState, CreateAccountStepTwoAction>

    @State private var focusedEmail = false
    @State private var focusedPassword = false
    @State private var focusedPasswordConfirmation = false

    init(store: Store<CreateAccountStepTwoState, CreateAccountStepTwoAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Spacing.padding3) {
                    header
                    form
                    BlockchainComponentLibrary.PrimaryButton(
                        title: LocalizedString.createAccountButton,
                        isLoading: viewStore.validatingInput || viewStore.isCreatingWallet
                    ) {
                        viewStore.send(.createButtonTapped)
                    }
                    .disabled(viewStore.isCreateButtonDisabled)
                    .accessibility(identifier: AccessibilityIdentifier.createAccountButton)
                }
                .padding(Spacing.padding3)
                .frame(minHeight: geometry.size.height)
            }
            .onTapGesture {
                focusedEmail = false
                focusedPassword = false
                focusedPasswordConfirmation = false
            }
            .dismissKeyboardOnScroll()
            // setting the frame is necessary for the Spacer inside the VStack above to work properly
        }
        .primaryNavigation(title: "") {
            Button {
                viewStore.send(.createButtonTapped)
            } label: {
                Text(LocalizedString.nextButton)
                    .typography(.paragraph2)
            }
            .disabled(viewStore.isCreateButtonDisabled)
            // disabling the button doesn't gray it out
            .foregroundColor(viewStore.isCreateButtonDisabled ? .semantic.muted : .semantic.title)
            .accessibility(identifier: AccessibilityIdentifier.nextButton)
        }
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
        .onWillDisappear {
            viewStore.send(.onWillDisappear)
        }
        .navigationRoute(in: store)
        .sheet(item: viewStore.binding(\.$fatalError)) { error in
            ErrorView(
                ux: error,
                navigationBarClose: true,
                fallback: {
                    ZStack {
                        Circle()
                            .fill(Color.semantic.light)
                            .frame(width: 88)
                        Icon.user
                            .color(.semantic.title)
                            .frame(width: 50)
                    }
                },
                dismiss: {
                    viewStore.send(.binding(.set(\.$fatalError, nil)))
                }
            )
        }
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

extension UX.Error: Identifiable {}

extension CreateAccountViewStepTwo {

    var header: some View {
        VStack(spacing: Spacing.padding3) {
            Icon.user
                .color(.semantic.title)
                .with(length: 58.pt)
                .background(
                    Circle()
                        .fill(Color.semantic.background)
                        .frame(width: 88, height: 88)
                )
                .frame(width: 88, height: 88)
            VStack(spacing: Spacing.baseline) {
                Text(LocalizedString.headerTitle)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(LocalizedString.headerSubtitle)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
            }
        }
    }
}

extension CreateAccountViewStepTwo {

    var form: some View {
        VStack(spacing: Spacing.padding2) {
            emailField
            passwordField
            passwordConfirmationField
            Spacer()
            termsAgreementView
        }
    }

    private var emailField: some View {
        let shouldShowError = viewStore.inputValidationState == .invalid(.invalidEmail)
        return Input(
            text: viewStore.binding(\.$emailAddress),
            isFirstResponder: $focusedEmail,
            shouldResignFirstResponderOnReturn: true,
            label: LocalizedString.TextFieldTitle.email,
            subText: shouldShowError ? LocalizedString.TextFieldError.invalidEmail : nil,
            subTextStyle: .error,
            placeholder: LocalizedString.TextFieldPlaceholder.email,
            state: shouldShowError ? .error : .default
        )
        .accessibility(identifier: AccessibilityIdentifier.emailGroup)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
    }

    private var passwordField: some View {
        let shouldShowError = viewStore.inputValidationState == .invalid(.weakPassword)
        return Input(
            text: viewStore.binding(\.$password),
            isFirstResponder: $focusedPassword,
            shouldResignFirstResponderOnReturn: true,
            label: LocalizedString.TextFieldTitle.password,
            subText: viewStore.passwordStrength.displayString,
            subTextStyle: viewStore.passwordStrength.inputSubTextStyle,
            placeholder: LocalizedString.TextFieldPlaceholder.password,
            state: shouldShowError ? .error : .default,
            isSecure: !viewStore.passwordFieldTextVisible,
            trailing: {
                PasswordEyeSymbolButton(
                    isPasswordVisible: viewStore.binding(\.$passwordFieldTextVisible)
                )
            }
        )
        .accessibility(identifier: AccessibilityIdentifier.passwordGroup)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .textContentType(.newPassword)
    }

    private var passwordConfirmationField: some View {
        let shouldShowError = viewStore.inputConfirmationValidationState == .invalid(.passwordsDontMatch)
        return Input(
            text: viewStore.binding(\.$passwordConfirmation),
            isFirstResponder: $focusedPasswordConfirmation,
            shouldResignFirstResponderOnReturn: true,
            label: LocalizedString.TextFieldTitle.passwordConfirmation,
            subText: shouldShowError ? LocalizedString.TextFieldError.passwordsDontMatch : nil,
            subTextStyle: .error,
            placeholder: LocalizedString.TextFieldPlaceholder.passwordConfirmation,
            state: shouldShowError ? .error : .default,
            isSecure: !viewStore.passwordFieldTextVisible,
            trailing: {
                PasswordEyeSymbolButton(
                    isPasswordVisible: viewStore.binding(\.$passwordFieldTextVisible)
                )
            }
        )
        .accessibility(identifier: AccessibilityIdentifier.passwordGroup)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .textContentType(.password)
    }

    private var termsAgreementView: some View {
        HStack(spacing: Spacing.baseline) {
            Toggle(isOn: viewStore.binding(\.$termsAccepted)) {}
                .labelsHidden()
                .accessibility(identifier: AccessibilityIdentifier.termsOfServiceButton)
            agreementText
                .typography(.micro)
                .accessibility(identifier: AccessibilityIdentifier.agreementPromptText)
        }
        // fixing the size prevents the view from collapsing when the keyboard is on screen
        .fixedSize(horizontal: false, vertical: true)
    }

    private var agreementText: some View {
        HStack {
            VStack(alignment: .leading, spacing: .zero) {
                let promptText = Text(
                    rich: LocalizedString.agreementPrompt
                )
                promptText
                    .foregroundColor(.semantic.body)
                    .accessibility(identifier: AccessibilityIdentifier.agreementPromptText)

                HStack(alignment: .firstTextBaseline, spacing: .zero) {
                    Text(LocalizedString.termsOfServiceLink)
                        .foregroundColor(.semantic.primary)
                        .onTapGesture {
                            guard let url = URL(string: Constants.HostURL.terms) else { return }
                            viewStore.send(.openExternalLink(url))
                        }
                        .accessibility(identifier: AccessibilityIdentifier.termsOfServiceButton)

                    Text(" " + LocalizedString.and + " ")
                        .foregroundColor(.semantic.body)

                    let privacyPolicyComponent = Text(LocalizedString.privacyPolicyLink)
                        .foregroundColor(.semantic.primary)
                    let fullStopComponent = Text(".")
                        .foregroundColor(.semantic.body)
                    let privacyPolicyText = privacyPolicyComponent + fullStopComponent

                    privacyPolicyText
                        .onTapGesture {
                            guard let url = URL(string: Constants.HostURL.privacyPolicy) else { return }
                            viewStore.send(.openExternalLink(url))
                        }
                        .accessibility(identifier: AccessibilityIdentifier.privacyPolicyButton)
                }
            }
            Spacer()
        }
    }
}

extension PasswordValidationScore {
    fileprivate var displayString: String? {
        switch self {
        case .none:
            return nil
        case .normal:
            return LocalizedString.PasswordStrengthIndicator.regularPassword
        case .strong:
            return LocalizedString.PasswordStrengthIndicator.strongPassword
        case .weak:
            return LocalizedString.PasswordStrengthIndicator.weakPassword
        }
    }

    fileprivate var inputSubTextStyle: InputSubTextStyle {
        switch self {
        case .none, .normal:
            return .primary
        case .strong:
            return .success
        case .weak:
            return .error
        }
    }
}

struct DismissKeyboard: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.scrollDismissesKeyboard(.interactively)
        } else {
            content
        }
    }
}

extension View {

    func dismissKeyboardOnScroll() -> some View {
        modifier(DismissKeyboard())
    }
}

#if DEBUG
import AnalyticsKit
import ToolKit

struct CreateAccountViewStepTwo_Previews: PreviewProvider {

    static var previews: some View {
        CreateAccountViewStepTwo(
            store: .init(
                initialState: .init(
                    context: .createWallet,
                    country: SearchableItem(id: "1", title: "US"),
                    countryState: SearchableItem(id: "1", title: "State"),
                    referralCode: "id1"
                ),
                reducer: createAccountStepTwoReducer,
                environment: .init(
                    mainQueue: .main,
                    passwordValidator: PasswordValidator(),
                    externalAppOpener: ToLogAppOpener(),
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    walletRecoveryService: .noop,
                    walletCreationService: .noop,
                    walletFetcherService: .noop,
                    recaptchaService: NoOpGoogleRecatpchaService()
                )
            )
        )
    }
}
#endif
