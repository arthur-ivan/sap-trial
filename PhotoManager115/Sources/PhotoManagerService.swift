import Foundation

/// Main service for managing photos from various cloud storage providers
public class PhotoManagerService {
    public private(set) var photos: [Photo] = []
    public private(set) var albums: [Album] = []
    public private(set) var isLoading = false
    public private(set) var error: Error?
    
    private var currentProvider: CloudStorageProvider?
    private var imageCache: NSCache<NSString, NSData>
    
    public init() {
        self.imageCache = NSCache<NSString, NSData>()
        self.imageCache.countLimit = 100 // Cache up to 100 images
    }
    
    // MARK: - Provider Management
    
    /// Set up 115 Cloud storage provider
    public func setup115Provider(username: String, password: String) async throws {
        let provider = Cloud115Provider()
        try await provider.authenticate(credentials: [
            "username": username,
            "password": password
        ])
        currentProvider = provider
    }
    
    /// Set up WebDAV storage provider
    public func setupWebDAVProvider(serverURL: String, username: String, password: String) async throws {
        let provider = WebDAVProvider()
        try await provider.authenticate(credentials: [
            "serverURL": serverURL,
            "username": username,
            "password": password
        ])
        currentProvider = provider
    }
    
    /// Disconnect from current provider
    public func disconnect() {
        currentProvider = nil
        photos = []
        albums = []
        imageCache.removeAllObjects()
    }
    
    // MARK: - Data Loading
    
    /// Load all albums from the current provider
    public func loadAlbums() async {
        guard let provider = currentProvider else {
            self.error = StorageError.notAuthenticated
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let fetchedAlbums = try await provider.fetchAlbums()
            self.albums = fetchedAlbums
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Load all photos from the current provider
    public func loadAllPhotos() async {
        guard let provider = currentProvider else {
            self.error = StorageError.notAuthenticated
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let fetchedPhotos = try await provider.fetchAllPhotos()
            self.photos = fetchedPhotos.sorted { $0.modifiedDate > $1.modifiedDate }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Load photos from a specific album
    public func loadPhotos(from album: Album) async {
        guard let provider = currentProvider else {
            self.error = StorageError.notAuthenticated
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let fetchedPhotos = try await provider.fetchPhotos(in: album.path)
            self.photos = fetchedPhotos.sorted { $0.modifiedDate > $1.modifiedDate }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Image Loading
    
    /// Load image data for a photo (with caching)
    public func loadImage(for photo: Photo, thumbnail: Bool = true) async throws -> Data {
        let cacheKey = NSString(string: "\(photo.id)_\(thumbnail ? "thumb" : "full")")
        
        // Check cache first
        if let cachedData = imageCache.object(forKey: cacheKey) {
            return cachedData as Data
        }
        
        guard let provider = currentProvider else {
            throw StorageError.notAuthenticated
        }
        
        // Download from provider
        let data = thumbnail 
            ? try await provider.downloadThumbnail(photo: photo)
            : try await provider.downloadPhoto(photo: photo)
        
        // Cache the data
        imageCache.setObject(data as NSData, forKey: cacheKey)
        
        return data
    }
    
    /// Clear image cache
    public func clearCache() {
        imageCache.removeAllObjects()
    }
}
