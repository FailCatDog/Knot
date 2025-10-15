import { login } from '../../services/api/UserApi'
import { AuthPageType } from './AuthPage'
import { httpRequest, http } from '../../services/api/HttpRequest'
import { TokenManager } from '../../services/TokenManager'
import { common } from '@kit.AbilityKit'
// import getContext from '@ohos.application.appContext'
@Component
export struct LoginPage {
  @State username: string = 'zhangsan'
  @State password: string = 'password123'
  @State isLoading: boolean = false
  @State errorMessage: string = ''
  @State testResult: string = ''

  @Link currentPage: AuthPageType


  // 导航栈引用（如果有的话）
  @Consume('NavPathStack') navPathStack: NavPathStack
  //
  // // 页面加载时检查是否有有效的token
  // async aboutToAppear() {
  //   try {
  //     const tokenManager = TokenManager.getInstance()
  //     const token = await tokenManager.getToken()
  //
  //     if (token) {
  //       // 如果存在token，设置到httpRequest中
  //       httpRequest.setAuthToken(token)
  //       // 可以选择直接跳转到主页面
  //       // this.getUIContext().getRouter().replaceUrl({ url: 'pages/MainPage' })
  //     }
  //   } catch (error) {
  //     console.error('检查token状态失败:', (error as Error).message)
  //   }
  // }

  // 登录处理函数
  private async handleLogin() {
    if (!this.username || !this.password) {
      this.errorMessage = '请输入用户名和密码'
      return
    }

    this.isLoading = true
    this.errorMessage = ''

    try {
      const response = await login({
        username: this.username,
        password: this.password
      })

      if (response.success) {
        const tokenManager = TokenManager.getInstance()
        await tokenManager.saveToken(response.data.access_token)
        httpRequest.setAuthToken(response.data.access_token)
        this.errorMessage = '登录成功'

        try {
          let context = getContext(this) as common.UIAbilityContext;
          let eventHub = context.eventHub;
          eventHub.emit('userLoginStatusChanged', {
            isLoggedIn: true,
            userInfo: response.data.user
          });
        } catch (error) {
          console.error('发送事件失败:', error);
        }

        await this.getUIContext().getRouter().replaceUrl({
          url: 'pages/MainPage'
        })

        // // 根据是否有导航栈选择跳转方式
        // if (this.navPathStack) {
        //   // 如果有导航栈，使用导航栈跳转到主页面tabs
        //   this.navPathStack.pushPathByName('main-tabs', null, false)
        // } else {
        //   // 如果没有导航栈（独立页面），使用router跳转到主页面
        //   this.getUIContext().getRouter().replaceUrl({
        //     url: 'pages/MainPage'
        //   }).catch((err: Error) => {
        //     console.error('导航到主页面失败:', err.message)
        //   })
        // }
      } else {
        this.errorMessage = response.message || '登录失败'
      }
    } catch (error) {
      // 直接显示后端返回的错误信息
      this.errorMessage = (error as Error).message || '网络错误，请稍后重试'
      console.error('登录异常', (error as Error).message)
    } finally {
      this.isLoading = false
    }
  }

  // 测试网络连接的方法
  private async testNetworkConnection() {
    this.testResult = '测试中...';

    try {
      // 创建一个新的HTTP请求对象
      let httpRequestTest = http.createHttp();

      // 发起请求
      const response = await httpRequestTest.request(
        'http://8.138.115.164:8081/api-docs.html#',
        {
          method: http.RequestMethod.GET,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      // 检查响应状态码
      if (response.responseCode === 200) {
        this.testResult = 'API文档页面访问成功！';
      } else {
        this.testResult = `API文档页面访问失败，状态码: ${response.responseCode}`;
      }

      // 销毁HTTP请求对象
      httpRequestTest.destroy();
    } catch (error) {
      this.testResult = `网络连接测试失败: ${(error as Error).message}`;
      console.error('网络测试错误:', (error as Error).message);
    }
  }

  // 测试API接口连接的方法
  private async testApiConnection() {
    this.testResult = '测试中...';

    try {
      // 创建一个新的HTTP请求对象
      let httpRequestTest = http.createHttp();

      // 发起请求 - 测试API根路径
      const response = await httpRequestTest.request(
        'http://8.138.115.164:8080/api/v1/auth/login',
        {
          method: http.RequestMethod.GET,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      // 检查响应状态码
      if (response.responseCode === 405) {
        this.testResult = 'API接口正常：登录端点存在（GET方法不被允许，这是正常的）';
      } else if (response.responseCode === 200) {
        this.testResult = 'API接口正常：登录端点可访问';
      } else if (response.responseCode === 404) {
        this.testResult = 'API接口不存在，请检查API路径配置';
      } else {
        this.testResult = `API接口测试状态码: ${response.responseCode}`;
      }

      // 销毁HTTP请求对象
      httpRequestTest.destroy();
    } catch (error) {
      this.testResult = `API接口测试失败: ${(error as Error).message}`;
      console.error('API测试错误:', (error as Error).message);
    }
  }

  // 测试登录端点的方法
  private async testLoginEndpoint() {
    this.testResult = '测试中...';

    try {
      // 创建一个新的HTTP请求对象
      let httpRequestTest = http.createHttp();

      // 发起请求
      const response = await httpRequestTest.request(
        'http://8.138.115.164:8080/api/v1/auth/login',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ username: this.username || 'testuser', password: this.password || 'testpass' }),
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      // 检查响应状态码
      if (response.responseCode === 200) {
        interface LoginTestResponse {
          success: boolean;
          message: string;
        }

        const result = JSON.parse(response.result as string) as LoginTestResponse;
        if (result.success) {
          this.testResult = '登录端点访问成功！认证通过';
        } else {
          this.testResult = `登录端点访问成功，但登录失败: ${result.message}`;
        }
      } else if (response.responseCode === 401) {
        this.testResult = '登录端点访问成功，但认证失败';
      } else {
        this.testResult = `登录端点访问失败，状态码: ${response.responseCode}`;
      }

      // 销毁HTTP请求对象
      httpRequestTest.destroy();
    } catch (error) {
      this.testResult = `登录端点测试失败: ${(error as Error).message}`;
      console.error('登录端点测试错误:', (error as Error).message);
    }
  }

  build() {
    Column({ space: 24 }) {
      // 标题
      Text('登录')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100, bottom: 20 })

      // 表单区域
      Column({ space: 16 }) {
        // 用户名输入框
        TextInput({ text: this.username, placeholder: '请输入用户名' })
          .onChange((value: string) => {
            this.username = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })

        // 密码输入框
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

        // 错误提示
        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#FF0000')
            .textAlign(TextAlign.Center)
        }

        // 登录按钮
        Button('登录')
          .onClick(() => {
            this.handleLogin()
          })
          .width('80%')
          .height(50)
          .borderRadius(24)
          .backgroundColor('#FFDD0223')
          .fontColor('#FFFFFF')
          .enabled(!this.isLoading)

        // 加载指示器
        if (this.isLoading) {
          Progress({ value: 0, total: 100 })
            .width('80%')
            .color('#FFDD0223')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 注册跳转
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
      .margin({ top: 20 })

      // 添加测试网络连接的按钮
      Column() {
        Button('测试API文档页面')
          .width('80%')
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 20 })
          .onClick(() => {
            this.testNetworkConnection()
          })

        Button('测试API接口')
          .width('80%')
          .height(40)
          .backgroundColor('#4CAF50')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 10 })
          .onClick(() => {
            this.testApiConnection()
          })

        Button('测试登录端点')
          .width('80%')
          .height(40)
          .backgroundColor('#FF9800')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 10 })
          .onClick(() => {
            this.testLoginEndpoint()
          })

        // 显示测试结果
        if (this.testResult !== '') {
          Text(this.testResult)
            .fontSize(14)
            .fontColor(this.testResult.includes('成功') ? '#00FF00' : '#FF0000')
            .margin({ top: 10 })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding({ left: 20, right: 20 })
  }
}