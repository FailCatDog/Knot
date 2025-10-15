import prompt from '@ohos.prompt'
import router from '@ohos.router'
import { changePassword, ChangePasswordRequest, getCurrentUserInfo } from '../../services/api/UserApi'

@Builder
export function ChangePasswordPageBuilder() {
  ChangePasswordPage()
}

@Entry
@Component
export struct ChangePasswordPage {
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State isSubmitting: boolean = false
  @State userId: number = 0

  async aboutToAppear() {
    const response = await getCurrentUserInfo()
    if (response.success && response.data) {
      this.userId = response.data.id
    } else {
      prompt.showToast({ message: '获取用户信息失败' })
      router.back()
    }
  }

  @Builder
  buildPasswordInput(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(16)
          .fontColor('#1A1A1A')
          .width(80)

        TextInput({ placeholder: placeholder, text: value })
          .type(InputType.Password)
          .layoutWeight(1)
          .fontSize(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(0)
          .onChange((value: string) => {
            onChange(value)
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })

        Text('修改密码')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(40)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      Column() {
        List() {
          ListItem() {
            this.buildPasswordInput('旧密码', '请输入旧密码', this.oldPassword, (value: string) => {
              this.oldPassword = value
            })
          }

          ListItem() {
            this.buildPasswordInput('新密码', '请输入新密码', this.newPassword, (value: string) => {
              this.newPassword = value
            })
          }

          ListItem() {
            this.buildPasswordInput('确认密码', '请再次输入新密码', this.confirmPassword, (value: string) => {
              this.confirmPassword = value
            })
          }

          ListItem() {
            Column() {
              Text('密码至少包含6个字符')
                .fontSize(12)
                .fontColor('#999999')
                .width('100%')
                .padding({ left: 16, top: 16, bottom: 8 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
          }
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
        .divider({
          strokeWidth: 0.5,
          color: '#E5E5E5'
        })
        .margin({ top: 16 })

        Blank()

        Column() {
          Button('确认修改')
            .width('90%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#ffdd0223')
            .borderRadius(24)
            .enabled(!this.isSubmitting)
            .onClick(() => {
              this.handleChangePassword()
            })
        }
        .width('100%')
        .padding({ top: 16, bottom: 32 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 处理修改密码
  private async handleChangePassword() {
    // 表单验证
    if (!this.oldPassword) {
      prompt.showToast({ message: '请输入旧密码' })
      return
    }

    if (!this.newPassword) {
      prompt.showToast({ message: '请输入新密码' })
      return
    }

    if (this.newPassword.length < 6 || this.newPassword.length > 100) {
      prompt.showToast({ message: '新密码长度需在6-100个字符之间' })
      return
    }

    if (this.newPassword !== this.confirmPassword) {
      prompt.showToast({ message: '两次输入的新密码不一致' })
      return
    }

    if (this.oldPassword === this.newPassword) {
      prompt.showToast({ message: '新密码不能与旧密码相同' })
      return
    }

    // 发起修改密码请求
    try {
      this.isSubmitting = true

      const param: ChangePasswordRequest = {
        user_id: this.userId,
        old_password: this.oldPassword,
        new_password: this.newPassword
      }

      const response = await changePassword(param)

      if (response.success) {
        prompt.showToast({ message: '密码修改成功' })
        // 返回设置页面
        router.back()
      } else {
        // 根据错误信息显示具体提示
        switch (response.message) {
          case '旧密码不正确':
            prompt.showToast({ message: '旧密码不正确' })
            break
          case '新密码格式不正确':
            prompt.showToast({ message: '新密码格式不正确' })
            break
          default:
            prompt.showToast({ message: response.message || '密码修改失败' })
        }
      }
    } catch (error) {
      console.error('修改密码失败:', error)
      prompt.showToast({ message: '网络请求失败，请稍后重试' })
    } finally {
      this.isSubmitting = false
    }
  }
}