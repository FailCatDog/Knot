import { FollowPage } from '../views/pages/FollowPage'
import { DiscoverPage } from '../views/pages/DiscoverPage'
import { MessagePage } from '../views/pages/MessagePage'
import { SettingPage } from './SettingPage'
import { ProfilePage } from '../views/pages/ProfilePage'
import { PostDetailPageBuilder } from './PostDetailPage'
import { CreatePostPageBuilder } from './CreatePostPage'
// import { NavPathStack } from '@kit.ArkUI'
import { TokenManager } from '../services/TokenManager'

@Builder
export function MainPageBuilder() {
  MainPage()
}
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 1
  private tabsController: TabsController = new TabsController()
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack();
  // @Provide('onLogout') onLogout: () => void = this.handleLogout.bind(this)



  private lastValidIndex: number = 1

  // // 页面加载时检查是否有有效的token
  // async aboutToAppear() {
  //   try {
  //     const tokenManager = TokenManager.getInstance()
  //     const token = await tokenManager.getToken()
  //
  //     if (!token) {
  //       // 如果没有token，跳转到登录页面
  //       this.pathStack.pushPathByName('AuthPage', null, false)
  //     }
  //   } catch (error) {
  //     console.error('检查token状态失败:', error)
  //   }
  // }


  build() {
    Navigation(this.pathStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.tabsController }) {
          TabContent() {
            FollowPage()
          }
          .tabBar(this.TabBuilder('关注', 0))

          TabContent() {
            DiscoverPage()
          }
          .tabBar(this.TabBuilder('发现', 1))

          TabContent() {
          }
          .tabBar(this.AddTabBuilder())

          TabContent() {
            MessagePage()
          }
          .tabBar(this.TabBuilder('摄像馆', 3))

          TabContent() {
            ProfilePage()
          }
          .tabBar(this.TabBuilder('我的', 4))
        }
        .onChange((index: number) => {
          if (index === 2) {
            this.tabsController.changeIndex(this.lastValidIndex)
            this.currentIndex = this.lastValidIndex
            this.pathStack.pushPathByName('CreatePostPage', null, false)
            return
          }

          this.currentIndex = index
          this.lastValidIndex = index
        })
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')
        .barHeight(56)
        .barBackgroundColor('#F5F5F5')

        // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .navDestination(this.navDestinationBuilder)
  }



  @Builder
  navDestinationBuilder(name: string, param: Object) {
    if (name === 'CreatePostPage') {
      CreatePostPageBuilder()
    }
    if (name === 'PostDetailPage') {
      PostDetailPageBuilder()
    }
    if (name === 'MainPage') {
      // AuthPage()
      NavDestination() {
        // 在导航栈中显示AuthPage
      }
      .title('MainPage')
    }
  }

  // 处理登出
 async handleLogout() {
    try {
      // 清除token
      const tokenManager = TokenManager.getInstance()
      await tokenManager.clearToken()

      // 跳转到登录页面
      this.pathStack.pushPathByName('AuthPage', null, false)
    } catch (error) {
      console.error('登出失败:', error)
    }
  }

  @Builder
  TabBuilder(title: string, targetIndex: number) {
    Column() {
      Image(this.getTabIcon(targetIndex))
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === targetIndex ? '#ffdd0223' : '#999999')
        .margin({ bottom: 4 })

      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#ffdd0223' : '#999999')
        .fontSize(10)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .border({
      width: { top: 1 },
      color: { top: '#E5E5E5' }
    })
  }

  @Builder
  AddTabBuilder() {
    Column() {
      Image($r('app.media.ic_add'))
        .width(36)
        .height(36)
        .fillColor('#ffdd0223')
        .margin({ bottom: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .border({
      width: { top: 1 },
      color: { top: '#E5E5E5' }
    })
  }

  getTabIcon(index: number): Resource {
    const icons = [
      $r('app.media.ic_follow'),
      $r('app.media.ic_discover'),
      $r('app.media.ic_technology'),
      $r('app.media.ic_profile')
    ]
    // return icons[index]
    // 调整索引映射
    return icons[index > 2 ? index - 1 : index]
  }
}
// // 添加AuthPage作为隐藏的TabContent，仅用于路由跳转。wei
// TabContent() {
//   AuthPage()
// }
// .tabBar({ icon: "", text: "" })