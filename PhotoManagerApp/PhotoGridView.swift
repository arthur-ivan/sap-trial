import SwiftUI

struct PhotoGridView: View {
    @EnvironmentObject var photoManager: PhotoManagerService
    @State private var selectedPhoto: Photo?
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]
    
    var body: some View {
        ScrollView {
            if photoManager.isLoading {
                ProgressView("加载照片中...")
                    .padding()
            } else if let error = photoManager.error {
                ErrorView(error: error) {
                    Task {
                        await photoManager.loadAllPhotos()
                    }
                }
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(photoManager.photos) { photo in
                        PhotoThumbnailView(photo: photo)
                            .aspectRatio(1, contentMode: .fill)
                            .onTapGesture {
                                selectedPhoto = photo
                            }
                    }
                }
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo)
        }
        .refreshable {
            await photoManager.loadAllPhotos()
        }
    }
}

struct PhotoThumbnailView: View {
    let photo: Photo
    @EnvironmentObject var photoManager: PhotoManagerService
    @State private var imageData: Data?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        ProgressView()
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .task {
            await loadThumbnail()
        }
    }
    
    private func loadThumbnail() async {
        do {
            let data = try await photoManager.loadImage(for: photo, thumbnail: true)
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
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("出错了")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("重试")
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct PhotoGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhotoGridView()
                .environmentObject(PhotoManagerService())
        }
    }
}
