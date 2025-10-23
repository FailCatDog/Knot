import { logout, LogoutRequest } from '../services/api/UserApi'
import { TokenManager } from '../services/TokenManager'
import { ToastUtil } from '../common/utils/ToastUtil'

/**
 * 设置页面构建器
 * 功能：创建设置页面实例
 * 使用场景：导航系统调用
 */
@Builder
export function SettingPageBuilder() {
  SettingPage()
}

/**
 * 设置页面组件
 * 功能：用户设置管理、个人资料编辑、密码修改、退出登录
 * 关键特性：完整的用户设置功能，支持导航跳转和状态管理
 * 安全功能：登录状态验证、安全退出登录
 */
@Component
export struct SettingPage {
  // ========== 导航管理 ==========
  @Consume('NavPathStack') pathStack: NavPathStack  // 导航栈，用于页面跳转

  /**
   * 页面初始化 - 调试方法
   * 功能：检查导航栈状态，确保页面正常显示
   * 调用时机：页面显示时自动调用
   */
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
              ToastUtil.getInstance().show('请先登录');
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
              ToastUtil.getInstance().show('请先登录');
              return
            }
            
            this.pathStack.pushPathByName('ChangePasswordPage', null, false)
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('隐私设置', () => {
            ToastUtil.getInstance().show('功能开发中');
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('通知设置', () => {
            ToastUtil.getInstance().show('功能开发中');
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('通用设置', () => {
            ToastUtil.getInstance().show('功能开发中');
          })
        }
        .height('auto')

        ListItem() {
          this.buildSettingItem('关于应用', () => {
            ToastUtil.getInstance().show('功能开发中');
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

  /**
   * 构建设置项 - UI组件方法
   * 功能：创建统一的设置项UI组件
   * 参数：title-设置项标题, onClick-点击回调函数
   * 设计：统一的设置项样式，包含标题和右箭头图标
   */
  @Builder
  buildSettingItem(title: string, onClick: () => void | Promise<void>) {
    Row() {
      // 🔑 关键：设置项标题
      Text(title)
        .fontSize(16)
        .fontColor('#1A1A1A')
        .layoutWeight(1)
        .margin({ left: 16 })

      // 🔑 关键：右箭头图标
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

  /**
   * 处理退出登录 - 核心安全功能
   * 功能：安全退出登录，清除本地数据，更新全局状态
   * 关键流程：验证token → 调用登出API → 清除本地数据 → 更新状态 → 跳转主页
   * 安全特性：完整的登出流程，确保数据安全
   */
  async handleLogout() {
    try {
      // 🔑 关键：获取当前用户token
      const tokenManager = TokenManager.getInstance()
      const token = await tokenManager.getToken()

      if (token) {
        // 🔑 关键：构建登出请求参数
        const logoutParam: LogoutRequest = {
          access_token: token
        }

        // 🔑 关键：调用登出API
        const response = await logout(logoutParam)
        
        if (response.success) {
          ToastUtil.getInstance().show('登出成功');
          
          // 🔑 关键：清除本地token
          await tokenManager.clearToken()
          
          // 🔑 关键：更新全局登录状态（触发其他页面刷新）
          AppStorage.set<boolean>('isUserLoggedIn', false)
          AppStorage.set<number>('logoutTimestamp', Date.now())
          
          // 🔑 关键：清空导航栈，跳转到主页面
          this.pathStack.clear()
        } else {
          ToastUtil.getInstance().show(response.message || '登出失败');
        }
      } else {
        // 🔑 关键：未找到token时的处理
        ToastUtil.getInstance().show('未找到用户token');
        this.pathStack.clear()
      }
    } catch (error) {
      console.error('[SettingPage] 退出登录失败:', error)
      ToastUtil.getInstance().show('网络请求失败');
    }
  }
}
