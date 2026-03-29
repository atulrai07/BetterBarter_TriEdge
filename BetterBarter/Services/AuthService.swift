import Foundation
import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
class AuthService {
    static let shared = AuthService()
    
    var currentUser: User?
    var isAuthenticated: Bool = false
    var isLoading: Bool = true
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private var db: Firestore { Firestore.firestore() }
    private var authListener: AuthStateDidChangeListenerHandle?
    private var userDocumentListener: ListenerRegistration?
    
    init() {
        listenToAuthChanges()
    }
    
    private func listenToAuthChanges() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                self.setupUserListener(uid: firebaseUser.uid)
            } else {
                self.userDocumentListener?.remove()
                self.userDocumentListener = nil
                self.currentUser = nil
                self.isAuthenticated = false
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    private func setupUserListener(uid: String) {
        userDocumentListener?.remove()
        
        userDocumentListener = db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("AUTH_ERROR: User document listener failed: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            guard let snapshot = snapshot else {
                self.isLoading = false
                return
            }
            
            if snapshot.exists {
                do {
                    self.currentUser = try snapshot.data(as: User.self)
                    self.isAuthenticated = true
                } catch {
                    print("AUTH_ERROR: Failed to decode user: \(error)")
                }
            } else {
                // Initial user creation logic stays similar
                Task {
                    let newUser = User(
                        id: uid,
                        name: Auth.auth().currentUser?.displayName ?? "New Neighbor",
                        avatarName: "person.circle.fill",
                        location: "Unknown",
                        trustScore: 50.0,
                        credits: 100,
                        skills: [],
                        interests: [],
                        joinDate: Date()
                    )
                    try? self.db.collection("users").document(uid).setData(from: newUser)
                }
            }
            self.isLoading = false
        }
    }
    
    func signOut() throws {
        userDocumentListener?.remove()
        userDocumentListener = nil
        try Auth.auth().signOut()
    }
}
