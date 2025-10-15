import router from '@ohos.router'
import prompt from '@ohos.prompt'
import { logout, LogoutRequest } from '../services/api/UserApi'
import { httpRequest } from '../services/api/HttpRequest'
import { TokenManager } from '../services/TokenManager'
import { common } from '@kit.AbilityKit'

@Entry
@Component
export struct SettingPage {
  // @Consume('NavPathStack') navPathStack: NavPathStack
  build() {
    Column() {
      Row() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      // 设置项列表
      List() {
        ListItem() {
          this.buildSettingItem('个人资料', () => {
            router.pushUrl({
              url: 'views/pages/EditProfilePage'
            }).catch((err: Error) => {
              console.error('导航到编辑资料页面失败:', err.message)
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('修改密码', () => {
            // 导航到修改密码页面
            router.pushUrl({
              url: 'views/pages/ChangePasswordPage'
            }).catch((err: Error) => {
              console.error('导航到修改密码页面失败:', err.message)
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('隐私设置', () => {
            // 导航到隐私设置页面
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('通知设置', () => {
            // 导航到通知设置页面
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('通用设置', () => {
            // 导航到通用设置页面
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('关于应用', () => {
            // 导航到关于页面
            prompt.showToast({
              message: '功能开发中'
            })
          })
        }
        .height('auto')

        ListItem() {
          // 退出登录按钮
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

  @Builder
  buildSettingItem(title: string, onClick: () => void) {
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
      // 从持久化存储中获取access_token
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
          // 清除内存中的token
          httpRequest.setAuthToken('')
          // 清除持久化的token
          await tokenManager.clearToken()
          
          // 发送退出登录事件通知ProfilePage
          try {
            let context = getContext(this) as common.UIAbilityContext;
            let eventHub = context.eventHub;
            eventHub.emit('userLogoutStatusChanged', {
              isLoggedIn: false
            });
          } catch (error) {
            console.error('发送退出事件失败:', error);
          }
          
          // 返回主页面
          router.replaceUrl({
            url: 'pages/MainPage'
          }).catch((err: Error) => {
            console.error('导航到主页面失败:', err.message)
          })
        } else {
          prompt.showToast({
            message: response.message || '登出失败'
          })
        }
      } else {
        // 即使没有token，也跳转到登录页面
        prompt.showToast({
          message: '未找到用户token，将跳转到登录页面'
        })
        router.replaceUrl({
          url: 'views/pages/AuthPage'
          // url: 'pages/MainPage' // 测试用
        }).catch((err: Error) => {
          console.error('导航到登录页面失败:', err.message)
        })
      }
    } catch (error) {
      console.error('登出请求失败:', error)
      prompt.showToast({
        message: '网络请求失败'
      })
    }
  }
}