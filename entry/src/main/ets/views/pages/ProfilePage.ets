import { ImageCard, ImageItem } from '../components/ImageCard'
import { UserInfo } from '../../services/api/UserApi'
import { LoginPage } from './LoginPage'
import { RegisterPage } from './RegisterPage'
import { ProfileViewModel } from '../../viewmodels/ProfileViewModel'
import { LoadingComponent } from '../components/LoadingComponent'
import { ApiResponse } from '../../services/api/HttpRequest'
import { LikePostData } from '../../services/api/PostApi'

export enum AuthPageType {
  LOGIN = 0,
  REGISTER = 1
}

interface PostDetailNavParam {
  post_id: string
  user_avatar?: string
  user_name?: string
}


@Component
export struct ProfilePage {
  @Consume('NavPathStack') pathStack: NavPathStack
  @State viewModel: ProfileViewModel = new ProfileViewModel()
  @State currentAuthPage: AuthPageType = AuthPageType.LOGIN
  @State showAuthView: boolean = false
  @State currentIndex: number = 0
  
  // 作品点赞状态
  @State workLikedItems: Set<string> = new Set()
  @State workLikeCounts: Map<string, number> = new Map()
  
  // 收藏点赞状态
  @State likeLikedItems: Set<string> = new Set()
  @State likeLikeCounts: Map<string, number> = new Map()
  
  // 标志位：是否已完成初始化检查
  private hasInitialized: boolean = false
  
  // 监听全局登录状态（通过 AppStorage 实现跨页面状态同步）
  @StorageLink('logoutTimestamp') @Watch('onLogoutTimestampChange') logoutTimestamp: number = 0
  @StorageLink('loginTimestamp') @Watch('onLoginTimestampChange') loginTimestamp: number = 0
  
  // 监听登录状态变化
  onLoginTimestampChange() {
    if (this.loginTimestamp > 0) {
      console.log('[ProfilePage] 检测到登录成功，重新加载用户数据')
      
      this.viewModel.checkUserLoginStatus().then(() => {
        if (this.viewModel.isUserLoggedIn) {
          this.viewModel.loadUserPosts(true)
          this.viewModel.loadUserFavorites(true).then(() => {
            this.initializeLikeStates()
          })
        }
      })
    }
  }
  
  // 监听退出登录状态变化
  onLogoutTimestampChange() {
    if (this.logoutTimestamp > 0) {
      console.log('[ProfilePage] 检测到退出登录，重置为未登录状态')
      
      // 清空页面状态
      this.workLikedItems = new Set()
      this.workLikeCounts = new Map()
      this.likeLikedItems = new Set()
      this.likeLikeCounts = new Map()
      this.showAuthView = false
      
      // 创建全新的 ViewModel 实例
      this.viewModel = new ProfileViewModel()
    }
  }

  aboutToAppear(): void {
    console.log('[ProfilePage] aboutToAppear - 初始化')
    
    // 只在第一次初始化时检查登录状态
    if (!this.hasInitialized) {
      this.hasInitialized = true
      this.viewModel.checkUserLoginStatus().then(() => {
        this.initializeLikeStates()
      }).catch(() => {
        console.error('[ProfilePage] 检查登录状态失败')
      })
    } else {
      this.initializeLikeStates()
    }
  }
  
  // aboutToDisappear 不再需要，AppStorage 会自动管理状态

  // 初始化点赞状态
  initializeLikeStates(): void {
    // 先清空所有旧状态
    this.workLikedItems.clear()
    this.workLikeCounts.clear()
    this.likeLikedItems.clear()
    this.likeLikeCounts.clear()
    
    // 初始化作品点赞状态
    this.viewModel.workItems.forEach(item => {
      this.workLikeCounts.set(item.id, item.likeCount)
      if (item.isLiked) {
        this.workLikedItems.add(item.id)
      }
    })
    
    // 初始化收藏点赞状态
    this.viewModel.likeItems.forEach(item => {
      this.likeLikeCounts.set(item.id, item.likeCount)
      if (item.isLiked) {
        this.likeLikedItems.add(item.id)
      }
    })
    
    // 触发UI更新
    this.workLikedItems = new Set(this.workLikedItems)
    this.workLikeCounts = new Map(this.workLikeCounts)
    this.likeLikedItems = new Set(this.likeLikedItems)
    this.likeLikeCounts = new Map(this.likeLikeCounts)
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
              .margin({right:5})
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
            // 切换到收藏标签时，重新初始化点赞状态
            if (index === 1) {
              console.log('[ProfilePage] 切换到收藏标签，重新初始化点赞状态')
              this.initializeLikeStates()
            }
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

  // 处理作品卡片点击
  handleWorkCardClick(id: string): void {
    const item = this.viewModel.workItems.find(item => item.id === id)
    const userAvatar = typeof item?.userAvatar === 'string' ? item.userAvatar : undefined
    const param: PostDetailNavParam = { 
      post_id: id,
      user_avatar: userAvatar,
      user_name: item?.userId
    }
    this.pathStack.pushPathByName('PostDetailPage', param, false)
  }

  // 处理收藏卡片点击
  handleLikeCardClick(id: string): void {
    const item = this.viewModel.likeItems.find(item => item.id === id)
    const userAvatar = typeof item?.userAvatar === 'string' ? item.userAvatar : undefined
    const param: PostDetailNavParam = {
      post_id: id,
      user_avatar: userAvatar,
      user_name: item?.userId
    }
    this.pathStack.pushPathByName('PostDetailPage', param, false)
  }

  // 处理作品点赞
  async handleWorkLikeClick(id: string): Promise<void> {
    const isCurrentlyLiked: boolean = this.workLikedItems.has(id)
    const result: ApiResponse<LikePostData> = await this.viewModel.handleWorkLikeClick(id)
    
    if (result.success && result.data) {
      if (result.data.has_liked) {
        this.workLikedItems.add(id)
      } else {
        this.workLikedItems.delete(id)
      }
      this.workLikeCounts.set(id, result.data.like_count)
      
      // 触发UI更新
      this.workLikedItems = new Set(this.workLikedItems)
      this.workLikeCounts = new Map(this.workLikeCounts)
    }
  }

  // 处理收藏点赞
  async handleLikeLikeClick(id: string): Promise<void> {
    const isCurrentlyLiked: boolean = this.likeLikedItems.has(id)
    const result: ApiResponse<LikePostData> = await this.viewModel.handleLikeLikeClick(id)
    
    if (result.success && result.data) {
      if (result.data.has_liked) {
        this.likeLikedItems.add(id)
      } else {
        this.likeLikedItems.delete(id)
      }
      this.likeLikeCounts.set(id, result.data.like_count)
      
      // 触发UI更新
      this.likeLikedItems = new Set(this.likeLikedItems)
      this.likeLikeCounts = new Map(this.likeLikeCounts)
    }
  }

  // 获取作品点赞状态
  isWorkItemLiked(id: string): boolean {
    return this.workLikedItems.has(id)
  }

  // 获取作品点赞数
  getWorkItemLikeCount(id: string): number {
    return this.workLikeCounts.get(id) || 0
  }

  // 获取收藏点赞状态
  isLikeItemLiked(id: string): boolean {
    return this.likeLikedItems.has(id)
  }

  // 获取收藏点赞数
  getLikeItemLikeCount(id: string): number {
    return this.likeLikeCounts.get(id) || 0
  }

  @Builder
  WorkContent() {
    if (this.viewModel.workLoading && this.viewModel.workItems.length === 0) {
      LoadingComponent()
    } else if (this.viewModel.workItems.length === 0 && !this.viewModel.workLoading) {
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
                likeCount: this.getWorkItemLikeCount(item.id),
                isLiked: this.isWorkItemLiked(item.id),
                imageHeight: item.imageHeight
              },
              onLikeClick: async (id: string) => await this.handleWorkLikeClick(id),
              onCardClick: (id: string) => this.handleWorkCardClick(id)
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
    if (this.viewModel.likeItems.length === 0) {
      LoadingComponent()
    } else {
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
                likeCount: this.getLikeItemLikeCount(item.id),
                isLiked: this.isLikeItemLiked(item.id),
                imageHeight: item.imageHeight
              },
              onLikeClick: async (id: string) => await this.handleLikeLikeClick(id),
              onCardClick: (id: string) => this.handleLikeCardClick(id)
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

}
