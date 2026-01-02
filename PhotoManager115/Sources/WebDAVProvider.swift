import Foundation

/// Implementation of CloudStorageProvider for WebDAV servers
public class WebDAVProvider: CloudStorageProvider {
    public let providerName = "WebDAV"
    
    private var serverURL: String?
    private var username: String?
    private var password: String?
    private var authenticated = false
    
    public var isAuthenticated: Bool {
        return authenticated
    }
    
    public init() {}
    
    // MARK: - Authentication
    
    public func authenticate(credentials: [String: String]) async throws {
        guard let serverURL = credentials["serverURL"],
              let username = credentials["username"],
              let password = credentials["password"] else {
            throw AuthenticationError.invalidCredentials
        }
        
        self.serverURL = serverURL
        self.username = username
        self.password = password
        
        // Test connection with a PROPFIND request
        guard let url = URL(string: serverURL) else {
            throw AuthenticationError.invalidCredentials
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PROPFIND"
        request.setValue("0", forHTTPHeaderField: "Depth")
        
        // Add Basic Authentication
        if let authData = "\(username):\(password)".data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.networkError
        }
        
        guard httpResponse.statusCode == 207 || httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw AuthenticationError.invalidCredentials
            }
            throw AuthenticationError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        authenticated = true
    }
    
    // MARK: - Helper Methods
    
    private func createAuthenticatedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let username = username, let password = password,
           let authData = "\(username):\(password)".data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func listDirectory(path: String) async throws -> [WebDAVItem] {
        guard isAuthenticated, let serverURL = serverURL else {
            throw StorageError.notAuthenticated
        }
        
        let fullPath = serverURL + path
        guard let url = URL(string: fullPath) else {
            throw StorageError.invalidResponse
        }
        
        var request = createAuthenticatedRequest(url: url, method: "PROPFIND")
        request.setValue("1", forHTTPHeaderField: "Depth")
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        // Basic PROPFIND body
        let propfindBody = """
        <?xml version="1.0" encoding="utf-8"?>
        <D:propfind xmlns:D="DAV:">
            <D:prop>
                <D:displayname/>
                <D:getcontentlength/>
                <D:getcontenttype/>
                <D:creationdate/>
                <D:getlastmodified/>
                <D:resourcetype/>
            </D:prop>
        </D:propfind>
        """
        request.httpBody = propfindBody.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 207 else {
            throw StorageError.serverError("Failed to list directory")
        }
        
        // Parse WebDAV XML response
        return try parseWebDAVResponse(data)
    }
    
    private func parseWebDAVResponse(_ data: Data) throws -> [WebDAVItem] {
        // Basic WebDAV XML response parsing
        // A production implementation should use XMLParser or a proper XML library
        var items: [WebDAVItem] = []
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw StorageError.invalidResponse
        }
        
        // Simple pattern matching for basic WebDAV responses
        // This is a simplified implementation - production code should use proper XML parsing
        let lines = xmlString.components(separatedBy: "\n")
        var currentHref: String?
        var currentIsDirectory = false
        var currentContentType: String?
        var currentSize: Int64 = 0
        var currentModified = Date()
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Extract href (file path)
            if trimmed.contains("<D:href>") || trimmed.contains("<d:href>") {
                let start = trimmed.range(of: ">")?.upperBound
                let end = trimmed.range(of: "</", options: .backwards)?.lowerBound
                if let start = start, let end = end {
                    currentHref = String(trimmed[start..<end])
                }
            }
            
            // Check if it's a directory
            if trimmed.contains("<D:collection") || trimmed.contains("<d:collection") {
                currentIsDirectory = true
            }
            
            // Extract content type
            if trimmed.contains("<D:getcontenttype>") || trimmed.contains("<d:getcontenttype>") {
                let start = trimmed.range(of: ">")?.upperBound
                let end = trimmed.range(of: "</", options: .backwards)?.lowerBound
                if let start = start, let end = end {
                    currentContentType = String(trimmed[start..<end])
                }
            }
            
            // Extract size
            if trimmed.contains("<D:getcontentlength>") || trimmed.contains("<d:getcontentlength>") {
                let start = trimmed.range(of: ">")?.upperBound
                let end = trimmed.range(of: "</", options: .backwards)?.lowerBound
                if let start = start, let end = end, let size = Int64(String(trimmed[start..<end])) {
                    currentSize = size
                }
            }
            
            // When we reach the end of a response element, create the item
            if trimmed.contains("</D:response>") || trimmed.contains("</d:response>") {
                if let href = currentHref, let serverURL = serverURL, let url = URL(string: serverURL + href) {
                    let name = href.components(separatedBy: "/").last ?? href
                    let item = WebDAVItem(
                        name: name,
                        path: href,
                        size: currentSize,
                        contentType: currentContentType,
                        createdDate: currentModified,
                        modifiedDate: currentModified,
                        isDirectory: currentIsDirectory,
                        url: url
                    )
                    items.append(item)
                }
                
                // Reset for next item
                currentHref = nil
                currentIsDirectory = false
                currentContentType = nil
                currentSize = 0
            }
        }
        
        return items
    }
    
    // MARK: - Fetch Operations
    
    public func fetchAlbums() async throws -> [Album] {
        guard isAuthenticated else {
            throw StorageError.notAuthenticated
        }
        
        // List root directory and find subdirectories
        let items = try await listDirectory(path: "/")
        
        var albums: [Album] = []
        for item in items where item.isDirectory {
            let album = Album(
                id: item.path,
                name: item.name,
                path: item.path,
                photoCount: 0, // Would need to count in real implementation
                coverPhotoURL: nil
            )
            albums.append(album)
        }
        
        return albums
    }
    
    public func fetchPhotos(in path: String) async throws -> [Photo] {
        guard isAuthenticated else {
            throw StorageError.notAuthenticated
        }
        
        let items = try await listDirectory(path: path)
        
        var photos: [Photo] = []
        for item in items where !item.isDirectory && item.isImage {
            let photo = Photo(
                id: item.path,
                name: item.name,
                path: item.path,
                size: item.size,
                createdDate: item.createdDate,
                modifiedDate: item.modifiedDate,
                thumbnailURL: item.url,
                fullImageURL: item.url,
                mimeType: item.contentType ?? "image/jpeg"
            )
            photos.append(photo)
        }
        
        return photos
    }
    
    public func fetchAllPhotos() async throws -> [Photo] {
        guard isAuthenticated else {
            throw StorageError.notAuthenticated
        }
        
        // Recursively fetch photos from all directories
        return try await fetchPhotosRecursively(path: "/")
    }
    
    private func fetchPhotosRecursively(path: String) async throws -> [Photo] {
        var allPhotos: [Photo] = []
        
        let items = try await listDirectory(path: path)
        
        for item in items {
            if item.isDirectory {
                let subPhotos = try await fetchPhotosRecursively(path: item.path)
                allPhotos.append(contentsOf: subPhotos)
            } else if item.isImage {
                let photo = Photo(
                    id: item.path,
                    name: item.name,
                    path: item.path,
                    size: item.size,
                    createdDate: item.createdDate,
                    modifiedDate: item.modifiedDate,
                    thumbnailURL: item.url,
                    fullImageURL: item.url,
                    mimeType: item.contentType ?? "image/jpeg"
                )
                allPhotos.append(photo)
            }
        }
        
        return allPhotos
    }
    
    public func downloadPhoto(photo: Photo) async throws -> Data {
        guard isAuthenticated else {
            throw StorageError.notAuthenticated
        }
        
        guard let url = photo.fullImageURL else {
            throw StorageError.notFound
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw StorageError.serverError("Failed to download photo")
        }
        
        return data
    }
    
    public func downloadThumbnail(photo: Photo) async throws -> Data {
        // WebDAV doesn't have built-in thumbnail support
        // Would need to generate thumbnails or use full images
        return try await downloadPhoto(photo: photo)
    }
}

// MARK: - Supporting Types

private struct WebDAVItem {
    let name: String
    let path: String
    let size: Int64
    let contentType: String?
    let createdDate: Date
    let modifiedDate: Date
    let isDirectory: Bool
    let url: URL
    
    var isImage: Bool {
        guard let contentType = contentType else { return false }
        return contentType.hasPrefix("image/")
    }
}
