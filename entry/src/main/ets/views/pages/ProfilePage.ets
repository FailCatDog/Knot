import { ImageCard, ImageItem } from '../components/ImageCard'
import { UserInfo } from '../../services/api/UserApi'
import { LoginPage } from './LoginPage'
import { RegisterPage } from './RegisterPage'
import { ProfileViewModel } from '../../viewmodels/ProfileViewModel'
import { LoadingComponent } from '../components/LoadingComponent'
import { ApiResponse } from '../../services/api/HttpRequest'
import { LikePostData } from '../../services/api/PostApi'
import { ShareMessageDialog, ShareMessageItem } from '../components/ShareMessageDialog'
import { ShareRecord, getReceivedShares } from '../../services/api/ShareApi'
import { ReadStatusManager } from '../../services/ReadStatusManager'
import { ApiConstants } from '../../services/api/ApiConstants'

export enum AuthPageType {
  LOGIN = 0,
  REGISTER = 1
}

interface PostDetailNavParam {
  post_id: string
  user_avatar?: string
  user_name?: string
}

interface MockFriend {
  name: string
  avatar: string
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
  @State isWorkRefreshing: boolean = false
  
  @State likeLikedItems: Set<string> = new Set()
  @State likeLikeCounts: Map<string, number> = new Map()
  @State isLikeRefreshing: boolean = false
  
  // 分享消息相关
  @State showShareDialog: boolean = false
  @State shareMessages: ShareMessageItem[] = []
  @State unreadCount: number = 0 // 未读消息数量
  @State isLoadingShares: boolean = false
  
  // 标志位：是否已完成初始化检查
  private hasInitialized: boolean = false
  
  // 监听全局登录状态（通过 AppStorage 实现跨页面状态同步）
  @StorageLink('logoutTimestamp') @Watch('onLogoutTimestampChange') logoutTimestamp: number = 0
  @StorageLink('loginTimestamp') @Watch('onLoginTimestampChange') loginTimestamp: number = 0
  @StorageLink('shouldShowShareDialog') @Watch('onShouldShowShareDialogChange') shouldShowShareDialog: number = 0
  
  // 监听分享弹窗状态变化（从详情页返回）
  onShouldShowShareDialogChange() {
    if (this.shouldShowShareDialog > 0) {
      console.log('[ProfilePage] 检测到需要显示分享弹窗，时间戳:', this.shouldShowShareDialog)
      // 延迟显示弹窗，确保页面转换完成
      setTimeout(() => {
        this.showShareDialog = true
        console.log('[ProfilePage] 弹窗已显示')
      }, 100)
      // 重置标记
      AppStorage.set<number>('shouldShowShareDialog', 0)
    }
  }
  

  // 监听登录状态变化，重新加载用户数据
  onLoginTimestampChange() {
    if (this.loginTimestamp > 0) {
      console.log('[ProfilePage] 检测到登录成功，重新加载用户数据')
      
      // 清空用户信息缓存，确保显示最新的用户信息
      this.viewModel.clearUserInfoCache()
      
      this.viewModel.checkUserLoginStatus().then(async () => {
        if (this.viewModel.isUserLoggedIn) {
          this.viewModel.loadUserPosts(true)
          this.viewModel.loadUserFavorites(true).then(async () => {
            this.initializeLikeStates()
            // 收藏数据加载完成后初始化分享消息
            await this.initializeShareMessages()
          })
        }
      })
    }
  }

  // 监听退出登录状态变化，重置为未登录状态
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

  // 页面初始化，检查登录状态并加载数据
  aboutToAppear(): void {
    console.log('[ProfilePage] aboutToAppear - 初始化')
    
    // 只在第一次初始化时检查登录状态
    if (!this.hasInitialized) {
      this.hasInitialized = true
      this.viewModel.checkUserLoginStatus().then(async () => {
        this.initializeLikeStates()
        await this.initializeShareMessages()
      }).catch(() => {
        console.error('[ProfilePage] 检查登录状态失败')
      })
    } else {
      this.initializeLikeStates()
    }
  }

  // 初始化分享消息，从API获取真实数据
  async initializeShareMessages(): Promise<void> {
    console.log('[ProfilePage] 开始初始化分享消息')
    
    try {
      const response = await getReceivedShares({
        page: 1,
        page_size: 20
      })
      
      if (response.success && response.data) {
        
        // 获取已读状态
        const readPosts = await this.getReadPosts()
        
        // 转换API数据为ShareMessageItem格式
        this.shareMessages = response.data.shares.map((record: ShareRecord): ShareMessageItem => ({
          id: record.share_id,
          friendAvatar: record.sender?.avatar_url ? `${ApiConstants.BASE_URL}${record.sender.avatar_url}` : '', // 分享人头像
          friendName: record.sender?.username || '未知用户', // 分享人名字
          postId: record.post.post_id,
          postCover: record.post.cover_image ? `${ApiConstants.BASE_URL}${record.post.cover_image}` : '',
          postTitle: record.post.title,
          shareTime: record.create_time * 1000, // 转换为毫秒
          authorAvatar: '', // 帖主头像需要从帖子详情获取，这里先留空
          authorName: '', // 帖主名字需要从帖子详情获取，这里先留空
          isRead: readPosts.includes(record.post.post_id), // 使用本地存储的已读状态
          shareDescription: record.share_message
        }))
        
        // 计算未读数量
        this.unreadCount = this.shareMessages.filter(msg => !msg.isRead).length
        console.log('[ProfilePage] 分享消息初始化完成，消息数量:', this.shareMessages.length, '未读数量:', this.unreadCount)
      } else {
        console.log('[ProfilePage] 获取分享消息失败:', response.message)
        this.shareMessages = []
        this.unreadCount = 0
      }
    } catch (error) {
      console.error('[ProfilePage] 初始化分享消息异常:', error)
      this.shareMessages = []
      this.unreadCount = 0
    }
  }
  
  // 更新未读消息数量
  updateUnreadCount(): void {
    this.unreadCount = this.shareMessages.filter(msg => !msg.isRead).length
    console.log('[ProfilePage] 未读消息数量:', this.unreadCount)
  }
  
  
  // aboutToDisappear 不再需要，AppStorage 会自动管理状态
  // 初始化点赞状态，从ViewModel获取数据
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
  // 构建欢迎页面视图
  buildWelcomeView() {
    Column() {
      Column() {
        Image($r("app.media.ic_logo"))
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


  // 构建主页面视图
  build() {
    Stack() {
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
            Row({ space: 12 }) {
              // 分享消息图标
              Button() {
                Stack() {
                  Image($r('app.media.ic_send'))
                    .width(24)
                    .height(24)
                    .fillColor('#fff')
                  
                  // 未读消息小红点
                  if (this.unreadCount > 0) {
                    Text(this.unreadCount.toString())
                      .fontSize(10)
                      .fontColor('#fff')
                      .backgroundColor('#FF0000')
                      .borderRadius(8)
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .position({ x: 14, y: -4 })
                  }
                }
              }
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                console.log('[ProfilePage] 点击分享消息图标')
                this.loadShareMessages()
              })
              
              // 设置图标
              Button() {
                Image($r('app.media.ic_profilePage_setting'))
                  .width(24)
                  .height(24)
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
            .padding({ left: 16, right: 24 });
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
      
      // 分享消息弹窗（放在最外层以覆盖整个屏幕包括导航栏）
      if (this.showShareDialog) {
        ShareMessageDialog({
          showDialog: $showShareDialog,
          messageItems: this.shareMessages,
          onPostClick: async (postId: string) => {
            console.log('[ProfilePage] 点击分享的帖子:', postId)
            
            // 标记消息为已读
            await this.markMessageAsRead(postId)
            
            // 更新分享消息项中的帖主信息（PostDetailPage会自己获取）
            const message = this.shareMessages.find(msg => msg.postId === postId)
            if (message) {
              // 清空帖主信息，让PostDetailPage从API获取正确的信息
              message.authorAvatar = ''
              message.authorName = ''
            }
            
            // 直接传递帖子ID，让PostDetailPage自己获取帖主信息
            const param: PostDetailNavParam = {
              post_id: postId
              // 不传递user_avatar和user_name，让PostDetailPage从API获取正确的帖主信息
            }
            // 设置全局标记，返回时恢复弹窗
            const timestamp = Date.now()
            console.log('[ProfilePage] 设置全局标记 shouldShowShareDialog:', timestamp)
            AppStorage.setOrCreate<number>('shouldShowShareDialog', timestamp)
            this.showShareDialog = false
            console.log('[ProfilePage] 关闭弹窗，准备跳转到详情页')
            // 跳转到帖子详情页
            this.pathStack.pushPathByName('PostDetailPage', param, false)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 注意：由于 ProfilePage 是在 TabContent 中，无法直接拦截返回键
  // 用户可以通过以下方式关闭弹窗：
  // 1. 点击弹窗外的背景区域
  // 2. 点击弹窗右上角的关闭按钮



  @Builder
  // 渲染已登录用户的视图
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


  // 处理作品卡片点击事件，跳转到帖子详情页
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

  // 处理收藏卡片点击事件，跳转到帖子详情页
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

  // 处理作品点赞/取消点赞操作
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

  // 处理收藏点赞/取消点赞操作
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

  // 检查作品是否已点赞
  isWorkItemLiked(id: string): boolean {
    return this.workLikedItems.has(id)
  }


  // 获取作品点赞数量
  getWorkItemLikeCount(id: string): number {
    return this.workLikeCounts.get(id) || 0
  }

  // 检查收藏是否已点赞
  isLikeItemLiked(id: string): boolean {
    return this.likeLikedItems.has(id)
  }


  // 获取收藏点赞数量
  getLikeItemLikeCount(id: string): number {
    return this.likeLikeCounts.get(id) || 0
  }

  // 处理作品列表下拉刷新
  async handleWorkRefresh(): Promise<void> {
    this.isWorkRefreshing = true
    await this.viewModel.loadUserPosts(true)
    this.initializeLikeStates()
    this.isWorkRefreshing = false
  }

  // 处理收藏列表下拉刷新
  async handleLikeRefresh(): Promise<void> {
    this.isLikeRefreshing = true
    await this.viewModel.loadUserFavorites(true)
    this.initializeLikeStates()
    this.isLikeRefreshing = false
  }

  @Builder
  // 构建作品内容区域
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
      Refresh({ refreshing: $$this.isWorkRefreshing }) {
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
          if (this.viewModel.workHasMore && !this.viewModel.workLoading) {
            this.viewModel.loadUserPosts(false)
          }
        })
      }
      .onRefreshing(() => {
        this.handleWorkRefresh()
      })
    }
  }

  @Builder
  // 构建收藏内容区域
  LikeContent() {
    if (this.viewModel.likeLoading && this.viewModel.likeItems.length === 0) {
      LoadingComponent()
    } else if (this.viewModel.likeItems.length === 0 && !this.viewModel.likeLoading) {
      Column() {
        Image($r('app.media.ic_discover'))
          .width(80)
          .height(80)
          .fillColor('#CCCCCC')
          .margin({ bottom: 16 })

        Text('还没有收藏作品')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 8 })

        Text('快去收藏喜欢的内容吧')
          .fontSize(14)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      Refresh({ refreshing: $$this.isLikeRefreshing }) {
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
      .onRefreshing(() => {
        this.handleLikeRefresh()
      })
    }
  }


  // 加载分享消息列表
  async loadShareMessages() {
    if (this.isLoadingShares) return
    
    this.isLoadingShares = true
    
    try {
      const response = await getReceivedShares({
        page: 1,
        page_size: 20
      })
      
      if (response.success && response.data) {
        
        // 获取已读状态
        const readPosts = await this.getReadPosts()
        
        // 转换API数据为ShareMessageItem格式
        this.shareMessages = response.data.shares.map((record: ShareRecord): ShareMessageItem => {
          
          return {
            id: record.share_id,
            friendAvatar: record.sender?.avatar_url || '', // 分享人头像（已经是完整URL）
            friendName: record.sender?.username || '未知用户', // 分享人名字
            postId: record.post.post_id,
            postCover: record.post.cover_image ? `http://43.142.157.145:8080${record.post.cover_image}` : '',
            postTitle: record.post.title,
            shareTime: record.create_time * 1000, // 转换为毫秒
            authorAvatar: '', // 帖主头像需要从帖子详情获取，这里先留空
            authorName: '', // 帖主名字需要从帖子详情获取，这里先留空
            isRead: readPosts.includes(record.post.post_id), // 使用本地存储的已读状态
            shareDescription: record.share_message
          }
        })
        
        // 计算未读数量
        this.unreadCount = this.shareMessages.filter(msg => !msg.isRead).length
        
        // 显示弹窗
        this.showShareDialog = true
      } else {
        console.error('[ProfilePage] 加载分享消息失败:', response.message)
        // 显示空状态
        this.shareMessages = []
        this.unreadCount = 0
        this.showShareDialog = true
      }
    } catch (error) {
      console.error('[ProfilePage] 加载分享消息异常:', error)
      // 显示空状态
      this.shareMessages = []
      this.unreadCount = 0
      this.showShareDialog = true
    } finally {
      this.isLoadingShares = false
    }
  }

  // 标记消息为已读
  async markMessageAsRead(postId: string) {
    const message = this.shareMessages.find(msg => msg.postId === postId)
    if (message) {
      message.isRead = true
      this.unreadCount = this.shareMessages.filter(msg => !msg.isRead).length
      
      // 保存已读状态到本地存储
      await this.saveReadStatus(postId)
    }
  }

  // 保存已读状态到本地存储
  async saveReadStatus(postId: string) {
    try {
      await ReadStatusManager.getInstance().saveReadPost(postId)
    } catch (error) {
      console.error('[ProfilePage] 保存已读状态失败:', error)
    }
  }

  // 获取已读帖子列表
  async getReadPosts(): Promise<string[]> {
    try {
      return await ReadStatusManager.getInstance().getReadPosts()
    } catch (error) {
      console.error('[ProfilePage] 获取已读状态失败:', error)
      return []
    }
  }

  // 检查帖子是否已读
  async isPostRead(postId: string): Promise<boolean> {
    try {
      return await ReadStatusManager.getInstance().isPostRead(postId)
    } catch (error) {
      console.error('[ProfilePage] 检查已读状态失败:', error)
      return false
    }
  }


}
