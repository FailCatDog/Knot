import { ImageCard, ImageItem } from '../components/ImageCard'
import { getPublicUserInfo, PublicUserInfo, getUserPosts, Post } from '../../services/api/UserApi'
import { PostDetailParam, likePost, unlikePost } from '../../services/api/PostApi'

interface PostImage {
  file_url: string
  thumbnail_url: string
  width: number
  height: number
}

@Builder
export function UserProfilePageBuilder() {
  UserProfilePage()
}

@Component
export struct UserProfilePage {
  @Consume('NavPathStack') pathStack: NavPathStack
  @State userInfo: PublicUserInfo | null = null
  @State isLoading: boolean = true
  @State workItems: ImageItem[] = []
  @State workPosts: Post[] = []
  @State workPage: number = 1
  @State workTotalCount: number = 0
  @State workLoading: boolean = false
  @State workHasMore: boolean = true
  @State likedItems: Set<string> = new Set()
  @State likeCounts: Map<string, number> = new Map()
  
  private userId: string = ''

  aboutToAppear(): void {
    // 从路由参数获取 user_id
    const param = this.pathStack.getParamByIndex(this.pathStack.size() - 1) as Record<string, Object>
    if (param && param['user_id']) {
      this.userId = param['user_id'] as string
      this.loadUserInfo()
    }
  }

  // 加载用户公开信息
  async loadUserInfo(): Promise<void> {
    this.isLoading = true
    
    try {
      console.log('[UserProfilePage] 开始加载用户信息, userId:', this.userId)
      const response = await getPublicUserInfo(this.userId)
      console.log('[UserProfilePage] 获取用户信息响应:', JSON.stringify(response))
      if (response.success && response.data) {
        this.userInfo = response.data
        // 加载用户作品
        await this.loadUserPosts(true)
      } else {
        console.error('[UserProfilePage] 获取用户信息失败:', response.message)
      }
    } catch (error) {
      console.error('[UserProfilePage] 加载用户信息异常:', error)
    } finally {
      this.isLoading = false
    }
  }

  // 加载用户作品
  async loadUserPosts(refresh: boolean = false): Promise<void> {
    if (this.workLoading || (!refresh && !this.workHasMore)) {
      return
    }

    this.workLoading = true

    try {
      const page: number = refresh ? 1 : this.workPage
      console.log('[UserProfilePage] 加载用户作品, userId:', this.userId, 'page:', page)
      const response = await getUserPosts({
        user_id: this.userId,
        page: page,
        pageSize: 20
      })
      console.log('[UserProfilePage] 用户作品响应:', JSON.stringify(response))

      if (response.success && response.data) {
        const posts: Post[] = response.data.posts
        const total: number = response.data.total
        
        // 初始化点赞状态
        posts.forEach(post => {
          if (post.has_liked && !this.likedItems.has(post.post_id)) {
            this.likedItems.add(post.post_id)
          }
          if (!this.likeCounts.has(post.post_id)) {
            this.likeCounts.set(post.post_id, post.like_count)
          }
        })
        
        if (refresh) {
          this.workPosts = posts
          this.workItems = posts.map(post => this.postToImageItem(post))
          this.workPage = 1
        } else {
          this.workPosts = [...this.workPosts, ...posts]
          this.workItems = [...this.workItems, ...posts.map(post => this.postToImageItem(post))]
        }
        
        this.workTotalCount = total
        this.workPage = response.data.page + 1
        this.workHasMore = this.workPosts.length < total
      }
    } catch (error) {
      console.error('[UserProfilePage] 加载用户作品失败:', error)
    } finally {
      this.workLoading = false
    }
  }

  // 将Post转换为ImageItem
  private postToImageItem(post: Post): ImageItem {
    const imageUrl: string = post.cover_image_url || 
      (post.images && post.images.length > 0 ? post.images[0].thumbnail_url : '')
    
    // 使用本地状态而非post的原始值
    const isLiked: boolean = this.likedItems.has(post.post_id)
    const likeCount: number = this.likeCounts.get(post.post_id) || post.like_count
    
    // 优先使用post中的作者信息，否则使用页面用户信息
    const userAvatar = post.author?.avatar_url || post.avatar_url || 
      this.userInfo?.avatar_url || $r('app.media.head')
    const userName = post.author?.username || post.username || 
      this.userInfo?.username || ''
    
    return {
      id: post.post_id,
      imageUrl: imageUrl,
      title: post.title,
      description: post.description,
      userAvatar: userAvatar,
      userId: userName,
      likeCount: likeCount,
      isLiked: isLiked,
      imageHeight: 200
    }
  }

  // 处理作品卡片点击
  handleCardClick(id: string): void {
    const item = this.workItems.find(item => item.id === id)
    const userAvatar = typeof item?.userAvatar === 'string' ? item.userAvatar : undefined
    const param: PostDetailParam = {
      post_id: id,
      user_avatar: userAvatar,
      user_name: item?.userId
    }
    this.pathStack.pushPathByName('PostDetailPage', param, false)
  }

  // 处理点赞
  async handleLikeClick(id: string): Promise<void> {
    const isCurrentlyLiked = this.likedItems.has(id)
    const response = isCurrentlyLiked ? await unlikePost(id) : await likePost(id)
    
    if (response.success && response.data) {
      // 更新本地状态
      if (response.data.has_liked) {
        this.likedItems = new Set(this.likedItems.add(id))
      } else {
        this.likedItems.delete(id)
        this.likedItems = new Set(this.likedItems)
      }
      this.likeCounts.set(id, response.data.like_count)
      this.likeCounts = new Map(this.likeCounts)
    }
  }

  getItemLikeCount(id: string): number {
    return this.likeCounts.get(id) || 0
  }

  isItemLiked(id: string): boolean {
    return this.likedItems.has(id)
  }

  getGenderText(gender: string): string {
    switch (gender) {
      case 'male':
        return '男'
      case 'female':
        return '女'
      default:
        return '未知'
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .margin({ bottom: 16 })
            
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else if (this.userInfo) {
          Scroll() {
            Column() {
              // 背景和头部
              Stack({ alignContent: Alignment.TopStart }) {
                // 背景图
                Image('https://design.gemcoder.com/staticResource/echoAiSystemImages/582f3c87050f39c69515349a5003c9f1.png')
                  .width('100%')
                  .height(160)
                  .objectFit(ImageFit.Cover)

                // 返回按钮
                Image($r('app.media.ic_back'))
                  .width(24)
                  .height(24)
                  .fillColor('#FFFFFF')
                  .onClick(() => {
                    this.pathStack.pop()
                  })
                  .position({ top: 16, left: 16 })
                  .width(24)
                  .height(24)
              }
              .width('100%')
              .height(160)
              .clip(true)

              // 用户信息卡片
              Column() {
                Row() {
                  Image(this.userInfo.avatar_url && this.userInfo.avatar_url.trim() !== '' ? this.userInfo.avatar_url : $r('app.media.head'))
                    .width(90)
                    .height(90)
                    .borderRadius(45)
                    .border({ width: 3, color: '#fff' })
                    .margin({ right: 14, top: -35 })
                    .alt($r('app.media.head'))

                  Column() {
                    Text(this.userInfo.username)
                      .fontSize(18)
                      .fontColor('#333')
                      .fontWeight(FontWeight.Bold)

                    Text(this.userInfo.bio && this.userInfo.bio.trim() !== '' ? this.userInfo.bio : '暂无个人简介')
                      .fontSize(14)
                      .fontColor('#999')
                      .margin({ top: 4 })

                    // 地址和性别信息
                    Row({ space: 16 }) {
                      if (this.userInfo.location && this.userInfo.location.trim() !== '') {
                        Row({ space: 6 }) {
                          Image($r('app.media.ic_profilePage_location'))
                            .width(18)
                            .height(18)
                            .fillColor('#666')
                          
                          Text(this.userInfo.location)
                            .fontSize(13)
                            .fontColor('#666')
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                        }
                        .alignItems(VerticalAlign.Center)
                      }

                      if (this.userInfo.gender && this.userInfo.gender.trim() !== '') {
                        Row({ space: 6 }) {
                          Image($r('app.media.ic_profilePage_stats'))
                            .width(18)
                            .height(18)
                            .fillColor('#666')
                          
                          Text(this.getGenderText(this.userInfo.gender))
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
                }
                .alignItems(VerticalAlign.Top)
                .width('100%')
                .padding({ top: 12, bottom: 12 })
              }
              .padding({ left: 16, right: 16, top: 0, bottom: 12 })
              .margin({ top: -60 })
              .backgroundColor('#fff')
              .width('100%')
              .borderRadius({ topLeft: 16, topRight: 16 })

              // 作品列表
              Column() {
                Row() {
                  Text('作品')
                    .fontSize(16)
                    .fontColor('#333')
                    .fontWeight(FontWeight.Bold)
                  
                  Blank()
                  
                  Text(`${this.workTotalCount}`)
                    .fontSize(14)
                    .fontColor('#999')
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 8 })

                this.WorkContent()
              }
              .width('100%')
              .layoutWeight(1)
              .backgroundColor('#fff')
            }
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
        } else {
          Column() {
            Text('用户不存在')
              .fontSize(16)
              .fontColor('#999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
    }
    .hideTitleBar(true)
  }

  @Builder
  WorkContent() {
    if (this.workItems.length === 0 && !this.workLoading) {
      Column() {
        Image($r('app.media.ic_discover'))
          .width(80)
          .height(80)
          .fillColor('#CCCCCC')
          .margin({ bottom: 16 })

        Text('还没有发布作品')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height(300)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      WaterFlow() {
        ForEach(this.workItems, (item: ImageItem) => {
          FlowItem() {
            ImageCard({
              item: {
                id: item.id,
                imageUrl: item.imageUrl,
                title: item.title,
                userAvatar: item.userAvatar,
                userId: item.userId,
                description: item.description,
                likeCount: this.getItemLikeCount(item.id),
                isLiked: this.isItemLiked(item.id),
                imageHeight: item.imageHeight
              },
              onLikeClick: (id: string) => this.handleLikeClick(id),
              onCardClick: (id: string) => this.handleCardClick(id)
            })
          }
          .width('100%')
          .constraintSize({
            maxWidth: '100%',
            minWidth: 0
          })
        })

        if (this.workHasMore || this.workLoading) {
          FlowItem() {
            Column() {
              if (this.workLoading) {
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
              }
            }
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (!this.workLoading && this.workHasMore) {
                this.loadUserPosts(false)
              }
            })
          }
          .width('100%')
        }
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(10)
      .padding({ left: 8, right: 8, top: 8, bottom: 16 })
      .width('100%')
      .layoutWeight(1)
      .onReachEnd(() => {
        if (this.workHasMore && !this.workLoading) {
          this.loadUserPosts(false)
        }
      })
    }
  }
}

