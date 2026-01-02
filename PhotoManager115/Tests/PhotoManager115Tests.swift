import XCTest
@testable import PhotoManager115

final class PhotoManager115Tests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testPhotoInitialization() {
        let photo = Photo(
            id: "test-id",
            name: "test.jpg",
            path: "/photos/test.jpg",
            size: 1024,
            createdDate: Date(),
            modifiedDate: Date()
        )
        
        XCTAssertEqual(photo.id, "test-id")
        XCTAssertEqual(photo.name, "test.jpg")
        XCTAssertEqual(photo.path, "/photos/test.jpg")
        XCTAssertEqual(photo.size, 1024)
        XCTAssertEqual(photo.mimeType, "image/jpeg")
    }
    
    func testAlbumInitialization() {
        let album = Album(
            id: "album-1",
            name: "My Photos",
            path: "/albums/my-photos",
            photoCount: 10
        )
        
        XCTAssertEqual(album.id, "album-1")
        XCTAssertEqual(album.name, "My Photos")
        XCTAssertEqual(album.path, "/albums/my-photos")
        XCTAssertEqual(album.photoCount, 10)
    }
    
    // MARK: - Provider Tests
    
    func testCloud115ProviderInitialization() {
        let provider = Cloud115Provider()
        XCTAssertEqual(provider.providerName, "115 Cloud")
        XCTAssertFalse(provider.isAuthenticated)
    }
    
    func testWebDAVProviderInitialization() {
        let provider = WebDAVProvider()
        XCTAssertEqual(provider.providerName, "WebDAV")
        XCTAssertFalse(provider.isAuthenticated)
    }
    
    // MARK: - Service Tests
    
    func testPhotoManagerServiceInitialization() {
        let service = PhotoManagerService()
        XCTAssertTrue(service.photos.isEmpty)
        XCTAssertTrue(service.albums.isEmpty)
        XCTAssertFalse(service.isLoading)
        XCTAssertNil(service.error)
    }
    
    func testPhotoManagerServiceDisconnect() {
        let service = PhotoManagerService()
        service.disconnect()
        XCTAssertTrue(service.photos.isEmpty)
        XCTAssertTrue(service.albums.isEmpty)
    }
}
