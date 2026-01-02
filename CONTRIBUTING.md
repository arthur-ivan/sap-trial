# 贡献指南 (Contributing Guide)

感谢你考虑为115网盘照片管理器做出贡献！

## 如何贡献

### 报告问题 (Bug Reports)

如果你发现了bug，请创建一个Issue并包含以下信息：

1. **问题描述**: 清楚地描述问题
2. **复现步骤**: 详细的步骤让其他人能够复现问题
3. **期望行为**: 描述你期望发生什么
4. **实际行为**: 描述实际发生了什么
5. **环境信息**:
   - iOS版本
   - 设备型号
   - 应用版本
   - 使用的存储提供商 (115/WebDAV)

### 功能建议 (Feature Requests)

如果你有新功能的想法：

1. 创建一个Issue
2. 使用标签 `enhancement`
3. 清楚地描述:
   - 功能的用途
   - 为什么需要这个功能
   - 如何实现（如果有想法）

### 提交代码 (Pull Requests)

1. **Fork仓库**
2. **创建分支**: `git checkout -b feature/your-feature-name`
3. **编写代码**:
   - 遵循现有代码风格
   - 添加必要的注释
   - 确保代码通过测试
4. **提交更改**:
   - 使用清晰的提交信息
   - 中英文均可
5. **推送分支**: `git push origin feature/your-feature-name`
6. **创建Pull Request**

## 代码规范

### Swift代码风格

```swift
// 1. 使用4个空格缩进
// 2. 类型名使用大写驼峰 (UpperCamelCase)
// 3. 变量和函数使用小写驼峰 (lowerCamelCase)
// 4. 协议名以 -able/-ible 结尾或使用描述性名词

// Good
class PhotoManager {
    func loadPhotos() async throws -> [Photo] {
        // implementation
    }
}

// 5. 使用有意义的变量名
// Good
let photoCount = photos.count
// Avoid
let c = photos.count

// 6. 添加适当的注释
/// Loads all photos from the current storage provider
/// - Returns: Array of Photo objects
/// - Throws: StorageError if loading fails
func loadAllPhotos() async throws -> [Photo] {
    // implementation
}
```

### SwiftUI视图

```swift
// 1. 保持视图简洁
// 2. 将复杂逻辑提取到单独的方法或ViewModel
// 3. 使用有意义的子视图拆分

struct PhotoGridView: View {
    var body: some View {
        ScrollView {
            photoGrid
        }
    }
    
    private var photoGrid: some View {
        LazyVGrid(columns: columns) {
            // grid content
        }
    }
}
```

### 文件组织

```
PhotoManager115/
├── Sources/
│   ├── Models/          # 数据模型
│   ├── Services/        # 服务层
│   ├── Providers/       # 存储提供商
│   └── Utilities/       # 工具类
└── Tests/
    └── *Tests.swift     # 测试文件
```

## 测试要求

### 单元测试

- 为新功能添加单元测试
- 确保现有测试通过
- 测试覆盖率至少60%

```swift
func testPhotoInitialization() {
    let photo = Photo(...)
    XCTAssertEqual(photo.id, "expected-id")
}
```

### 集成测试

- 测试组件之间的交互
- Mock网络请求
- 验证数据流

## 文档要求

### 代码文档

- 使用Swift文档注释 (`///`)
- 为公开API添加文档
- 说明参数、返回值和异常

```swift
/// Downloads a photo from the storage provider
/// - Parameter photo: The photo to download
/// - Returns: Image data as Data object
/// - Throws: StorageError if download fails
public func downloadPhoto(photo: Photo) async throws -> Data {
    // implementation
}
```

### README更新

- 新功能需要更新README
- 添加使用示例
- 更新功能列表

## 版本控制

### 分支策略

- `main`: 稳定版本
- `develop`: 开发版本
- `feature/*`: 新功能
- `bugfix/*`: bug修复
- `hotfix/*`: 紧急修复

### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

类型 (type):
- `feat`: 新功能
- `fix`: bug修复
- `docs`: 文档更新
- `style`: 代码格式
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

示例:
```
feat(webdav): 添加WebDAV递归目录遍历

- 实现递归函数fetchPhotosRecursively
- 支持多层级目录结构
- 添加错误处理

Closes #123
```

## 许可协议

通过提交代码，你同意你的贡献将以MIT许可证发布。

## 行为准则

- 尊重所有贡献者
- 建设性地讨论
- 欢迎新手
- 专注于技术和解决方案

## 需要帮助？

- 查看现有Issues
- 阅读ARCHITECTURE.md了解架构
- 在Issue中提问
- 联系维护者

## 优先级任务

当前最需要的贡献：

1. **WebDAV XML解析改进**: 完善parseWebDAVResponse函数
2. **115 API完善**: 研究和实现更多115 API
3. **图片缓存优化**: 改进缓存策略
4. **视频支持**: 添加视频播放功能
5. **搜索功能**: 实现照片搜索
6. **UI改进**: 提升用户体验
7. **测试覆盖**: 增加测试用例
8. **文档完善**: 补充使用文档

感谢你的贡献！🎉
