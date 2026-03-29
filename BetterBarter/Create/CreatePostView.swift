import SwiftUI
import MapKit

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var listingType: Listing.ListingType = .offer
    @State private var category: Listing.Category = .skills
    @State private var credits: String = ""
    @State private var exchangeItems: String = ""
    @State private var animateForm = false
    @State private var isPosting = false
    @StateObject private var locationManager = LocationManager()
    
    // Photo Attachment State
    @State private var selectedImage: UIImage?
    @State private var showImageSourceDialog = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Tab navigation binding (used when presented as a tab)
    @Binding var selectedTab: ContentView.TabSelection
    private var isTabMode: Bool
    
    init(initialType: Listing.ListingType? = nil, selectedTab: Binding<ContentView.TabSelection>? = nil) {
        if let type = initialType {
            _listingType = State(initialValue: type)
        }
        if let tab = selectedTab {
            _selectedTab = tab
            isTabMode = true
        } else {
            _selectedTab = .constant(.create)
            isTabMode = false
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Type Selector (Apple-style Segmented Control)
                        Picker("Type", selection: $listingType) {
                            Text("Offer").tag(Listing.ListingType.offer)
                            Text("Request").tag(Listing.ListingType.request)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top, 16)

                        // 2. Media Section
                        CreateSection(title: "PHOTO") {
                            Button {
                                showImageSourceDialog = true
                            } label: {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 160)
                                        .cornerRadius(12)
                                        .overlay(alignment: .topTrailing) {
                                            Button {
                                                selectedImage = nil
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.3))
                                                    .clipShape(Circle())
                                            }
                                            .padding(8)
                                        }
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 24))
                                        Text("Add Photos")
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .foregroundColor(AppTheme.accent)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }

                        // 2.5 Location Section
                        CreateSection(title: "LOCATION") {
                            VStack(spacing: 0) {
                                HStack {
                                    if locationManager.isRequestingLocation {
                                        ProgressView()
                                            .padding(.trailing, 8)
                                    } else {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(AppTheme.accent)
                                    }
                                    
                                    if locationManager.locationString.isEmpty {
                                        Button("Detect Current Location") {
                                            locationManager.requestLocation()
                                        }
                                        .foregroundColor(AppTheme.accent)
                                        Spacer()
                                    } else {
                                        Text(locationManager.locationString)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Button(action: { locationManager.requestLocation() }) {
                                            Text("Update")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(AppTheme.accent)
                                        }
                                    }
                                }
                                .padding()
                                
                                if let coordinate = locationManager.coordinate {
                                    Map(position: .constant(.region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))))) {
                                        Marker(locationManager.locationString, coordinate: coordinate)
                                    }
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }

                        // 3. Info Section
                        CreateSection(title: "LISTING DETAILS") {
                            VStack(spacing: 0) {
                                GroupedTextField(placeholder: "Title", text: $title)
                                Divider().padding(.leading)
                                
                                categoryPickerRow
                                
                                Divider().padding(.leading)
                                GroupedTextEditor(placeholder: "Description...", text: $description)
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }

                        // 4. Value Section
                        CreateSection(title: listingType == .offer ? "COMPENSATION" : "EXCHANGE") {
                            VStack(spacing: 0) {
                                if listingType == .offer {
                                    HStack {
                                        Text("Credits")
                                            .font(.system(size: 16))
                                        Spacer()
                                        TextField("0", text: $credits)
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.trailing)
                                            .foregroundColor(AppTheme.accent)
                                            .fontWeight(.bold)
                                        Text("tc")
                                            .foregroundColor(AppTheme.accent)
                                            .fontWeight(.bold)
                                    }
                                    .padding()
                                } else {
                                    GroupedTextField(placeholder: "What would you exchange?", text: $exchangeItems)
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // Community Message
                        Text("Listing will be visible to neighbors within 5km.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("New Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        resetForm()
                        if isTabMode {
                            selectedTab = .home
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(AppTheme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: postListing) {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("Post")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(isFormValid && !isPosting ? AppTheme.accent : .secondary)
                    .disabled(!isFormValid || isPosting)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                }
            }
            .confirmationDialog("Add Photo", isPresented: $showImageSourceDialog) {
                Button("Camera") {
                    sourceType = .camera
                    showImagePicker = true
                }
                Button("Photo Library") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
        }
    }

    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty
    }

    private func resetForm() {
        title = ""
        description = ""
        credits = ""
        exchangeItems = ""
        selectedImage = nil
        listingType = .offer
        category = .skills
    }

    private func postListing() {
        guard let currentUser = AuthService.shared.currentUser, isFormValid else { return }
        isPosting = true
        
        let finalCredits = listingType == .offer ? (Int(credits) ?? 0) : 0
        let listingId = UUID().uuidString
        
        Task {
            do {
                // Encode image as base64 data URI (avoids Firebase Storage dependency)
                var imageUrlString: String? = nil
                if let image = selectedImage,
                   let imageData = image.jpegData(compressionQuality: 0.3) {
                    let base64String = imageData.base64EncodedString()
                    imageUrlString = "data:image/jpeg;base64,\(base64String)"
                }
                
                let newListing = Listing(
                    id: listingId,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    category: category,
                    type: listingType,
                    credits: finalCredits,
                    ownerID: currentUser.id,
                    ownerName: currentUser.name,
                    ownerAvatar: currentUser.avatarName,
                    ownerTrustScore: currentUser.trustScore,
                    distance: locationManager.locationString.isEmpty ? "Near you" : locationManager.locationString,
                    createdAt: Date(),
                    iconName: category.icon,
                    latitude: locationManager.coordinate?.latitude,
                    longitude: locationManager.coordinate?.longitude,
                    imageUrl: imageUrlString
                )
                
                try await FirebaseDataService.shared.createListing(newListing)
                await MainActor.run {
                    isPosting = false
                    resetForm()
                    if isTabMode {
                        selectedTab = .home
                    } else {
                        dismiss()
                    }
                }
            } catch {
                print("Error saving listing: \(error)")
                await MainActor.run {
                    isPosting = false
                }
            }
        }
    }

    private var categoryPickerRow: some View {
        NavigationLink(destination: CategorySelectionView(selectedCategory: $category)) {
            HStack {
                Text("Category")
                    .foregroundColor(.primary)
                Spacer()
                Text(category.rawValue)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.systemGray4))
            }
            .padding()
        }
    }
}

// MARK: - Subcomponents

struct CreateSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.leading, 32)
            
            content
                .padding(.horizontal)
        }
    }
}

struct GroupedTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .font(.system(size: 16))
    }
}

struct GroupedTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
            
            TextEditor(text: $text)
                .frame(height: 100)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .opacity(text.isEmpty ? 0.25 : 1)
        }
        .font(.system(size: 16))
    }
}

struct CategorySelectionView: View {
    @Binding var selectedCategory: Listing.Category
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            ForEach(Listing.Category.allCases.filter { $0 != .all }, id: \.self) { cat in
                Button(action: {
                    selectedCategory = cat
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: cat.icon)
                            .foregroundColor(AppTheme.accent)
                            .frame(width: 30)
                        Text(cat.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedCategory == cat {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppTheme.accent)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .navigationTitle("Category")
    }
}

#Preview {
    CreatePostView()
}
