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

  // 测试方法已注释 - 不再需要
  // private async testNetworkConnection() {
  //   this.testResult = '测试中...';
  //
  //   try {
  //     let httpRequestTest: http.HttpRequest = http.createHttp();

  //     const response: http.HttpResponse = await httpRequestTest.request(
  //       'http://8.138.115.164:8081/api-docs.html#',
  //       {
  //         method: http.RequestMethod.GET,
  //         connectTimeout: 10000,
  //         readTimeout: 10000
  //       }
  //     );
  //
  //     if (response.responseCode === 200) {
  //       this.testResult = 'API文档页面访问成功！';
  //     } else {
  //       this.testResult = `API文档页面访问失败，状态码: ${response.responseCode}`;
  //     }
  //
  //     httpRequestTest.destroy();
  //   } catch (error) {
  //     this.testResult = `网络连接测试失败: ${(error as Error).message}`;
  //     console.error('网络测试错误:', (error as Error).message);
  //   }
  // }
  //
  // private async testApiConnection() {
  //   this.testResult = '测试中...';
  //
  //   try {
  //     let httpRequestTest: http.HttpRequest = http.createHttp();
  //
  //     const response: http.HttpResponse = await httpRequestTest.request(
  //       'http://8.138.115.164:8080/api/v1/auth/login',
  //       {
  //         method: http.RequestMethod.GET,
  //         connectTimeout: 10000,
  //         readTimeout: 10000
  //       }
  //     );
  //
  //     if (response.responseCode === 405) {
  //       this.testResult = 'API接口正常：登录端点存在（GET方法不被允许，这是正常的）';
  //     } else if (response.responseCode === 200) {
  //       this.testResult = 'API接口正常：登录端点可访问';
  //     } else if (response.responseCode === 404) {
  //       this.testResult = 'API接口不存在，请检查API路径配置';
  //     } else {
  //       this.testResult = `API接口测试状态码: ${response.responseCode}`;
  //     }
  //
  //     httpRequestTest.destroy();
  //   } catch (error) {
  //     this.testResult = `API接口测试失败: ${(error as Error).message}`;
  //     console.error('API测试错误:', (error as Error).message);
  //   }
  // }
  //
  // private async testLoginEndpoint() {
  //   this.testResult = '测试中...';
  //
  //   try {
  //     let httpRequestTest: http.HttpRequest = http.createHttp();
  //
  //     const response: http.HttpResponse = await httpRequestTest.request(
  //       'http://8.138.115.164:8080/api/v1/auth/login',
  //       {
  //         method: http.RequestMethod.POST,
  //         header: { 'Content-Type': 'application/json' },
  //         extraData: JSON.stringify({ username: this.username || 'testuser', password: this.password || 'testpass' }),
  //         connectTimeout: 10000,
  //         readTimeout: 10000
  //       }
  //     );
  //
  //     if (response.responseCode === 200) {
  //       interface LoginTestResponse {
  //         success: boolean;
  //         message: string;
  //       }
  //
  //       const result = JSON.parse(response.result as string) as LoginTestResponse;
  //       if (result.success) {
  //         this.testResult = '登录端点访问成功！认证通过';
  //       } else {
  //         this.testResult = `登录端点访问成功，但登录失败: ${result.message}`;
  //       }
  //     } else if (response.responseCode === 401) {
  //       this.testResult = '登录端点访问成功，但认证失败';
  //     } else {
  //       this.testResult = `登录端点访问失败，状态码: ${response.responseCode}`;
  //     }
  //
  //     httpRequestTest.destroy();
  //   } catch (error) {
  //     this.testResult = `登录端点测试失败: ${(error as Error).message}`;
  //     console.error('登录端点测试错误:', (error as Error).message);
  //   }
  // }

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

      // 测试按钮已删除 - 不再需要
      // Column() {
      //   Button('测试API文档页面')
      //     .width('80%')
      //     .height(40)
      //     .backgroundColor('#007DFF')
      //     .fontColor('#FFFFFF')
      //     .borderRadius(8)
      //     .margin({ top: 20 })
      //     .onClick(() => {
      //       this.testNetworkConnection()
      //     })
      //
      //   Button('测试API接口')
      //     .width('80%')
      //     .height(40)
      //     .backgroundColor('#4CAF50')
      //     .fontColor('#FFFFFF')
      //     .borderRadius(8)
      //     .margin({ top: 10 })
      //     .onClick(() => {
      //       this.testApiConnection()
      //     })
      //
      //   Button('测试登录端点')
      //     .width('80%')
      //     .height(40)
      //     .backgroundColor('#FF9800')
      //     .fontColor('#FFFFFF')
      //     .borderRadius(8)
      //     .margin({ top: 10 })
      //     .onClick(() => {
      //       this.testLoginEndpoint()
      //     })
      //
      //   if (this.testResult !== '') {
      //     Text(this.testResult)
      //       .fontSize(14)
      //       .fontColor(this.testResult.includes('成功') ? '#00FF00' : '#FF0000')
      //       .margin({ top: 10 })
      //   }
      // }
      // .width('100%')
      // .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding({ left: 20, right: 20, bottom: 20 })
  }
}
