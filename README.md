# 115网盘照片管理器 (115 Cloud Photo Manager)

一个功能强大的iOS照片管理应用，支持连接115网盘和WebDAV服务器，以相册应用的形式管理云端照片。

## 功能特性

### 核心功能
- ✅ **115网盘集成** - 连接115网盘账户，访问云端照片
- ✅ **WebDAV支持** - 兼容任何WebDAV服务器（如Nextcloud、ownCloud等）
- ✅ **照片网格视图** - 类似iOS照片应用的网格布局
- ✅ **照片详情视图** - 支持缩放、双击放大等手势操作
- ✅ **智能缓存** - 自动缓存已查看的照片，提升浏览速度
- ✅ **下拉刷新** - 快速同步最新照片

### 用户界面
- 现代化SwiftUI设计
- 中文本地化界面
- 支持深色模式
- 流畅的动画和过渡效果

## 项目结构

```
sap-trial/
├── PhotoManager115/          # 核心库
│   ├── Package.swift         # Swift包配置
│   ├── Sources/
│   │   ├── Models.swift                  # 数据模型（Photo, Album）
│   │   ├── CloudStorageProvider.swift    # 存储提供商协议
│   │   ├── Cloud115Provider.swift        # 115网盘实现
│   │   ├── WebDAVProvider.swift          # WebDAV实现
│   │   └── PhotoManagerService.swift     # 照片管理服务
│   └── Tests/
└── PhotoManagerApp/          # iOS应用
    ├── PhotoManagerApp.swift       # 应用入口
    ├── ContentView.swift           # 主视图
    ├── PhotoGridView.swift         # 照片网格
    ├── PhotoDetailView.swift       # 照片详情
    ├── SettingsView.swift          # 设置界面
    └── Info.plist                  # 应用配置
```

## 技术架构

### 核心组件

#### 1. 数据模型
- **Photo**: 照片对象，包含ID、名称、路径、大小、日期等信息
- **Album**: 相册对象，表示照片文件夹

#### 2. 存储提供商
- **CloudStorageProvider**: 定义云存储操作的协议
  - 认证（authenticate）
  - 获取相册（fetchAlbums）
  - 获取照片（fetchPhotos）
  - 下载照片（downloadPhoto/downloadThumbnail）

- **Cloud115Provider**: 115网盘实现
  - 使用115 Cloud API
  - 处理认证和会话管理
  - 支持照片列表和下载

- **WebDAVProvider**: WebDAV实现
  - 标准WebDAV协议
  - PROPFIND获取文件列表
  - Basic Authentication

#### 3. 照片管理服务
- **PhotoManagerService**: 统一的照片管理接口
  - 提供商切换
  - 照片加载和缓存
  - 状态管理（ObservableObject）

### UI组件

#### 1. ContentView
- 应用主视图
- 欢迎页面
- 导航和工具栏

#### 2. PhotoGridView
- 照片网格显示
- LazyVGrid延迟加载
- 下拉刷新支持
- 错误处理

#### 3. PhotoDetailView
- 全屏照片查看
- 缩放手势支持
- 照片信息显示
- 分享和下载功能

#### 4. SettingsView
- 存储提供商选择
- 登录界面（115/WebDAV）
- 缓存管理
- 账户设置

## 快速开始

### 环境要求
- iOS 15.0 或更高版本
- Xcode 14.0 或更高版本
- Swift 5.9 或更高版本

### 安装步骤

1. 克隆仓库
```bash
git clone https://github.com/arthur-ivan/sap-trial.git
cd sap-trial
```

2. 使用Xcode打开项目
```bash
open PhotoManagerApp/PhotoManagerApp.swift
```

3. 选择目标设备（iPhone模拟器或真机）

4. 运行应用（⌘+R）

### 使用115网盘

1. 打开应用
2. 点击"开始设置"
3. 选择"115网盘"
4. 输入115账号和密码
5. 点击"登录"
6. 等待照片加载完成

### 使用WebDAV

1. 打开应用
2. 点击"开始设置"
3. 选择"WebDAV"
4. 输入服务器地址、用户名和密码
   - 示例：https://webdav.example.com/photos
5. 点击"连接"
6. 等待照片加载完成

## 注意事项

### 115网盘
- ⚠️ **重要**: 115网盘的API不是公开的，当前实现是基于网络分析的逆向工程
- 115可能会更改其API，导致功能失效
- 建议仅用于个人学习和研究
- 使用时请遵守115网盘的服务条款

### WebDAV
- ✅ 支持任何标准的WebDAV服务器
- ✅ 推荐使用HTTPS保护数据传输
- ✅ 经过测试的服务器：
  - Nextcloud
  - ownCloud
  - Synology NAS
  - QNAP NAS

### 性能优化
- 使用NSCache缓存已加载的图片
- LazyVGrid实现按需加载
- 支持缩略图和全尺寸图片分离下载

### 隐私和安全
- 所有认证信息仅存储在本地
- 使用HTTPS加密传输（如果服务器支持）
- 不会收集或上传用户数据
- 建议使用应用专用密码而非主密码

## 开发路线图

### 已完成
- [x] 基础项目结构
- [x] 115网盘集成
- [x] WebDAV支持
- [x] 照片网格视图
- [x] 照片详情视图
- [x] 缓存机制
- [x] 设置界面

### 计划中
- [ ] 相册视图
- [ ] 搜索功能
- [ ] 照片排序和筛选
- [ ] 批量下载
- [ ] 照片编辑（裁剪、滤镜等）
- [ ] 视频支持
- [ ] iCloud同步
- [ ] 分享扩展
- [ ] Widget支持
- [ ] macOS版本

## 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

## 许可证

本项目仅供学习和研究使用。

## 联系方式

- GitHub Issues: https://github.com/arthur-ivan/sap-trial/issues

## 致谢

感谢所有为此项目做出贡献的开发者和用户。

---

**免责声明**: 本应用仅供学习和个人使用。使用115网盘功能时，请遵守115的服务条款。开发者不对任何使用本应用导致的问题负责。
