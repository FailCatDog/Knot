import router from '@ohos.router'
import prompt from '@ohos.prompt'
import { updateUserInfo, UpdateUserInfoRequest, UserInfo, getCurrentUserInfo } from '../../services/api/UserApi'
import { common } from '@kit.AbilityKit'

@Entry
@Component
export struct EditProfilePage {
  @State realName: string = ''
  @State phone: string = ''
  @State email: string = ''
  @State bio: string = ''
  @State gender: string = ''
  @State location: string = ''
  @State avatarUrl: string = ''
  @State isLoading: boolean = false

  async aboutToAppear() {
    await this.loadUserInfo()
  }

  async loadUserInfo() {
    this.isLoading = true
    const response = await getCurrentUserInfo()
    if (response.success && response.data) {
      const userInfo = response.data
      this.realName = userInfo.real_name || ''
      this.phone = userInfo.phone || ''
      this.email = userInfo.email || ''
      this.bio = userInfo.bio || ''
      this.gender = userInfo.gender || ''
      this.location = userInfo.location || ''
      this.avatarUrl = userInfo.avatar_url || ''
    }
    this.isLoading = false
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

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#ffdd0223')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ListItem() {
            this.buildInputItem('真实姓名', this.realName, (value: string) => {
              this.realName = value
            }, true)
          }

          ListItem() {
            this.buildInputItem('手机号', this.phone, (value: string) => {
              this.phone = value
            }, true)
          }

          ListItem() {
            this.buildInputItem('邮箱', this.email, (value: string) => {
              this.email = value
            }, false)
          }

          ListItem() {
            this.buildInputItem('个人简介', this.bio, (value: string) => {
              this.bio = value
            }, false, true)
          }

          ListItem() {
            this.buildGenderSelector()
          }

          ListItem() {
            this.buildInputItem('所在地', this.location, (value: string) => {
              this.location = value
            }, false)
          }

          ListItem() {
            this.buildInputItem('头像URL', this.avatarUrl, (value: string) => {
              this.avatarUrl = value
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
      .fontColor(this.gender === value ? '#ffdd0223' : '#666')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .backgroundColor(this.gender === value ? '#ffdd022310' : '#F5F5F5')
      .margin({ right: 8 })
      .onClick(() => {
        this.gender = value
      })
  }

  async handleSave() {
    if (!this.realName.trim()) {
      prompt.showToast({
        message: '请输入真实姓名'
      })
      return
    }

    if (!this.phone.trim()) {
      prompt.showToast({
        message: '请输入手机号'
      })
      return
    }

    const phoneRegex = /^1[3-9]\d{9}$/
    if (!phoneRegex.test(this.phone)) {
      prompt.showToast({
        message: '手机号格式不正确'
      })
      return
    }

    if (this.bio.length > 500) {
      prompt.showToast({
        message: '个人简介不能超过500个字符'
      })
      return
    }

    this.isLoading = true

    try {
      const updateParam: UpdateUserInfoRequest = {
        real_name: this.realName,
        phone: this.phone
      }

      if (this.email.trim()) {
        updateParam.email = this.email
      }
      if (this.bio.trim()) {
        updateParam.bio = this.bio
      }
      if (this.gender) {
        updateParam.gender = this.gender
      }
      if (this.location.trim()) {
        updateParam.location = this.location
      }
      if (this.avatarUrl.trim()) {
        updateParam.avatar_url = this.avatarUrl
      }

      const response = await updateUserInfo(updateParam)

      this.isLoading = false

      if (response.success) {
        prompt.showToast({
          message: '更新成功'
        })

        try {
          let context = getContext(this) as common.UIAbilityContext;
          let eventHub = context.eventHub;
          eventHub.emit('userLoginStatusChanged', {
            isLoggedIn: true,
            userInfo: response.data
          });
        } catch (error) {
          console.error('发送更新事件失败:', error);
        }

        router.back()
      } else {
        prompt.showToast({
          message: response.message || '更新失败'
        })
      }
    } catch (error) {
      this.isLoading = false
      console.error('更新用户信息失败:', error)
      prompt.showToast({
        message: '网络请求失败，请稍后重试'
      })
    }
  }
}

