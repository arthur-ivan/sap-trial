import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    @EnvironmentObject var photoManager: PhotoManagerService
    @Environment(\.dismiss) var dismiss
    @State private var imageData: Data?
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    // Reset if zoomed out too much
                                    if scale < 1 {
                                        withAnimation {
                                            scale = 1
                                            lastScale = 1
                                        }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation {
                                if scale > 1 {
                                    scale = 1
                                    lastScale = 1
                                } else {
                                    scale = 2
                                    lastScale = 2
                                }
                            }
                        }
                } else if isLoading {
                    ProgressView("加载中...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("无法加载图片")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(photo.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(formatFileSize(photo.size))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            // Share functionality would go here
                        }) {
                            Label("分享", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            // Download functionality would go here
                        }) {
                            Label("下载", systemImage: "arrow.down.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task {
            await loadFullImage()
        }
    }
    
    private func loadFullImage() async {
        do {
            let data = try await photoManager.loadImage(for: photo, thumbnail: false)
            await MainActor.run {
                self.imageData = data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(photo: Photo(
            id: "1",
            name: "Sample Photo.jpg",
            path: "/photos/sample.jpg",
            size: 1024000,
            createdDate: Date(),
            modifiedDate: Date()
        ))
        .environmentObject(PhotoManagerService())
    }
}
