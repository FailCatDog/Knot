import { FollowPage } from '../views/pages/FollowPage'
import { DiscoverPage } from '../views/pages/DiscoverPage'
import { MessagePage } from '../views/pages/MessagePage'
import { ProfilePage } from '../views/pages/ProfilePage'

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 1

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        FollowPage()
      }
      .tabBar(this.TabBuilder('关注', 0))

      TabContent() {
        DiscoverPage()
      }
      .tabBar(this.TabBuilder('发现', 1))

      TabContent() {
        MessagePage()
      }
      .tabBar(this.TabBuilder('摄像馆', 2))

      TabContent() {
        ProfilePage()
      }
      .tabBar(this.TabBuilder('我的', 3))
    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .barHeight(56)
    .barBackgroundColor('#F5F5F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder TabBuilder(title: string, targetIndex: number) {
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

  getTabIcon(index: number): Resource {
    const icons = [
      $r('app.media.ic_follow'),
      $r('app.media.ic_discover'),
      $r('app.media.ic_technology'),
      $r('app.media.ic_profile')
    ]
    return icons[index]
  }
}
