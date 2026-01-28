//
//  OnboardingView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

private enum OnboardingTheme {
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let separator = Color(.separator)
    static let accent = Color.accentColor
    static let shadow = Color(.separator)
}

struct OnboardingView: View {
    let onComplete: (ChildProfile) -> Void
    
    @State private var step: Int = 0
    @State private var role: UserRole? = nil
    @State private var enteredCode: String = ""
    @State private var phone: String = ""
    @State private var profile: PartialChildProfile = PartialChildProfile()
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    @FocusState private var isInputFocused: Bool
    
    private var totalSteps: Int {
        role == .parent ? 4 : 3
    }
    
    var body: some View {
        ZStack {
            OnboardingTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                if step > 0 {
                    HStack {
                        Button(action: prevStep) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(OnboardingTheme.secondaryBackground)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.leading, 24)
                        .padding(.top, 56)
                        
                        Spacer()
                    }
                }
                
                // Progress bar
                if step > 0 {
                    progressBar
                        .padding(.horizontal, 40)
                        .padding(.top, step > 0 ? 16 : 64)
                }
                
                // Content
                ScrollView {
                    contentView
                        .padding(.horizontal, 40)
                        .padding(.top, step == 0 ? 96 : 24)
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(OnboardingTheme.secondaryBackground)
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(OnboardingTheme.accent)
                    .frame(width: geometry.size.width * CGFloat(step) / CGFloat(totalSteps), height: 6)
                    .animation(.easeOut(duration: 0.5), value: step)
            }
        }
        .frame(height: 6)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch step {
        case 0:
            landingView
        case 1:
            step1View
        case 2:
            step2View
        case 3:
            step3View
        case 4:
            step4View
        default:
            EmptyView()
        }
    }
    
    // MARK: - Step Views
    
    private var landingView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 32) {
                // Logo
                VStack(spacing: 24) {
                    HeartBridgeLogo(size: 128, animated: true)
                        .frame(width: 176, height: 176)
                        .background(
                            RoundedRectangle(cornerRadius: 44)
                                .fill(OnboardingTheme.background)
                                .shadow(color: OnboardingTheme.shadow, radius: 20, x: 0, y: 10)
                        )
                    
                    // Title
                    Text("HeartBridge")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .tracking(-1)
                    
                    // Tagline box
                    VStack(spacing: 0) {
                        Text("Predictive Support for Everyday Autism Care")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .tracking(-0.5)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 44)
                            .fill(OnboardingTheme.secondaryBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 44)
                                    .stroke(OnboardingTheme.separator, lineWidth: 2)
                            )
                    )
                    
                    // Subtitle
                    Text("Understand your child better—every day.")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                // Role selection buttons
                HStack(spacing: 16) {
                    roleButton(
                        role: .parent,
                        icon: "person.2.fill",
                        title: "Parent"
                    )
                    
                    roleButton(
                        role: .expert,
                        icon: "stethoscope",
                        title: "Therapist / Teacher"
                    )
                }
            }
            
            Spacer()
            
            Text("Select your role to continue")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(4)
                .padding(.bottom, 40)
        }
    }
    
    private func roleButton(role: UserRole, icon: String, title: String) -> some View {
        Button(action: {
            self.role = role
            nextStep()
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(self.role == role ? OnboardingTheme.secondaryBackground : OnboardingTheme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                self.role == role ? OnboardingTheme.accent : OnboardingTheme.separator,
                                lineWidth: 4
                            )
                    )
                    .shadow(
                        color: self.role == role ? OnboardingTheme.shadow : Color.clear,
                        radius: 20,
                        x: 0,
                        y: 10
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var step1View: some View {
        stepView(
            stepNumber: 1,
            stepTitle: "Profile",
            mainTitle: "How should we address you?",
            placeholder: "Full name",
            text: $profile.parentName,
            onContinue: nextStep
        )
    }
    
    @ViewBuilder
    private var step2View: some View {
        if role == .parent {
            stepView(
                stepNumber: 2,
                stepTitle: "Your Child",
                mainTitle: "Who is your amazing child?",
                placeholder: "Child's name",
                text: $profile.name,
                onContinue: nextStep
            )
        } else {
            phoneStepView(stepNumber: 2)
        }
    }
    
    @ViewBuilder
    private var step3View: some View {
        if role == .parent {
            phoneStepView(stepNumber: 3)
        } else {
            codeStepView(stepNumber: 3)
        }
    }
    
    private var step4View: some View {
        codeStepView(stepNumber: 4)
    }
    
    private func stepView(
        stepNumber: Int,
        stepTitle: String,
        mainTitle: String,
        placeholder: String,
        text: Binding<String>,
        onContinue: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("Step \(stepNumber) · \(stepTitle)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(3)
                
                Text(mainTitle)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.bottom, 64)
                
                TextField(placeholder, text: text)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 24)
                    .background(
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(OnboardingTheme.separator)
                                .frame(height: 4)
                        }
                    )
                    .focused($isInputFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isInputFocused = true
                        }
                    }
            }
            
            Spacer()
            
            continueButton(
                title: "Continue",
                isEnabled: isStepValid(),
                action: onContinue
            )
            
            statusMessageView
        }
    }
    
    private func phoneStepView(stepNumber: Int) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("Security")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(3)
                
                Text("Where can we send your code?")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.bottom, 64)
                
                HStack(spacing: 16) {
                    Text("+1")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    TextField("(555) 000-0000", text: Binding(
                        get: { formatPhoneNumber(phone) },
                        set: { newValue in
                            let digits = newValue.filter { $0.isNumber }
                            phone = String(digits.prefix(10))
                        }
                    ))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .keyboardType(.phonePad)
                        .multilineTextAlignment(.center)
                        .focused($isInputFocused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isInputFocused = true
                            }
                        }
                }
                .padding(.vertical, 24)
                .background(
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(OnboardingTheme.separator)
                            .frame(height: 4)
                    }
                )
            }
            .frame(maxWidth: 300)
            
            Spacer()
            
            continueButton(
                title: "Send verification code",
                isEnabled: isStepValid(),
                action: handleSendCode
            )
            
            statusMessageView
        }
    }
    
    private func codeStepView(stepNumber: Int) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("Verification")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(3)
                
                VStack(spacing: 16) {
                    Text("Welcome to HeartBridge 💙")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    TextField("0000", text: $enteredCode)
                        .font(.system(size: 60, weight: .black, design: .monospaced))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .tracking(12)
                        .frame(maxWidth: 240)
                        .padding(.vertical, 16)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(OnboardingTheme.separator)
                                    .frame(height: 4)
                            }
                        )
                        .focused($isInputFocused)
                        .onChange(of: enteredCode) { oldValue, newValue in
                            let digits = newValue.filter { $0.isNumber }
                            enteredCode = String(digits.prefix(4))
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isInputFocused = true
                            }
                        }
                }
                .padding(.top, 48)
            }
            
            Spacer()
            
            continueButton(
                title: "Go to Dashboard",
                isEnabled: isStepValid(),
                action: handleVerifyCode
            )
            
            statusMessageView
        }
    }
    
    private func continueButton(title: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        let isButtonEnabled = isEnabled && !isLoading
        return Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(isButtonEnabled ? OnboardingTheme.accent : OnboardingTheme.tertiaryBackground)
                )
                .shadow(
                    color: isButtonEnabled ? OnboardingTheme.shadow : Color.clear,
                    radius: 20,
                    x: 0,
                    y: 10
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isButtonEnabled)
    }

    @ViewBuilder
    private var statusMessageView: some View {
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
        } else if isLoading {
            Text("Loading…")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.top, 12)
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Validation
    
    private func isStepValid() -> Bool {
        switch step {
        case 0:
            return role != nil
        case 1:
            return !profile.parentName.isEmpty && profile.parentName.count > 1
        case 2:
            if role == .parent {
                return !profile.name.isEmpty && profile.name.count > 1
            } else {
                return phone.count >= 10
            }
        case 3:
            if role == .parent {
                return phone.count >= 10
            } else {
                return enteredCode.count == 4
            }
        case 4:
            return enteredCode.count == 4
        default:
            return true
        }
    }
    
    // MARK: - Helpers
    
    private func formatPhoneNumber(_ digits: String) -> String {
        let digitsOnly = digits.filter { $0.isNumber }
        if digitsOnly.count <= 3 {
            return digitsOnly
        } else if digitsOnly.count <= 6 {
            let area = String(digitsOnly.prefix(3))
            let rest = String(digitsOnly.dropFirst(3))
            return "(\(area)) \(rest)"
        } else {
            let area = String(digitsOnly.prefix(3))
            let first = String(digitsOnly.dropFirst(3).prefix(3))
            let last = String(digitsOnly.dropFirst(6))
            return "(\(area)) \(first)-\(last)"
        }
    }
    
    // MARK: - Actions
    
    private func nextStep() {
        if step == totalSteps && role != nil {
            handleComplete()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                step += 1
            }
        }
        errorMessage = nil
    }
    
    private func prevStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            step = max(0, step - 1)
        }
        errorMessage = nil
    }

    private func handleSendCode() {
        guard !isLoading, let role = role else { return }
        errorMessage = nil
        isLoading = true

        Task {
            do {
                let request = StartLoginRequest(
                    userType: role.rawValue,
                    name: profile.parentName,
                    childName: role == .parent ? profile.name : nil,
                    phone: phone
                )
                _ = try await APIClient.shared.post("/api/auth/start-login", body: request) as StartLoginResponse

                await MainActor.run {
                    isLoading = false
                    nextStep()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func handleVerifyCode() {
        guard !isLoading else { return }
        errorMessage = nil
        isLoading = true

        Task {
            do {
                let request = VerifyCodeRequest(phone: phone, code: enteredCode)
                let response: VerifyCodeResponse = try await APIClient.shared.post("/api/auth/verify-code", body: request)
                try KeychainTokenStore.shared.saveToken(response.token)

                let finalProfile = mapUserToProfile(response.user)

                await MainActor.run {
                    isLoading = false
                    onComplete(finalProfile)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func mapUserToProfile(_ user: APIUser) -> ChildProfile {
        let resolvedRoleRaw = user.userType ?? user.role ?? role?.rawValue ?? UserRole.parent.rawValue
        let resolvedRole = UserRole(rawValue: resolvedRoleRaw) ?? .parent
        let parentName = user.name ?? profile.parentName
        let childName = user.childName ?? profile.name
        let tier = SubscriptionTier(rawValue: user.subscriptionTier ?? "free") ?? .free
        let points = user.points ?? (resolvedRole == .parent ? 100 : 0)

        return ChildProfile(
            name: childName.isEmpty ? parentName : childName,
            parentName: parentName,
            role: resolvedRole,
            points: points,
            subscriptionTier: tier,
            email: user.email,
            diagnosis: user.diagnosis,
            severity: user.severity,
            currentTherapies: user.currentTherapies,
            goals: user.goals,
            gender: user.gender,
            age: user.age
        )
    }
    
    private func handleComplete() {
        guard let role = role else { return }
        
        let email = profile.parentName.lowercased().replacingOccurrences(of: " ", with: "") + "@example.com"
        let gender = role == .parent ? "Boy" : "N/A"
        let age = role == .parent ? "6" : "N/A"
        
        let finalProfile = ChildProfile(
            name: profile.name.isEmpty ? profile.parentName : profile.name,
            parentName: profile.parentName,
            role: role,
            points: role == .parent ? 100 : 0,
            subscriptionTier: .free,
            email: email,
            diagnosis: role == .parent ? ["ASD (Autism)"] : nil,
            severity: role == .parent ? "Moderate" : nil,
            currentTherapies: role == .parent ? ["ABA"] : nil,
            goals: role == .parent ? ["Emotional Regulation"] : nil,
            gender: gender,
            age: age
        )
        
        onComplete(finalProfile)
    }
}

// MARK: - Supporting Types

struct PartialChildProfile {
    var parentName: String = ""
    var name: String = ""
    var email: String = ""
    var diagnosis: [String] = ["ASD (Autism)"]
    var severity: String = "Moderate"
    var currentTherapies: [String] = ["ABA"]
    var goals: [String] = ["Emotional Regulation"]
}

#Preview {
    OnboardingView { _ in }
}
