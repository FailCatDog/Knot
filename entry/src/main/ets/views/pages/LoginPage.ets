import { AuthPageType } from './ProfilePage'
import { http } from '../../services/api/HttpRequest'
import { AuthViewModel } from '../../viewmodels/AuthViewModel'
import { LoginPreferences } from '../../common/utils/LoginPreferences'
import { common } from '@kit.AbilityKit'

/**
 * 登录页面组件
 * 功能：用户登录、记住密码、自动填充用户名
 * 关键特性：支持记住密码功能，自动保存和恢复登录信息
 */
@Component
export struct LoginPage {
  // ========== 状态管理 ==========
  @State viewModel: AuthViewModel = new AuthViewModel()  // 认证业务逻辑
  @State username: string = ''                          // 用户名输入
  @State password: string = ''                          // 密码输入
  @State rememberPassword: boolean = false              // 是否记住密码
  @Consume('NavPathStack') pathStack: NavPathStack      // 导航栈
  
  // ========== 核心组件 ==========
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private loginPreferences: LoginPreferences = LoginPreferences.getInstance()  // 登录信息存储管理

  @Link currentPage: AuthPageType  // 当前页面类型（登录/注册）

  /**
   * 页面初始化 - 关键方法
   * 功能：初始化本地存储，自动加载保存的登录信息
   * 调用时机：页面显示时自动调用
   */
  async aboutToAppear(): Promise<void> {
    // 🔑 关键：初始化本地存储系统
    await this.loginPreferences.init(this.context)
    // 🔑 关键：自动加载保存的登录信息
    await this.loadSavedLoginInfo()
  }

  /**
   * 加载保存的登录信息 - 核心功能
   * 功能：从本地存储中读取用户名、密码和记住密码状态
   * 用户体验：实现自动填充，提升登录便利性
   */
  private async loadSavedLoginInfo(): Promise<void> {
    try {
      // 🔑 关键：获取保存的用户名（始终保存）
      const savedUsername = await this.loginPreferences.getSavedUsername()
      // 🔑 关键：获取保存的密码（仅当勾选记住密码时）
      const savedPassword = await this.loginPreferences.getSavedPassword()
      // 🔑 关键：获取记住密码状态
      const rememberPassword = await this.loginPreferences.getRememberPassword()
      
      // 自动填充用户名
      if (savedUsername) {
        this.username = savedUsername
        console.log('[LoginPage] 已加载保存的用户名')
      }
      
      // 自动填充密码（仅当之前勾选了记住密码）
      if (rememberPassword && savedPassword) {
        this.password = savedPassword
        this.rememberPassword = true
        console.log('[LoginPage] 已加载保存的密码')
      }
    } catch (error) {
      console.error('[LoginPage] 加载保存的登录信息失败:', error)
    }
  }

  /**
   * 处理登录逻辑 - 核心业务方法
   * 功能：验证用户凭据，保存登录信息，更新全局状态
   * 关键流程：登录验证 → 保存信息 → 更新状态 → 跳转主页
   */
  private async handleLogin() {
    // 🔑 关键：调用认证服务进行登录验证
    const result = await this.viewModel.login(this.username, this.password)
    
    if (result.success && result.userInfo) {
      // 🔑 关键：保存登录信息到本地存储
      await this.loginPreferences.saveLoginInfo(this.username, this.password, this.rememberPassword)
      
      // 🔑 关键：更新全局登录状态（触发其他页面刷新）
      AppStorage.set<boolean>('isUserLoggedIn', true)
      AppStorage.set<number>('loginTimestamp', Date.now())
      
      // 🔑 关键：清空导航栈，跳转到主页面
      this.pathStack.clear()
    }
  }


  build() {
    Column({ space: 24 }) {
      // Logo图片
      Image($r("app.media.ic_logo"))
        .width(120)
        .height(120)
        .margin({ top: 5, bottom: 1 })
        .objectFit(ImageFit.Contain)

      // KONT字样
      Text('Kont')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .letterSpacing(4)
        .margin({ bottom: 2 })

      Column({ space: 16 }) {
        TextInput({ text: this.username, placeholder: '请输入用户名' })
          .onChange((value: string) => {
            this.username = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })

        TextInput({
          text: this.password,
          placeholder: '请输入密码'
        })
          .onChange((value: string) => {
            this.password = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })
          .type(InputType.Password)

        // 记住密码勾选框
        Row({ space: 8 }) {
          Checkbox({ name: 'rememberPassword' })
            .select(this.rememberPassword)
            .selectedColor('#FFDD0223')
            .onChange((value: boolean) => {
              this.rememberPassword = value
              console.log('[LoginPage] 记住密码:', value)
            })
          
          Text('记住密码')
            .fontSize(14)
            .fontColor('#666666')
            .onClick(() => {
              this.rememberPassword = !this.rememberPassword
            })
        }
        .width('80%')
        .justifyContent(FlexAlign.Start)

        if (this.viewModel.loginErrorMessage) {
          Text(this.viewModel.loginErrorMessage)
            .fontSize(14)
            .fontColor('#FF0000')
            .textAlign(TextAlign.Center)
        }

        Button('登录')
          .onClick(() => {
            this.handleLogin()
          })
          .width('80%')
          .height(50)
          .borderRadius(24)
          .backgroundColor('#FFDD0223')
          .fontColor('#FFFFFF')
          .enabled(!this.viewModel.isLoginLoading)

        if (this.viewModel.isLoginLoading) {
          Progress({ value: 0, total: 100 })
            .width('80%')
            .color('#FFDD0223')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#999999')

        Text('立即注册')
          .fontSize(14)
          .fontColor('#FFDD0223')
          .onClick(() => {
            this.currentPage = AuthPageType.REGISTER
          })
      }
      .margin({ top: 1, bottom: 40 })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding({ left: 20, right: 20, bottom: 20 })
  }
}
