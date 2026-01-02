import Foundation

/// Protocol defining operations for cloud storage providers
public protocol CloudStorageProvider {
    /// Provider name (e.g., "115 Cloud", "WebDAV")
    var providerName: String { get }
    
    /// Check if the provider is authenticated
    var isAuthenticated: Bool { get }
    
    /// Authenticate with the storage provider
    func authenticate(credentials: [String: String]) async throws
    
    /// Fetch all albums from the storage
    func fetchAlbums() async throws -> [Album]
    
    /// Fetch photos from a specific album/path
    func fetchPhotos(in path: String) async throws -> [Photo]
    
    /// Fetch all photos across all albums
    func fetchAllPhotos() async throws -> [Photo]
    
    /// Download photo data
    func downloadPhoto(photo: Photo) async throws -> Data
    
    /// Download thumbnail data
    func downloadThumbnail(photo: Photo) async throws -> Data
}

/// Authentication error types
public enum AuthenticationError: Error {
    case invalidCredentials
    case networkError
    case serverError(String)
    case unknownError
}

/// Storage error types
public enum StorageError: Error {
    case notAuthenticated
    case networkError
    case notFound
    case serverError(String)
    case invalidResponse
    case unknownError
}
