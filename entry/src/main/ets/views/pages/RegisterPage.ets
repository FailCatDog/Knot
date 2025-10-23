import { AuthPageType } from './ProfilePage'
import { http } from '../../services/api/HttpRequest'
import { AuthViewModel } from '../../viewmodels/AuthViewModel'

// 注册API响应接口
interface RegisterApiResponse {
  success: boolean
  message: string
}

/**
 * 注册页面组件
 * 功能：新用户注册、表单验证、跳转登录
 * 关键特性：完整的用户信息收集，支持必填和可选字段
 */
@Component
export struct RegisterPage {
  // ========== 状态管理 ==========
  @State viewModel: AuthViewModel = new AuthViewModel()  // 认证业务逻辑
  @State username: string = ''                          // 用户名输入
  @State realName: string = ''                          // 真实姓名输入
  @State phone: string = ''                             // 手机号输入
  @State email: string = ''                             // 邮箱输入（可选）
  @State password: string = ''                          // 密码输入
  @State confirmPassword: string = ''                   // 确认密码输入

  @Link currentPage: AuthPageType  // 当前页面类型（登录/注册）

  /**
   * 处理用户注册 - 核心业务方法
   * 功能：收集用户信息，调用注册API，处理注册结果
   * 关键流程：表单验证 → API调用 → 注册成功 → 跳转登录页
   */
  private async handleRegister() {
    // 🔑 关键：调用认证服务进行用户注册
    const result = await this.viewModel.register(
      this.username,        // 用户名（必填）
      this.realName,        // 真实姓名（必填）
      this.phone,           // 手机号（必填）
      this.email,           // 邮箱（可选）
      this.password,        // 密码（必填）
      this.confirmPassword  // 确认密码（必填）
    )
    
    // 🔑 关键：注册成功后跳转到登录页面
    if (result.success) {
      this.currentPage = AuthPageType.LOGIN
    }
  }

  build() {
    Column({ space: 16 }) {
      Column({ space: 12 }) {
        TextInput({ text: this.username, placeholder: '请输入用户名（3-50字符）' })
          .margin({ top: 10 })
          .onChange((value: string) => {
            this.username = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })

        TextInput({ text: this.realName, placeholder: '请输入真实姓名 *' })
          .onChange((value: string) => {
            this.realName = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })

        TextInput({ text: this.phone, placeholder: '请输入手机号 *' })
          .onChange((value: string) => {
            this.phone = value
          })
          .width('80%')
          .height(50)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })
          .type(InputType.PhoneNumber)
          .maxLength(11)

        TextInput({ text: this.email, placeholder: '请输入邮箱（可选）' })
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
          placeholder: '请输入密码（至少8位）'
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

        if (this.viewModel.registerErrorMessage) {
          Text(this.viewModel.registerErrorMessage)
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
          .enabled(!this.viewModel.isRegisterLoading)

        if (this.viewModel.isRegisterLoading) {
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
      .margin({ top: 20, bottom: 40 })

      // 测试按钮已删除 - 不再需要
      // Column() {
      //   Button('测试注册端点')
      //     .width('80%')
      //     .height(40)
      //     .backgroundColor('#007DFF')
      //     .fontColor('#FFFFFF')
      //     .borderRadius(8)
      //     .margin({ top: 20 })
      //     .onClick(() => {
      //       this.testRegisterEndpoint()
      //     })
      //
      //   if (this.testResult !== '') {
      //     Text(this.testResult)
      //       .fontSize(14)
      //       .fontColor(this.testResult.includes('成功') || this.testResult.includes('正常') ? '#00FF00' : '#FF0000')
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

  // 测试方法已注释 - 不再需要
  // private async testRegisterEndpoint() {
  //   this.testResult = '测试中...';
  //
  //   try {
  //     let httpRequestTest: http.HttpRequest = http.createHttp();
  //
  //     const response: http.HttpResponse = await httpRequestTest.request(
  //       'http://8.138.115.164:8080/api/v1/auth/register',
  //       {
  //         method: http.RequestMethod.POST,
  //         header: { 'Content-Type': 'application/json' },
  //         extraData: JSON.stringify({
  //           username: 'testuser',
  //           password: 'password123',
  //           real_name: '测试用户',
  //           phone: '13800138888',
  //           email: 'test@example.com',
  //           role: 'driver'
  //         }),
  //         connectTimeout: 10000,
  //         readTimeout: 10000
  //       }
  //     );
  //
  //     if (response.responseCode === 200) {
  //       const result = JSON.parse(response.result as string) as RegisterApiResponse;
  //       if (result.success) {
  //         this.testResult = '注册端点访问成功！';
  //       } else {
  //         this.testResult = `注册端点访问成功，但注册失败: ${result.message}`;
  //       }
  //     } else if (response.responseCode === 400) {
  //       this.testResult = '注册端点访问成功，但参数验证失败（这是正常的）';
  //     } else {
  //       this.testResult = `注册端点访问失败，状态码: ${response.responseCode}`;
  //     }
  //
  //     httpRequestTest.destroy();
  //   } catch (error) {
  //     this.testResult = `注册端点测试失败: ${(error as Error).message}`;
  //     console.error('注册端点测试错误:', (error as Error).message);
  //   }
  // }
}
