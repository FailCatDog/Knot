# Knot

Knot 是一个基于 ETS（Extended TypeScript）开发的社交应用，旨在为用户提供一个简洁、高效的社交平台。用户可以发布动态、浏览好友动态、点赞、评论、分享等。

## 功能特性

- **用户系统**：支持用户注册、登录、修改密码、编辑个人资料等功能。
- **动态发布**：用户可以发布图文动态，分享生活点滴。
- **动态浏览**：用户可以浏览自己和好友的动态，支持点赞、评论、分享等互动操作。
- **发现功能**：用户可以发现更多有趣的内容和用户。
- **收藏功能**：用户可以收藏喜欢的动态。
- **个人主页**：用户可以查看自己的个人主页，包括发布的动态、收藏的动态等。

## 技术栈

- **前端**：使用 ETS（Extended TypeScript）进行开发，基于 ArkUI 框架。
- **后端**：使用 MySQL 数据库，提供 RESTful API 接口。
- **网络请求**：使用自定义的 HTTP 请求工具进行网络通信。
- **状态管理**：使用 ViewModel 进行状态管理，确保数据与 UI 的分离。

## 目录结构

- **entry**：应用的主模块，包含应用的入口文件和资源文件。
  - **src/main/ets**：ETS 源代码目录。
    - **common/utils**：通用工具类，如 `LoginPreferences`、`ToastUtil` 等。
    - **entryability**：应用的入口能力，如 `EntryAbility`。
    - **models/entities**：数据模型，如 `PostEntity`、`PostDetailEntity` 等。
    - **pages**：页面组件，如 `MainPage`、`PostDetailPage` 等。
    - **services**：业务逻辑层，如 `TokenManager`、`ReadStatusManager` 等。
    - **services/api**：网络请求接口，如 `PostApi`、`CommentApi` 等。
    - **viewmodels**：ViewModel 层，如 `AuthViewModel`、`PostDetailViewModel` 等。
    - **views/components**：可复用的 UI 组件，如 `ImageCard`、`CommentSection` 等。
    - **views/pages**：具体的页面实现，如 `LoginPage`、`ProfilePage` 等。
- **resources**：资源文件目录，包含图片、颜色、字符串等资源。
- **docs**：文档目录，包含数据库脚本等。

## 安装与运行

1. **环境准备**：
   - 安装 [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio)。
   - 配置 HarmonyOS SDK。

2. **克隆项目**：
   ```bash
   git clone https://gitee.com/lxy-hgy-7/Knot.git
   ```

3. **导入项目**：
   - 打开 DevEco Studio，选择 `File > Open`，选择项目目录。

4. **运行项目**：
   - 连接设备或启动模拟器。
   - 点击 `Run` 按钮，选择目标设备，运行项目。

## 贡献指南

欢迎贡献代码和提出建议！请遵循以下步骤：

1. Fork 项目。
2. 创建新分支。
3. 提交代码更改。
4. 创建 Pull Request。

## 许可证

本项目使用 [MIT 许可证](LICENSE)。