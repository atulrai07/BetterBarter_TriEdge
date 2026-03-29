import SwiftUI

/// A view that displays an image from either a regular URL or a base64 data URI.
struct ListingImageView: View {
    let imageUrl: String
    var contentMode: ContentMode = .fill
    
    var body: some View {
        if imageUrl.hasPrefix("data:image") {
            // Decode base64 data URI
            if let uiImage = decodeDataURI(imageUrl) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundStyle(.tertiary)
            }
        } else if let url = URL(string: imageUrl) {
            // Regular URL – use AsyncImage
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
        }
    }
    
    private func decodeDataURI(_ dataURI: String) -> UIImage? {
        // Format: data:image/jpeg;base64,<data>
        guard let commaIndex = dataURI.firstIndex(of: ",") else { return nil }
        let base64String = String(dataURI[dataURI.index(after: commaIndex)...])
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: data)
    }
}
