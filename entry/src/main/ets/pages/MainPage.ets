import { FollowPage } from '../views/pages/FollowPage'
import { DiscoverPage } from '../views/pages/DiscoverPage'
import { GalleryPage } from '../views/pages/GalleryPage'
import { ProfilePage } from '../views/pages/ProfilePage'
import { TokenManager } from '../services/TokenManager'
import { ToastUtil } from '../common/utils/ToastUtil'

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 1
  private tabsController: TabsController = new TabsController()
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack();
  private lastValidIndex: number = 1

  aboutToAppear(): void {
    console.log('[MainPage] aboutToAppear called')
    console.log('[MainPage] pathStack created:', !!this.pathStack)
    
    TokenManager.setTokenExpiredCallback(() => {
      ToastUtil.getInstance().show('登录已过期，请重新登录')
      this.currentIndex = 4
      this.lastValidIndex = 4
      this.tabsController.changeIndex(4)
    })
  }

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
            GalleryPage()
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
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
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
    // 调整索引映射
    return icons[index > 2 ? index - 1 : index]
  }
}