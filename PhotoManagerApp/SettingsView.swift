import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var photoManager: PhotoManagerService
    @Environment(\.dismiss) var dismiss
    @State private var selectedProvider: StorageProvider = .cloud115
    @State private var showingAuthentication = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("存储提供商")) {
                    Picker("选择服务", selection: $selectedProvider) {
                        Text("115网盘").tag(StorageProvider.cloud115)
                        Text("WebDAV").tag(StorageProvider.webdav)
                    }
                    .pickerStyle(.segmented)
                    
                    Button(action: {
                        showingAuthentication = true
                    }) {
                        HStack {
                            Text("连接")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("照片管理")) {
                    Button(action: {
                        Task {
                            await photoManager.loadAllPhotos()
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("刷新照片")
                        }
                    }
                    
                    Button(action: {
                        photoManager.clearCache()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("清除缓存")
                        }
                    }
                }
                
                Section(header: Text("账户")) {
                    Button(action: {
                        photoManager.disconnect()
                        dismiss()
                    }) {
                        Text("断开连接")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("Photo Manager 115")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAuthentication) {
                if selectedProvider == .cloud115 {
                    Cloud115LoginView()
                } else {
                    WebDAVLoginView()
                }
            }
        }
    }
}

enum StorageProvider {
    case cloud115
    case webdav
}

struct Cloud115LoginView: View {
    @EnvironmentObject var photoManager: PhotoManagerService
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("115网盘账户")) {
                    TextField("用户名/邮箱", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                    
                    SecureField("密码", text: $password)
                        .textContentType(.password)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await authenticate()
                        }
                    }) {
                        if isAuthenticating {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("登录中...")
                                Spacer()
                            }
                        } else {
                            Text("登录")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(username.isEmpty || password.isEmpty || isAuthenticating)
                }
                
                Section {
                    Text("注意：115网盘的API可能需要额外的验证。此实现为演示版本。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("115网盘登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func authenticate() async {
        isAuthenticating = true
        errorMessage = nil
        
        do {
            try await photoManager.setup115Provider(username: username, password: password)
            await photoManager.loadAllPhotos()
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "登录失败：\(error.localizedDescription)"
                isAuthenticating = false
            }
        }
    }
}

struct WebDAVLoginView: View {
    @EnvironmentObject var photoManager: PhotoManagerService
    @Environment(\.dismiss) var dismiss
    @State private var serverURL = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("WebDAV服务器")) {
                    TextField("服务器地址", text: $serverURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    TextField("用户名", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                    
                    SecureField("密码", text: $password)
                        .textContentType(.password)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await authenticate()
                        }
                    }) {
                        if isAuthenticating {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("连接中...")
                                Spacer()
                            }
                        } else {
                            Text("连接")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(serverURL.isEmpty || username.isEmpty || password.isEmpty || isAuthenticating)
                }
                
                Section {
                    Text("示例：https://webdav.example.com/photos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("WebDAV登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func authenticate() async {
        isAuthenticating = true
        errorMessage = nil
        
        do {
            try await photoManager.setupWebDAVProvider(
                serverURL: serverURL,
                username: username,
                password: password
            )
            await photoManager.loadAllPhotos()
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "连接失败：\(error.localizedDescription)"
                isAuthenticating = false
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PhotoManagerService())
    }
}
