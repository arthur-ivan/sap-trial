import Foundation

/// Represents a photo item from cloud storage
public struct Photo: Identifiable, Codable {
    public let id: String
    public let name: String
    public let path: String
    public let size: Int64
    public let createdDate: Date
    public let modifiedDate: Date
    public let thumbnailURL: URL?
    public let fullImageURL: URL?
    public let mimeType: String
    
    public init(
        id: String,
        name: String,
        path: String,
        size: Int64,
        createdDate: Date,
        modifiedDate: Date,
        thumbnailURL: URL? = nil,
        fullImageURL: URL? = nil,
        mimeType: String = "image/jpeg"
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.size = size
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.thumbnailURL = thumbnailURL
        self.fullImageURL = fullImageURL
        self.mimeType = mimeType
    }
}

/// Represents an album/folder containing photos
public struct Album: Identifiable, Codable {
    public let id: String
    public let name: String
    public let path: String
    public let photoCount: Int
    public let coverPhotoURL: URL?
    
    public init(
        id: String,
        name: String,
        path: String,
        photoCount: Int,
        coverPhotoURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.photoCount = photoCount
        self.coverPhotoURL = coverPhotoURL
    }
}
