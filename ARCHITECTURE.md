# 技术架构文档 (Technical Architecture)

## 项目概述

115网盘照片管理器是一个基于SwiftUI开发的iOS应用，旨在提供类似iOS照片应用的体验，同时支持115网盘和WebDAV服务器作为后端存储。

## 架构设计

### 1. 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                     PhotoManagerApp                     │
│                    (iOS Application)                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────┐     │
│  │  Content   │  │   Photo      │  │  Settings   │     │
│  │   View     │  │ Grid/Detail  │  │    View     │     │
│  └──────┬─────┘  └──────┬───────┘  └──────┬──────┘     │
│         │               │                  │            │
│         └───────────────┴──────────────────┘            │
│                         │                               │
│                ┌────────▼────────┐                      │
│                │ PhotoManager    │                      │
│                │    Service      │                      │
│                └────────┬────────┘                      │
└─────────────────────────┼───────────────────────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌───────▼──────────┐              ┌────────▼────────┐
│ Cloud115Provider │              │ WebDAVProvider  │
└───────┬──────────┘              └────────┬────────┘
        │                                   │
        │                                   │
┌───────▼──────────┐              ┌────────▼────────┐
│   115 Cloud API  │              │  WebDAV Server  │
└──────────────────┘              └─────────────────┘
```

### 2. 核心模块

#### 2.1 数据层 (Data Layer)

**Models.swift**
- `Photo`: 照片数据模型
  - 属性: id, name, path, size, dates, URLs, mimeType
  - 实现: Identifiable, Codable
- `Album`: 相册数据模型
  - 属性: id, name, path, photoCount, coverPhotoURL
  - 实现: Identifiable, Codable

**CloudStorageProvider.swift**
- 定义云存储提供商的统一接口
- 主要方法:
  - `authenticate()`: 认证
  - `fetchAlbums()`: 获取相册列表
  - `fetchPhotos()`: 获取照片列表
  - `downloadPhoto()`: 下载照片
  - `downloadThumbnail()`: 下载缩略图

#### 2.2 服务层 (Service Layer)

**Cloud115Provider.swift**
- 实现115网盘的API集成
- 认证流程: username/password → session token
- API端点:
  - `/app/1.0/web/1.0/login`: 登录
  - `/files`: 文件列表
  - 文件下载需要带Authorization header

**WebDAVProvider.swift**
- 实现WebDAV协议
- 认证方式: HTTP Basic Authentication
- 核心操作:
  - PROPFIND: 列出目录内容
  - GET: 下载文件
- 支持递归遍历目录树

**PhotoManagerService.swift**
- 统一的照片管理接口
- 功能:
  - 提供商管理 (切换115/WebDAV)
  - 照片和相册加载
  - 图片缓存 (NSCache)
  - 状态管理 (loading, error)

#### 2.3 表现层 (Presentation Layer)

**ContentView.swift**
- 应用主界面
- 包含:
  - 欢迎页面 (未连接时)
  - 导航栏和工具栏
  - 设置按钮

**PhotoGridView.swift**
- 照片网格显示
- 特性:
  - LazyVGrid: 按需加载
  - 响应式布局
  - 下拉刷新
  - 错误处理和重试

**PhotoDetailView.swift**
- 照片详情和查看
- 特性:
  - 缩放手势 (pinch, double-tap)
  - 全屏显示
  - 文件信息
  - 分享和下载选项

**SettingsView.swift**
- 应用设置界面
- 功能:
  - 提供商选择
  - 登录界面
  - 缓存管理
  - 账户管理

### 3. 数据流

#### 3.1 认证流程

```
User Input (Credentials)
    ↓
SettingsView (Cloud115LoginView/WebDAVLoginView)
    ↓
PhotoManagerService.setup*Provider()
    ↓
Provider.authenticate()
    ↓
[Success] → loadAllPhotos()
    ↓
[Error] → Display Error Message
```

#### 3.2 照片加载流程

```
User Action (Open App / Refresh)
    ↓
PhotoManagerService.loadAllPhotos()
    ↓
Provider.fetchAllPhotos()
    ↓
[For 115] Provider.fetchAlbums() → fetchPhotos(in each album)
[For WebDAV] Provider.fetchPhotosRecursively(from root)
    ↓
Sort by modifiedDate
    ↓
Update PhotoManagerService.photos
    ↓
UI Update (PhotoGridView)
```

#### 3.3 图片显示流程

```
PhotoGridView renders Photo items
    ↓
PhotoThumbnailView.task { loadThumbnail() }
    ↓
PhotoManagerService.loadImage(thumbnail: true)
    ↓
Check NSCache
    ↓
[Cache Hit] → Return cached data
[Cache Miss] → Provider.downloadThumbnail()
    ↓
Cache the result
    ↓
Return image data
    ↓
Display in UI
```

### 4. 技术选型

#### 4.1 开发框架
- **SwiftUI**: 现代化的声明式UI框架
  - 优点: 简洁、响应式、跨平台
  - 适用: iOS 15+, macOS 12+
- **Swift Concurrency**: async/await异步编程
  - 优点: 可读性强、错误处理优雅
  - 用于所有网络请求

#### 4.2 网络通信
- **URLSession**: 系统原生HTTP客户端
  - 用于所有网络请求
  - 支持async/await
- **HTTP Basic Auth**: WebDAV认证
- **Bearer Token**: 115网盘认证

#### 4.3 缓存策略
- **NSCache**: 内存缓存
  - 缓存限制: 100张图片
  - 自动内存管理
  - 键格式: `{photo.id}_{thumb/full}`

#### 4.4 数据序列化
- **Codable**: Swift原生序列化
- **JSONSerialization**: JSON解析
- **XML**: WebDAV响应解析 (需要完善)

### 5. 安全考虑

#### 5.1 数据安全
- 认证信息仅存储在内存中
- 不持久化密码
- 建议使用HTTPS

#### 5.2 网络安全
- 支持TLS/SSL
- Info.plist中包含NSAppTransportSecurity配置
- 警告: 当前允许HTTP (NSAllowsArbitraryLoads)
  - 建议: 生产环境应限制为HTTPS only

#### 5.3 API安全
- 115网盘: 使用会话令牌
- WebDAV: Basic Authentication
- 建议: 使用应用专用密码

### 6. 性能优化

#### 6.1 图片加载
- 分离缩略图和全尺寸图片
- 按需加载 (LazyVGrid)
- 内存缓存避免重复下载

#### 6.2 列表性能
- LazyVGrid: 仅渲染可见项
- 异步加载: 不阻塞UI
- 防抖: 避免重复请求

#### 6.3 内存管理
- NSCache自动清理
- 大图片加载后及时释放
- 响应内存警告

### 7. 扩展性

#### 7.1 新增存储提供商
```swift
// 1. 创建新的Provider类
class NewStorageProvider: CloudStorageProvider {
    // 实现协议方法
}

// 2. 在PhotoManagerService中添加设置方法
func setupNewProvider(...) async throws {
    let provider = NewStorageProvider()
    try await provider.authenticate(...)
    currentProvider = provider
}

// 3. 在SettingsView中添加UI
```

#### 7.2 新增功能
- 相册视图: 显示文件夹结构
- 搜索: 添加搜索栏和过滤逻辑
- 视频: 扩展Photo模型和播放器
- 编辑: 集成图片编辑库

### 8. 测试策略

#### 8.1 单元测试
- 数据模型测试
- Provider初始化测试
- Service逻辑测试

#### 8.2 集成测试
- 网络请求mock
- 认证流程测试
- 数据加载测试

#### 8.3 UI测试
- SwiftUI Preview
- 手动测试
- 截图测试

### 9. 部署要求

#### 9.1 最低要求
- iOS 15.0+
- Xcode 14.0+
- Swift 5.9+

#### 9.2 推荐配置
- iOS 16.0+ (更好的SwiftUI支持)
- 网络连接
- 足够的存储空间 (用于缓存)

### 10. 已知限制

#### 10.1 115网盘
- API未公开，可能随时失效
- 需要逆向工程
- 可能违反服务条款
- 当前实现为演示版本

#### 10.2 WebDAV
- XML解析需要完善
- 不支持部分WebDAV扩展
- 缩略图生成需要改进

#### 10.3 通用限制
- 仅支持图片 (不支持视频)
- 无离线模式
- 无同步功能
- 无上传功能

## 总结

这个架构设计遵循了SOLID原则和iOS开发最佳实践:
- **S**ingle Responsibility: 每个类职责单一
- **O**pen/Closed: 通过协议扩展新提供商
- **L**iskov Substitution: 所有Provider可互换
- **I**nterface Segregation: 清晰的协议定义
- **D**ependency Inversion: 依赖抽象而非具体实现

未来可以继续优化和扩展功能，满足更多用户需求。
