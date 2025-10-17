import prompt from '@ohos.prompt'
import { ChangePasswordViewModel } from '../../viewmodels/ChangePasswordViewModel'

@Builder
export function ChangePasswordPageBuilder() {
  ChangePasswordPage()
}

@Component
export struct ChangePasswordPage {
  @Consume('NavPathStack') pathStack: NavPathStack
  viewModel: ChangePasswordViewModel = new ChangePasswordViewModel()

  async aboutToAppear() {
    const result = await this.viewModel.initialize()
    if (!result.success) {
      prompt.showToast({ message: result.message })
      this.pathStack.pop()
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
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .onClick(() => {
              this.pathStack.pop()
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
            this.buildPasswordInput('旧密码', '请输入旧密码', this.viewModel.oldPassword, (value: string) => {
              this.viewModel.oldPassword = value
            })
          }

          ListItem() {
            this.buildPasswordInput('新密码', '请输入新密码', this.viewModel.newPassword, (value: string) => {
              this.viewModel.newPassword = value
            })
          }

          ListItem() {
            this.buildPasswordInput('确认密码', '请再次输入新密码', this.viewModel.confirmPassword, (value: string) => {
              this.viewModel.confirmPassword = value
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
            .enabled(!this.viewModel.isSubmitting)
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
    .hideTitleBar(true)
  }

  private async handleChangePassword() {
    const result = await this.viewModel.changePassword()
    
    if (result.success) {
      prompt.showToast({ message: result.message })
      this.pathStack.pop()
    } else {
      prompt.showToast({ message: result.message })
    }
  }
}
