import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Logo / Branding
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.accent)
                }
                
                Text("BetterBarter")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Trade skills, build community.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 60)
            
            // Form
            VStack(spacing: 16) {
                CustomTextField(text: $email, placeholder: "Email", icon: "envelope.fill")
                CustomTextField(text: $password, placeholder: "Password", icon: "lock.fill", isSecure: true)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: handleAuth) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSigningUp ? "Create Account" : "Sign In")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 5)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Button(action: { isSigningUp.toggle() }) {
                    Text(isSigningUp ? "Already have an account? Sign In" : "New neighbor? Create an account")
                        .font(.footnote)
                        .foregroundColor(AppTheme.accent)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.secondaryBackground.ignoresSafeArea())
        .hideKeyboardWhenTappedAround()
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                if isSigningUp {
                    try await Auth.auth().createUser(withEmail: email, password: password)
                } else {
                    try await Auth.auth().signIn(withEmail: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.textTertiary)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 5, y: 2)
    }
}
