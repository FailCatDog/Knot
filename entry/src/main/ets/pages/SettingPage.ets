import prompt from '@ohos.prompt'
import { logout, LogoutRequest } from '../services/api/UserApi'
import { TokenManager } from '../services/TokenManager'
import { common } from '@kit.AbilityKit'

@Builder
export function SettingPageBuilder() {
  SettingPage()
}

@Component
export struct SettingPage {
  @Consume('NavPathStack') pathStack: NavPathStack

  aboutToAppear(): void {
    console.log('[SettingPage] aboutToAppear called')
    console.log('[SettingPage] pathStack exists:', !!this.pathStack)
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

          Text('设置')
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

      List() {
        ListItem() {
          this.buildSettingItem('个人资料', async () => {
            const tokenManager = TokenManager.getInstance()
            const token = await tokenManager.getToken()
            
            if (!token) {
              prompt.showToast({ message: '请先登录' })
              return
            }
            
            this.pathStack.pushPathByName('EditProfilePage', null, false)
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('修改密码', async () => {
            const tokenManager = TokenManager.getInstance()
            const token = await tokenManager.getToken()
            
            if (!token) {
              prompt.showToast({ message: '请先登录' })
              return
            }
            
            this.pathStack.pushPathByName('ChangePasswordPage', null, false)
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('隐私设置', () => {
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('通知设置', () => {
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('通用设置', () => {
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('关于应用', () => {
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          Button('退出登录')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FF0000')
            .backgroundColor('#FFFFFF')
            .borderRadius(0)
            .onClick(() => {
              this.handleLogout()
            })
        }
        .height('auto')
      }
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .divider({
        strokeWidth: 0.5,
        color: '#E5E5E5',
        startMargin: 16
      })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
  }

  @Builder
  buildSettingItem(title: string, onClick: () => void | Promise<void>) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor('#1A1A1A')
        .layoutWeight(1)
        .margin({ left: 16 })

      Image($r('app.media.ic_chevron_right'))
        .width(20)
        .height(16)
        .margin({ right: 16 })
        .fillColor('#999999')
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      onClick()
    })
  }

  async handleLogout() {
    try {
      const tokenManager = TokenManager.getInstance()
      const token = await tokenManager.getToken()

      if (token) {
        const logoutParam: LogoutRequest = {
          access_token: token
        }

        const response = await logout(logoutParam)
        if (response.success) {
          prompt.showToast({
            message: '登出成功'
          })
          await tokenManager.clearToken()
          
          try {
            let context = getContext(this) as common.UIAbilityContext;
            let eventHub = context.eventHub;
            eventHub.emit('userLogoutStatusChanged', {
              isLoggedIn: false
            });
          } catch (error) {
            console.error('发送退出事件失败:', error);
          }
          
          this.pathStack.clear()
        } else {
          prompt.showToast({
            message: response.message || '登出失败'
          })
        }
      } else {
        prompt.showToast({
          message: '未找到用户token'
        })
        this.pathStack.clear()
      }
    } catch (error) {
      console.error('登出请求失败:', error)
      prompt.showToast({
        message: '网络请求失败'
      })
    }
  }
}
