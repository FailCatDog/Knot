import { EditProfileViewModel } from '../../viewmodels/EditProfileViewModel'
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
    // 创建新的ViewModel实例并加载用户信息
    this.viewModel = new EditProfileViewModel()
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
          // 头像上传（放在第一条）
          ListItem() {
            this.buildAvatarUpload()
          }

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
  buildAvatarUpload() {
    Column() {
      Row() {
        Text('头像')
          .fontSize(16)
          .fontColor('#1A1A1A')
          .width(80)

        Row({ space: 12 }) {
          // 头像预览
          if (this.viewModel.isUploadingAvatar) {
            Column() {
              LoadingProgress()
                .width(60)
                .height(60)
                .color('#ffdd0223')
            }
            .width(60)
            .height(60)
            .justifyContent(FlexAlign.Center)
            .borderRadius(30)
            .backgroundColor('#F5F5F5')
          } else {
            Image(this.viewModel.avatarUrl && this.viewModel.avatarUrl.trim() !== '' ? 
              this.viewModel.avatarUrl : $r('app.media.head'))
              .width(60)
              .height(60)
              .borderRadius(30)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.head'))
          }

          // 上传按钮
          Button(this.viewModel.isUploadingAvatar ? '上传中...' : '点击上传')
            .fontSize(14)
            .fontColor('#ffdd0223')
            .backgroundColor('#FFF')
            .border({ width: 1, color: '#ffdd0223' })
            .borderRadius(4)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .enabled(!this.viewModel.isUploadingAvatar)
            .onClick(async () => {
              const result = await this.viewModel.selectAndUploadAvatar()
              if (result.success) {
                ToastUtil.getInstance().show(result.message)
              } else {
                ToastUtil.getInstance().show(result.message || '上传失败')
              }
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
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
      
      // 更新全局登录状态（用户信息已更新，触发 ProfilePage 刷新）
      AppStorage.set<number>('loginTimestamp', Date.now())
      
      this.pathStack.pop()
    } else if (this.viewModel.errorMessage) {
      ToastUtil.getInstance().show(this.viewModel.errorMessage);
    }
  }
}

