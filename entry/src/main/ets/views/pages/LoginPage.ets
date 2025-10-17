import { AuthPageType } from './ProfilePage'
import { http } from '../../services/api/HttpRequest'
import { common } from '@kit.AbilityKit'
import { AuthViewModel } from '../../viewmodels/AuthViewModel'

@Component
export struct LoginPage {
  @State viewModel: AuthViewModel = new AuthViewModel()
  @State username: string = 'zhangsan'
  @State password: string = 'password123'
  @State testResult: string = ''

  @Link currentPage: AuthPageType
  @Consume('NavPathStack') pathStack: NavPathStack

  private async handleLogin() {
    const result = await this.viewModel.login(this.username, this.password)
    
    if (result.success && result.userInfo) {
      try {
        let context = getContext(this) as common.UIAbilityContext
        let eventHub = context.eventHub
        eventHub.emit('userLoginStatusChanged', {
          isLoggedIn: true,
          userInfo: result.userInfo
        })
      } catch (error) {
        console.error('[LoginPage] 发送事件失败:', error)
      }
      
      this.pathStack.clear()
    }
  }

  private async testNetworkConnection() {
    this.testResult = '测试中...';

    try {
      let httpRequestTest: http.HttpRequest = http.createHttp();

      const response: http.HttpResponse = await httpRequestTest.request(
        'http://8.138.115.164:8081/api-docs.html#',
        {
          method: http.RequestMethod.GET,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      if (response.responseCode === 200) {
        this.testResult = 'API文档页面访问成功！';
      } else {
        this.testResult = `API文档页面访问失败，状态码: ${response.responseCode}`;
      }

      httpRequestTest.destroy();
    } catch (error) {
      this.testResult = `网络连接测试失败: ${(error as Error).message}`;
      console.error('网络测试错误:', (error as Error).message);
    }
  }

  private async testApiConnection() {
    this.testResult = '测试中...';

    try {
      let httpRequestTest: http.HttpRequest = http.createHttp();

      const response: http.HttpResponse = await httpRequestTest.request(
        'http://8.138.115.164:8080/api/v1/auth/login',
        {
          method: http.RequestMethod.GET,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      if (response.responseCode === 405) {
        this.testResult = 'API接口正常：登录端点存在（GET方法不被允许，这是正常的）';
      } else if (response.responseCode === 200) {
        this.testResult = 'API接口正常：登录端点可访问';
      } else if (response.responseCode === 404) {
        this.testResult = 'API接口不存在，请检查API路径配置';
      } else {
        this.testResult = `API接口测试状态码: ${response.responseCode}`;
      }

      httpRequestTest.destroy();
    } catch (error) {
      this.testResult = `API接口测试失败: ${(error as Error).message}`;
      console.error('API测试错误:', (error as Error).message);
    }
  }

  private async testLoginEndpoint() {
    this.testResult = '测试中...';

    try {
      let httpRequestTest: http.HttpRequest = http.createHttp();

      const response: http.HttpResponse = await httpRequestTest.request(
        'http://8.138.115.164:8080/api/v1/auth/login',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ username: this.username || 'testuser', password: this.password || 'testpass' }),
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

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

      httpRequestTest.destroy();
    } catch (error) {
      this.testResult = `登录端点测试失败: ${(error as Error).message}`;
      console.error('登录端点测试错误:', (error as Error).message);
    }
  }

  build() {
    Column({ space: 24 }) {
      Column({ space: 16 }) {
        TextInput({ text: this.username, placeholder: '请输入用户名' })
          .margin({ top: 100 })
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
      .margin({ top: 20 })

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
