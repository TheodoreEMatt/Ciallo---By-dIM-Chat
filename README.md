# Ciallo,切络 - 一个去中心化即时通讯软件

# 构建于Decentralized Instant Messenger (dIM) 项目

*注意，本项目不做为「商业」或「大规模分发」，且保留原仓库GPL3.0 许可证。仅供小范围娱乐。

dIM 是一个开源的即时通讯工具，专为 iOS 设计。虽然也可以在 iPad 上运行，但并不能很好的运行。
dIM 可以在没有互联网连接的情况下工作，通过蓝牙发送和接收消息。为了达到最佳效果，需附近有其他 dIM 用户。更多信息请见这里： [can be found here](https://www.dimchat.org). (来自dIM的官方网页)。





![icon](./images/icon.png "dIM")

dIM项目的原始图标。(见上)

![icon](./images/NEWICON25%.png "dIM")

本复刻项目的新图标。（暂未计划更改，见上）

### 平台兼容性
- iOS 16.0 (或以上)
- iPadOS 16.0* (可能会有问题)
- MacOS (通过 Catalyst)

### 功能简介
- 可以向联系人收发消息
- 通过二维码添加联系人 (会使用相机)
- 将收发信息使用私钥加密
- 删除信息和信息线程
- 允许更改用户名

### 未来计划 
- [ ] 在安卓设备上构建 
- [ ] 聊天群组
- [ ] 链接
- [ ] 应用内通知消息
- [ ] 在经过 PR 审核后自动生成文稿

### 开始构建和使用
克隆本项目，并在iPhone上运行。但请注意，蓝牙功能并不在Xcode的内置模拟器中启用，因此必须使用物理设备进行蓝牙消息接收、发送等调试功能。

若将用户名设置为 `APPLEDEMO` 则会显示一个会话框。 这可以用来在模拟器环境中测试UI是否正常。（也可以用于Apple App Store的审核。）

#### 依赖资源*
该项目使用 [SwiftGen](https://github.com/SwiftGen/SwiftGen#configuration-file)。 它是一种允许类型的安全资产工具*

若要添加新资产，只需将他们添加到 `assets.xcassets` 文件中并运行 `> swiftgen`. 其类型安全资产将位于 `Assets+Generated.swift`中。

*注意，翻译并不准确，请参考原项目。

### 构建教程
打开项目，并到 `Product -> Build Documentation`. 这会创建一个DocC归档供你浏览。
