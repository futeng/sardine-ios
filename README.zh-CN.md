# Sardine / 沙丁鱼

![Sardine 头像](assets/brand/exports/sardine-avatar-256.png)

Sardine 是一个自用 iOS 视频压缩工具，专门面向“交作业视频”：

- 拍作业纸
- 拍教材
- 拍讲解过程
- 拍白板 / 电脑屏幕 / PPT
- 需要发给老师或家长的小视频

目标不是做通用剪辑软件，而是解决一个很具体的问题：

> 文字基本看清，声音保持清楚，视频体积尽量变小，并且全流程在 iPhone 本机完成。

## 为什么叫 Sardine

沙丁鱼小、紧凑、容易记住，也天然有“压进罐头”的联想。

这个名字和之前的海洋生物项目 `Marlin` 保持同一命名体系：短、好传播、有画面感。

## 当前状态

这个仓库已经初始化为“技术方案 + iOS App 骨架”：

- 技术实现文档
- 压缩参数设计
- 品牌头像和 AppIcon 素材
- SwiftUI 源码骨架
- XcodeGen 项目配置
- 给后续 AI Agent 的开发交接说明

真正的视频压缩引擎还没有实现，下一步应优先实现 AVFoundation 管线。

## 如何开始

建议用 XcodeGen 生成 Xcode 项目：

```bash
brew install xcodegen
xcodegen generate
open Sardine.xcodeproj
```

然后运行 `Sardine` scheme。

注意：视频压缩性能、相册权限、保存相册等行为必须用真机测试。模拟器只能做界面和基础逻辑验证。

## 默认压缩策略

第一版默认档位建议：

| 参数 | 值 |
|---|---|
| 编码 | HEVC / H.265 |
| 容器 | MP4 |
| 分辨率 | 长边不超过 1920 |
| 帧率 | 最高 30fps |
| 视频码率 | 1.5Mbps |
| 音频 | 优先保留原音频，失败则 AAC 96kbps |

如果是教材、试卷、手写字这类文字很多的视频，使用 2.0Mbps。

不要默认降到 720p。作业视频的文字细节很容易在 720p 下丢掉。

## 文档

- [技术设计](docs/technical-design.md)
- [压缩档位](docs/compression-presets.md)
- [品牌指南](docs/brand.md)
- [分发方案](docs/distribution.md)
- [测试计划](docs/test-plan.md)
- [Agent 交接](docs/agent-handoff.md)

## 隐私原则

Sardine 应该只在本机处理视频。默认不加：

- 账号系统
- 云端上传
- 服务端压缩
- 埋点统计
- 第三方 SDK

如果未来要加入任何网络能力，必须先更新技术设计和隐私说明。

## License

MIT License. See [LICENSE](LICENSE).
