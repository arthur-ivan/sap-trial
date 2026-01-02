import SwiftUI

struct ContentView: View {
    @EnvironmentObject var photoManager: PhotoManagerService
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            Group {
                if photoManager.photos.isEmpty && !photoManager.isLoading {
                    WelcomeView(showingSettings: $showingSettings)
                } else {
                    PhotoGridView()
                }
            }
            .navigationTitle("照片管理器")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct WelcomeView: View {
    @Binding var showingSettings: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("欢迎使用照片管理器")
                .font(.title)
                .fontWeight(.bold)
            
            Text("连接您的115网盘或WebDAV服务器开始管理照片")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingSettings = true
            }) {
                Text("开始设置")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PhotoManagerService())
    }
}
