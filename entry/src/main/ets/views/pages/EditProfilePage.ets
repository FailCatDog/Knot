import { EditProfileViewModel } from '../../viewmodels/EditProfileViewModel'
import { common } from '@kit.AbilityKit'
import { ToastUtil } from '../../common/utils/ToastUtil'

@Builder
export function EditProfilePageBuilder() {
  EditProfilePage()
}

@Component
export struct EditProfilePage {
  @Consume('NavPathStack') pathStack: NavPathStack
  @State viewModel: EditProfileViewModel = new EditProfileViewModel()

  async aboutToAppear() {
    const result = await this.viewModel.loadUserInfo()
    if (!result.success) {
      ToastUtil.getInstance().show(result.message);
    }
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

          Text('编辑资料')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('保存')
            .fontSize(16)
            .fontColor('#ffdd0223')
            .margin({ right: 16 })
            .onClick(() => {
              this.handleSave()
            })
        }
        .width('100%')
        .height(56)
        .backgroundColor('#FFFFFF')

      if (this.viewModel.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#ffdd0223')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.viewModel.errorMessage && !this.viewModel.realName) {
        Column() {
          Image($r('app.media.ic_back'))
            .width(60)
            .height(60)
            .fillColor('#ccc')
          Text(this.viewModel.errorMessage)
            .fontSize(16)
            .fontColor('#666')
            .margin({ top: 16 })
          Button('重新加载')
            .fontSize(14)
            .backgroundColor('#ffdd0223')
            .fontColor('#fff')
            .margin({ top: 24 })
            .onClick(async () => {
              await this.viewModel.loadUserInfo()
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding(40)
      } else {
        List() {
          ListItem() {
            this.buildInputItem('真实姓名', this.viewModel.realName, (value: string) => {
              this.viewModel.realName = value
            }, true)
          }

          ListItem() {
            this.buildInputItem('手机号', this.viewModel.phone, (value: string) => {
              this.viewModel.phone = value
            }, true)
          }

          ListItem() {
            this.buildInputItem('邮箱', this.viewModel.email, (value: string) => {
              this.viewModel.email = value
            }, false)
          }

          ListItem() {
            this.buildInputItem('个人简介', this.viewModel.bio, (value: string) => {
              this.viewModel.bio = value
            }, false, true)
          }

          ListItem() {
            this.buildGenderSelector()
          }

          ListItem() {
            this.buildInputItem('所在地', this.viewModel.location, (value: string) => {
              this.viewModel.location = value
            }, false)
          }

          ListItem() {
            this.buildInputItem('头像URL', this.viewModel.avatarUrl, (value: string) => {
              this.viewModel.avatarUrl = value
            }, false)
          }
        }
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .divider({
          strokeWidth: 0.5,
          color: '#E5E5E5'
        })
      }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
  }

  @Builder
  buildInputItem(label: string, value: string, onChange: (value: string) => void, required: boolean, multiline: boolean = false) {
    Column() {
      Row() {
        Text(label)
          .fontSize(16)
          .fontColor('#1A1A1A')
          .width(80)

        if (required) {
          Text('*')
            .fontSize(16)
            .fontColor('#FF0000')
            .margin({ right: 8 })
        }

        if (multiline) {
          TextArea({ text: value })
            .layoutWeight(1)
            .height(80)
            .fontSize(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(0)
            .onChange((value: string) => {
              onChange(value)
            })
        } else {
          TextInput({ text: value })
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
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildGenderSelector() {
    Column() {
      Row() {
        Text('性别')
          .fontSize(16)
          .fontColor('#1A1A1A')
          .width(80)

        Row() {
          this.buildGenderOption('male', '男')
          this.buildGenderOption('female', '女')
          this.buildGenderOption('other', '其他')
          this.buildGenderOption('prefer_not_to_say', '保密')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildGenderOption(value: string, label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.viewModel.gender === value ? '#ffdd0223' : '#666')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .backgroundColor(this.viewModel.gender === value ? '#ffdd022310' : '#F5F5F5')
      .margin({ right: 8 })
      .onClick(() => {
        this.viewModel.gender = value
      })
  }

  async handleSave() {
    const result = await this.viewModel.saveUserInfo()
    
    if (result.success && result.userInfo) {
      ToastUtil.getInstance().show(result.message);
      
      try {
        let context = getContext(this) as common.UIAbilityContext
        let eventHub = context.eventHub
        eventHub.emit('userLoginStatusChanged', {
          isLoggedIn: true,
          userInfo: result.userInfo
        })
      } catch (error) {
        console.error('[EditProfilePage] 发送更新事件失败:', error)
      }
      
      this.pathStack.pop()
    } else if (this.viewModel.errorMessage) {
      ToastUtil.getInstance().show(this.viewModel.errorMessage);
    }
  }
}

