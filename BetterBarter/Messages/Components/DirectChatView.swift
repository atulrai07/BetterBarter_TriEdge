import SwiftUI

struct DirectChatView: View {
    let recipient: User
    @State private var viewModel: ChatViewModel
    @State private var messageText = ""
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    init(recipient: User) {
        self.recipient = recipient
        _viewModel = State(initialValue: ChatViewModel(recipient: recipient))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.accent)
                }
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipient.name)
                        .font(.headline)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(AppTheme.accent)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)

            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.messages.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.accent.opacity(0.3))
                                Text("No messages yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Start a conversation with \(recipient.name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(20)
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Bar
            HStack(spacing: 12) {
                TextField("Message...", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: {
                    if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendMessage(content: messageText)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.accent)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    DirectChatView(recipient: User.sampleNeighbors.first!)
        .environmentObject(AppState.shared)
}
