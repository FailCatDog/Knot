import { AuthPageType } from './ProfilePage'
import { http } from '../../services/api/HttpRequest'

interface ExtendedRegisterRequest {
  username: string;
  password: string;
  email: string;
  real_name: string;
  phone: string;
  role: string;
}

interface UserInfo {
  id: number;
  user_id: string;
  username: string;
  email: string;
  phone: string;
  real_name: string;
  avatar_url: string;
  bio: string;
  location: string;
  gender: string;
  role: string;
  status: string;
  create_time: number;
  update_time: number;
  device_count: number;
}

interface RegisterApiResponse {
  success: boolean;
  message: string;
  data: UserInfo | null;
}

@Component
export struct RegisterPage {
  @State username: string = ''
  @State email: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State realName: string = ''
  @State phone: string = ''
  @State isLoading: boolean = false
  @State errorMessage: string = ''
  @State testResult: string = ''

  @Link currentPage: AuthPageType

  private async handleRegister() {
    if (!this.username) {
      this.errorMessage = '请输入用户名'
      return
    }

    if (!this.realName) {
      this.errorMessage = '请输入真实姓名'
      return
    }

    if (!this.phone) {
      this.errorMessage = '请输入手机号'
      return
    }

    const phoneRegex = /^1[3-9]\d{9}$/
    if (!phoneRegex.test(this.phone)) {
      this.errorMessage = '请输入有效的手机号'
      return
    }

    if (!this.email) {
      this.errorMessage = '请输入邮箱'
      return
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(this.email)) {
      this.errorMessage = '请输入有效的邮箱地址'
      return
    }

    if (!this.password) {
      this.errorMessage = '请输入密码'
      return
    }

    if (this.password.length < 6) {
      this.errorMessage = '密码长度至少6位'
      return
    }

    if (this.password !== this.confirmPassword) {
      this.errorMessage = '两次输入的密码不一致'
      return
    }

    this.isLoading = true
    this.errorMessage = ''

    try {
      const registerData: ExtendedRegisterRequest = {
        username: this.username,
        password: this.password,
        email: this.email,
        real_name: this.realName,
        phone: this.phone,
        role: 'USER'
      }

      const response = await this.extendedRegister(registerData)

      console.log('注册响应:', JSON.stringify(response))

      if (response.success) {
        console.log('注册成功', response.data)
        this.currentPage = AuthPageType.LOGIN
        this.errorMessage = '注册成功，请登录'
      } else {
        this.errorMessage = response.message || '注册失败'
      }
    } catch (error) {
      console.error('注册异常详情:', (error as Error).message)
      this.errorMessage = '网络错误，请稍后重试: ' + (error as Error).message
      console.error('注册异常', error)
    } finally {
      this.isLoading = false
    }
  }

  private async extendedRegister(param: ExtendedRegisterRequest): Promise<RegisterApiResponse> {
    let httpRequestTest: http.HttpRequest = http.createHttp();

    try {
      const response: http.HttpResponse = await httpRequestTest.request(
        'http://8.138.115.164:8080/api/v1/auth/register',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(param),
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      httpRequestTest.destroy();

      return JSON.parse(response.result as string) as RegisterApiResponse;
    } catch (error) {
      httpRequestTest.destroy();
      throw new Error((error as Error).message);
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50, bottom: 20 })

      Column({ space: 12 }) {
        TextInput({ text: this.username, placeholder: '请输入用户名' })
          .onChange((value: string) => {
            this.username = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })

        TextInput({ text: this.realName, placeholder: '请输入真实姓名' })
          .onChange((value: string) => {
            this.realName = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })

        TextInput({ text: this.phone, placeholder: '请输入手机号' })
          .onChange((value: string) => {
            this.phone = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })
          .type(InputType.Number)

        TextInput({ text: this.email, placeholder: '请输入邮箱' })
          .onChange((value: string) => {
            this.email = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })

        TextInput({
          text: this.password,
          placeholder: '请输入密码（至少6位）'
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

        TextInput({
          text: this.confirmPassword,
          placeholder: '请再次输入密码'
        })
          .onChange((value: string) => {
            this.confirmPassword = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })
          .type(InputType.Password)

        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#FF0000')
            .textAlign(TextAlign.Center)
        }

        Button('注册')
          .onClick(() => {
            this.handleRegister()
          })
          .width('80%')
          .height(50)
          .borderRadius(24)
          .backgroundColor('#FFDD0223')
          .fontColor('#FFFFFF')
          .enabled(!this.isLoading)

        if (this.isLoading) {
          Progress({ value: 0, total: 100 })
            .width('80%')
            .color('#FFDD0223')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#999999')

        Text('立即登录')
          .fontSize(14)
          .fontColor('#FFDD0223')
          .onClick(() => {
            this.currentPage = AuthPageType.LOGIN
          })
      }
      .margin({ top: 10 })

      Column() {
        Button('测试注册端点')
          .width('80%')
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 20 })
          .onClick(() => {
            this.testRegisterEndpoint()
          })

        if (this.testResult !== '') {
          Text(this.testResult)
            .fontSize(14)
            .fontColor(this.testResult.includes('成功') || this.testResult.includes('正常') ? '#00FF00' : '#FF0000')
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

  private async testRegisterEndpoint() {
    this.testResult = '测试中...';

    try {
      let httpRequestTest: http.HttpRequest = http.createHttp();

      const response: http.HttpResponse = await httpRequestTest.request(
        'http://8.138.115.164:8080/api/v1/auth/register',
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({
            username: 'testuser',
            password: 'password123',
            real_name: '测试用户',
            phone: '13800138888',
            email: 'test@example.com',
            role: 'USER'
          }),
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as RegisterApiResponse;
        if (result.success) {
          this.testResult = '注册端点访问成功！';
        } else {
          this.testResult = `注册端点访问成功，但注册失败: ${result.message}`;
        }
      } else if (response.responseCode === 400) {
        this.testResult = '注册端点访问成功，但参数验证失败（这是正常的）';
      } else {
        this.testResult = `注册端点访问失败，状态码: ${response.responseCode}`;
      }

      httpRequestTest.destroy();
    } catch (error) {
      this.testResult = `注册端点测试失败: ${(error as Error).message}`;
      console.error('注册端点测试错误:', (error as Error).message);
    }
  }
}
