# Knot

Knot is a social application developed using ETS (Extended TypeScript), designed to provide users with a concise and efficient social platform. Users can post updates, browse updates from friends, like posts, comment, share, and more.

## Features

- **User System**: Supports user registration, login, password change, profile editing, and more.
- **Post Creation**: Users can publish图文 updates to share moments from their daily lives.
- **Post Browsing**: Users can view their own and their friends' updates, with support for interactive actions such as liking, commenting, and sharing.
- **Discovery Feature**: Users can discover more interesting content and users.
- **Favorite Feature**: Users can save their favorite updates.
- **Personal Homepage**: Users can view their own homepage, including published updates, favorite updates, and more.

## Technology Stack

- **Frontend**: Developed using ETS (Extended TypeScript), based on the ArkUI framework.
- **Backend**: Uses MySQL database and provides RESTful API interfaces.
- **Network Requests**: Uses a custom HTTP request tool for network communication.
- **State Management**: Uses ViewModel for state management, ensuring separation of data and UI.

## Directory Structure

- **entry**: The main module of the application, containing the entry files and resource files.
  - **src/main/ets**: ETS source code directory.
    - **common/utils**: Common utility classes, such as `LoginPreferences`, `ToastUtil`, etc.
    - **entryability**: Application entry capabilities, such as `EntryAbility`.
    - **models/entities**: Data models, such as `PostEntity`, `PostDetailEntity`, etc.
    - **pages**: Page components, such as `MainPage`, `PostDetailPage`, etc.
    - **services**: Business logic layer, such as `TokenManager`, `ReadStatusManager`, etc.
    - **services/api**: Network request interfaces, such as `PostApi`, `CommentApi`, etc.
    - **viewmodels**: ViewModel layer, such as `AuthViewModel`, `PostDetailViewModel`, etc.
    - **views/components**: Reusable UI components, such as `ImageCard`, `CommentSection`, etc.
    - **views/pages**: Specific page implementations, such as `LoginPage`, `ProfilePage`, etc.
- **resources**: Resource file directory, containing images, colors, strings, and other resources.
- **docs**: Documentation directory, containing database scripts and more.

## Installation and Running

1. **Environment Setup**:
   - Install [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio).
   - Configure the HarmonyOS SDK.

2. **Clone the Project**:
   ```bash
   git clone https://gitee.com/lxy-hgy-7/Knot.git
   ```

3. **Import the Project**:
   - Open DevEco Studio, select `File > Open`, and choose the project directory.

4. **Run the Project**:
   - Connect a device or start an emulator.
   - Click the `Run` button and select the target device to run the project.

## Contribution Guide

Contributions of code and suggestions are welcome! Please follow these steps:

1. Fork the project.
2. Create a new branch.
3. Submit code changes.
4. Create a Pull Request.

## License

This project uses the [MIT License](LICENSE).