import { ImageCard, ImageItem } from '../components/ImageCard'
import { UserInfo } from '../../services/api/UserApi'
import { common } from '@kit.AbilityKit'
import { LoginPage } from './LoginPage'
import { RegisterPage } from './RegisterPage'
import { ProfileViewModel } from '../../viewmodels/ProfileViewModel'

export enum AuthPageType {
  LOGIN = 0,
  REGISTER = 1
}

interface UserLoginStatusChangedData {
  isLoggedIn: boolean;
  userInfo: UserInfo;
}

interface UserLogoutStatusChangedData {
  isLoggedIn: boolean;
}

@Component
export struct ProfilePage {
  @Consume('NavPathStack') pathStack: NavPathStack
  viewModel: ProfileViewModel = new ProfileViewModel()
  @State currentAuthPage: AuthPageType = AuthPageType.LOGIN
  @State showAuthView: boolean = false
  @State currentIndex: number = 0

  aboutToAppear(): void {
    // 使用ViewModel检查登录状态
    this.viewModel.checkUserLoginStatus()

    try {
      let context = getContext(this) as common.UIAbilityContext
      let eventHub = context.eventHub
      
      eventHub.on('userLoginStatusChanged', (data: UserLoginStatusChangedData) => {
        if (data.userInfo) {
          this.viewModel.updateUserInfo(data.userInfo)
        }
        this.showAuthView = false
      })
      
      eventHub.on('userLogoutStatusChanged', (data: UserLogoutStatusChangedData) => {
        this.viewModel.logout()
        this.showAuthView = false
      })
    } catch (error) {
      console.error('[ProfilePage] 监听事件失败:', error)
    }
  }

  aboutToDisappear(): void {
    try {
      let context = getContext(this) as common.UIAbilityContext
      let eventHub = context.eventHub
      eventHub.off('userLoginStatusChanged')
      eventHub.off('userLogoutStatusChanged')
    } catch (error) {
      console.error('[ProfilePage] 取消监听事件失败:', error)
    }
  }

  @Builder
  buildWelcomeView() {
    Column() {
      Column() {
        Image($r('app.media.ic_profile'))
          .width(120)
          .height(120)
          .margin({ top: 120, bottom: 40 })
          .fillColor('#ffdd0223')

        Text('发现精彩，分享生活')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ bottom: 12 })

        Text('登录后查看个人主页和专属内容')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 60 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 16 }) {
        Button('登录 / 注册')
          .width('80%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#ffdd0223')
          .borderRadius(25)
          .onClick(() => {
            this.showAuthView = true
            this.currentAuthPage = AuthPageType.LOGIN
          })

        Row({ space: 8 }) {
          Text('继续使用即代表同意')
            .fontSize(12)
            .fontColor('#999999')
          Text('用户协议')
            .fontSize(12)
            .fontColor('#ffdd0223')
          Text('和')
            .fontSize(12)
            .fontColor('#999999')
          Text('隐私政策')
            .fontSize(12)
            .fontColor('#ffdd0223')
        }
        .margin({ top: 20 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }


  build() {
    if (!this.viewModel.isUserLoggedIn && !this.viewModel.isLoading) {
      if (this.showAuthView) {
        Column() {
          Row() {
            Image($r('app.media.ic_back'))
              .width(24)
              .height(24)
              .margin({ left: 16 })
              .onClick(() => {
                this.showAuthView = false
              })

            Text(this.currentAuthPage === AuthPageType.LOGIN ? '登录' : '注册')
              .fontSize(18)
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

          if (this.currentAuthPage === AuthPageType.LOGIN) {
            LoginPage({ currentPage: this.currentAuthPage })
          } else {
            RegisterPage({ currentPage: this.currentAuthPage })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
      } else {
        this.buildWelcomeView()
      }
    } else {
      Column() {
        Stack() {
          Image('https://design.gemcoder.com/staticResource/echoAiSystemImages/582f3c87050f39c69515349a5003c9f1.png')
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .opacity(1)
            .backgroundColor('#000')

          Row() {
            Row() {
              Button() {
                Image($r('app.media.ic_profilePage_setting'))
                  .width(24)
                  .height(24)
                  .margin({left:16})
                  .fillColor('#fff');
              }
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                console.log('[ProfilePage] 点击设置图标')
                console.log('[ProfilePage] pathStack exists:', !!this.pathStack)
                this.pathStack.pushPathByName('SettingPage', null, false)
                console.log('[ProfilePage] pushPathByName executed')
              });
            }
            .justifyContent(FlexAlign.End)
            .width('100%')
            .padding({ left: 16, right: 16 });
          }
          .position({ top: 1, left: 16, right: 16 })
          .width('100%')
          .height(48);
        }
        .width('100%')
        .height(160)
        .clip(true);

        Column() {
          if (this.viewModel.isLoading) {
            Column() {
              Text('加载中...')
                .fontSize(16)
                .fontColor('#999')
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
          } else {
            this.renderLoggedInView()
          }
        }
        .padding({ left: 16, right: 16, top: 0, bottom: 12 })
        .margin({ top: -60 })
        .backgroundColor('#fff')
        .width('100%')
        .borderRadius({ topLeft: 16, topRight: 16 });

        if (this.viewModel.isUserLoggedIn) {
          Tabs({ index: this.currentIndex, controller: new TabsController() }) {
            TabContent() {
              this.WorkContent()
            }
            .tabBar(this.TabBuilder('作品', 0))

            TabContent() {
              this.LikeContent()
            }
            .tabBar(this.TabBuilder('收藏', 1))
          }
          .barPosition(BarPosition.Start)
          .onChange((index: number) => {
            this.currentIndex = index;
          })
          .width('100%')
          .padding({ left: 0, right: 0, top: -15, bottom: 0 })
          .margin({ top: 0 })
          .backgroundColor('#fff')
          .layoutWeight(1);
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9');
    }
  }



  @Builder
  renderLoggedInView() {
    Row() {
      Image(this.viewModel.userInfo.avatar_url && this.viewModel.userInfo.avatar_url.trim() !== '' ? this.viewModel.userInfo.avatar_url : $r('app.media.head'))
        .width(90)
        .height(90)
        .borderRadius(45)
        .border({ width: 3, color: '#fff' })
        .margin({ right: 14, top: -35 })
        .alt($r('app.media.head'))

      Column() {
        Text(this.viewModel.userInfo.username)
          .fontSize(18)
          .fontColor('#333')
          .fontWeight(FontWeight.Bold)

        Text(this.viewModel.userInfo.bio && this.viewModel.userInfo.bio.trim() !== '' ? this.viewModel.userInfo.bio : '暂无个人简介')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 4 })

        // 地址和性别信息
        Row({ space: 16 }) {
          // 地址信息
          if (this.viewModel.userInfo.location && this.viewModel.userInfo.location.trim() !== '') {
            Row({ space: 6 }) {
              Image($r('app.media.ic_profilePage_location'))
                .width(18)
                .height(18)
                .fillColor('#666')
              
              Text(this.viewModel.userInfo.location)
                .fontSize(13)
                .fontColor('#666')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(VerticalAlign.Center)
          }

          // 性别信息
          if (this.viewModel.userInfo.gender && this.viewModel.userInfo.gender.trim() !== '') {
            Row({ space: 6 }) {
              Image($r('app.media.ic_profilePage_stats'))
                .width(18)
                .height(18)
                .fillColor('#666')
              
              Text(this.viewModel.getGenderText(this.viewModel.userInfo.gender))
                .fontSize(13)
                .fontColor('#666')
            }
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin({ top: 8 })
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ top: 0 })
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  @Builder TabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontColor(this.currentIndex === targetIndex ? '#ff0000' : '#6b7280')

      if (this.currentIndex === targetIndex) {
        Divider()
          .width(120)
          .height(8)
          .color('#ff0000')
          .margin({ top: 4 })
      }
    }

    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  WorkContent() {
    if (this.viewModel.workItems.length === 0 && !this.viewModel.workLoading) {
      // 空状态
      Column() {
        Image($r('app.media.ic_discover'))
          .width(80)
          .height(80)
          .fillColor('#CCCCCC')
          .margin({ bottom: 16 })

        Text('还没有发布作品')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 8 })

        Text('快去分享你的精彩瞬间吧')
          .fontSize(14)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      WaterFlow() {
        ForEach(this.viewModel.workItems, (item: ImageItem, index: number) => {
          FlowItem() {
            ImageCard({
              item: {
                id: item.id,
                imageUrl: item.imageUrl,
                title: item.title,
                userAvatar: item.userAvatar,
                userId: item.userId,
                description: item.description,
                likeCount: this.viewModel.getWorkItemLikeCount(item.id),
                isLiked: this.viewModel.isWorkItemLiked(item.id),
                imageHeight: item.imageHeight
              },
              onLikeClick: (id: string) => this.viewModel.handleWorkLikeClick(id),
            })
          }
          .width('100%')
          .constraintSize({
            maxWidth: '100%',
            minWidth: 0
          })
        })

        // 加载更多或加载中提示
        if (this.viewModel.workHasMore || this.viewModel.workLoading) {
          FlowItem() {
            Column() {
              if (this.viewModel.workLoading) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .margin({ bottom: 8 })
                Text('加载中...')
                  .fontSize(12)
                  .fontColor('#999999')
              } else {
                Text('点击加载更多')
                  .fontSize(12)
                  .fontColor('#666666')
                  .padding(8)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(4)
                  .onClick(() => {
                    this.viewModel.loadUserPosts(false)
                  })
              }
            }
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .height(60)
        }
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(10)
      .padding({ left: 8, right: 8, top: 8, bottom: 16 })
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .onReachEnd(() => {
        // 滚动到底部时自动加载更多
        if (this.viewModel.workHasMore && !this.viewModel.workLoading) {
          this.viewModel.loadUserPosts(false)
        }
      })
    }
  }

  @Builder
  LikeContent() {
    WaterFlow() {
      ForEach(this.viewModel.likeItems, (item: ImageItem, index: number) => {
        FlowItem() {
          ImageCard({
            item: {
              id: item.id,
              imageUrl: item.imageUrl,
              title: item.title,
              userAvatar: item.userAvatar,
              userId: item.userId,
              description: item.description,
              likeCount: this.viewModel.getLikeItemLikeCount(item.id),
              isLiked: this.viewModel.isLikeItemLiked(item.id),
              imageHeight: item.imageHeight
            },
            onLikeClick: (id: string) => this.viewModel.handleLikeLikeClick(id),
          })
        }
        .width('100%')
        .constraintSize({
          maxWidth: '100%',
          minWidth: 0
        })
      })
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(8)
    .rowsGap(10)
    .padding({ left: 8, right: 8, top: 8, bottom: 16 })
    .width('100%')
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

}
