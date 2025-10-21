import router from '@ohos.router'
import { ImageCard, ImageItem } from '../components/ImageCard'
import { getFollowingList, FollowingUserInfo, unfollowUser } from '../../services/api/UserApi'
import { TokenManager } from '../../services/TokenManager'
import { getUserPosts, PostEntity, likePost, unlikePost } from '../../services/api/PostApi'
import { LoadingComponent } from '../components/LoadingComponent'
import { ToastUtil } from '../../common/utils/ToastUtil'

interface FollowingUser {
  userId: string;
  userName: string;
  userAvatar: string;
}

@Component
export struct FollowPage {
  @State likedItems: Set<string> = new Set()
  @State likeCounts: Map<string, number> = new Map()
  @State followingUsers: FollowingUser[] = []
  @State isLoadingFollowing: boolean = false
  @State showFollowingDialog: boolean = false
  @State selectedUserId: string | null = null
  @State userPosts: ImageItem[] = []
  @State isLoadingPosts: boolean = false
  @State postsOpacity: number = 1

  async aboutToAppear(): Promise<void> {
    await this.loadFollowingList()
  }

  async loadFollowingList(): Promise<void> {
    const tokenManager = TokenManager.getInstance()
    const currentUserId = await tokenManager.getUserId()
    
    if (!currentUserId) {
      return
    }

    this.isLoadingFollowing = true
    const response = await getFollowingList(currentUserId)
    
    if (response.success && response.data) {
      this.followingUsers = response.data.users.map((user: FollowingUserInfo): FollowingUser => {
        return {
          userId: user.user_id,
          userName: user.username,
          userAvatar: user.avatar_url || 'https://picsum.photos/60/60'
        }
      })

      if (this.followingUsers.length > 0) {
        this.selectedUserId = this.followingUsers[0].userId
        await this.loadUserPosts(this.followingUsers[0].userId)
      }
    }
    
    this.isLoadingFollowing = false
  }

  async loadUserPosts(userId: string): Promise<void> {
    this.isLoadingPosts = true
    animateTo({
      duration: 200,
      curve: Curve.EaseOut
    }, () => {
      this.postsOpacity = 0.3
    })

    const response = await getUserPosts(userId, 1, 20)
    
    if (response.success && response.data) {
      this.userPosts = response.data.posts.map((post: PostEntity): ImageItem => {
        const firstImage = post.images && post.images.length > 0 ? post.images[0] : null
        const isLiked = this.likedItems.has(post.post_id) ? this.isItemLiked(post.post_id) : post.has_liked
        const likeCount = this.likeCounts.has(post.post_id) ? this.getItemLikeCount(post.post_id) : post.like_count

        if (post.has_liked && !this.likedItems.has(post.post_id)) {
          this.likedItems.add(post.post_id)
        }
        if (!this.likeCounts.has(post.post_id)) {
          this.likeCounts.set(post.post_id, post.like_count)
        }

        return {
          id: post.post_id,
          imageUrl: firstImage?.file_url || '',
          title: post.title,
          description: post.description || '',
          userAvatar: post.author?.avatar_url || post.avatar_url || 'https://picsum.photos/40/40',
          userId: post.author?.username || post.username || `用户${post.user_id}`,
          likeCount: likeCount,
          isLiked: isLiked,
          imageHeight: firstImage ? Math.min(Math.max(firstImage.height / firstImage.width * 280, 150), 420) : 280
        }
      })
    }
    
    this.isLoadingPosts = false
    animateTo({
      duration: 300,
      curve: Curve.EaseIn
    }, () => {
      this.postsOpacity = 1
    })
  }

  handleUserClick(userId: string): void {
    if (this.selectedUserId === userId) {
      return
    }
    this.selectedUserId = userId
    this.showFollowingDialog = false
    this.loadUserPosts(userId)
  }

  async handleUnfollow(userId: string): Promise<void> {
    const response = await unfollowUser(userId)
    
    if (response.success) {
      ToastUtil.getInstance().show('已取消关注')
      
      const unfollowedIndex = this.followingUsers.findIndex(user => user.userId === userId)
      this.followingUsers = this.followingUsers.filter(user => user.userId !== userId)
      
      if (this.selectedUserId === userId) {
        if (this.followingUsers.length > 0) {
          const newIndex = unfollowedIndex >= this.followingUsers.length ? this.followingUsers.length - 1 : unfollowedIndex
          this.selectedUserId = this.followingUsers[newIndex].userId
          await this.loadUserPosts(this.followingUsers[newIndex].userId)
        } else {
          this.selectedUserId = null
          this.userPosts = []
        }
      }
    } else {
      ToastUtil.getInstance().show('取消关注失败')
    }
  }

  isItemLiked(id: string): boolean {
    return this.likedItems.has(id)
  }

  getItemLikeCount(id: string): number {
    return this.likeCounts.get(id) || 0
  }

  build() {
    Stack() {
      Column() {
        this.buildHeader()
        
        if (this.isLoadingFollowing) {
          Column() {
            LoadingComponent()
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.followingUsers.length === 0) {
          this.buildEmptyState()
        } else {
          this.buildFollowingUsers()
          this.buildContent()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      if (this.showFollowingDialog) {
        this.buildFollowingDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('关注')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Blank()

      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildFollowingDialog() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showFollowingDialog = false
        })

      Column() {
        Row() {
          Text('我的关注')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
            .rotate({ angle: 180 })
            .onClick(() => {
              this.showFollowingDialog = false
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })

        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.followingUsers, (user: FollowingUser) => {
              Row({ space: 12 }) {
                Stack() {
                  Image(user.userAvatar)
                    .width(50)
                    .height(50)
                    .borderRadius(25)

                  if (this.selectedUserId === user.userId) {
                    Column()
                      .width(50)
                      .height(50)
                      .borderRadius(25)
                      .border({ width: 2, color: '#ffdd0223' })
                  }
                }

                Column({ space: 4 }) {
                  Text(user.userName)
                    .fontSize(16)
                    .fontColor(this.selectedUserId === user.userId ? '#ffdd0223' : '#333333')
                    .fontWeight(this.selectedUserId === user.userId ? FontWeight.Bold : FontWeight.Medium)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Button('取消关注')
                  .fontSize(14)
                  .fontColor('#666666')
                  .backgroundColor('#F5F5F5')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(4)
                  .onClick(() => {
                    this.handleUnfollow(user.userId)
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .onClick(() => {
                this.handleUserClick(user.userId)
              })
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 8, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('70%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 1000 })).animation({ duration: 300, curve: Curve.EaseOut }))
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildEmptyState() {
    Column({ space: 16 }) {
      Image($r('app.media.ic_follow'))
        .width(120)
        .height(120)
        .fillColor('#D0D0D0')
        .margin({ top: 100 })

      Text('还没有关注任何人')
        .fontSize(16)
        .fontColor('#666666')

      Text('去发现页寻找感兴趣的内容吧')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildFollowingUsers() {
    Column() {
      Row() {
        Text('我的关注')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        Row() {
          Text('更多')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ right: 4 })
          
          Image($r('app.media.ic_more'))
            .width(20)
            .height(20)
            .fillColor('#666666')
        }
        .onClick(() => {
          this.showFollowingDialog = true
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Row({ space: 12 }) {
        ForEach(this.followingUsers.slice(0, 6), (user: FollowingUser) => {
          Column({ space: 6 }) {
            Stack() {
              Image(user.userAvatar)
                .width(50)
                .height(50)
                .borderRadius(25)

              if (this.selectedUserId === user.userId) {
                Column()
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  .border({ width: 2, color: '#ffdd0223' })
              }
            }

            Text(user.userName)
              .fontSize(12)
              .fontColor(this.selectedUserId === user.userId ? '#ffdd0223' : '#666666')
              .fontWeight(this.selectedUserId === user.userId ? FontWeight.Bold : FontWeight.Normal)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width(60)
          .onClick(() => {
            this.handleUserClick(user.userId)
          })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .height(90)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 8, bottom: 12 })
  }

  @Builder
  buildContent() {
    if (this.isLoadingPosts) {
      Column() {
        LoadingComponent()
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        WaterFlow() {
          ForEach(this.userPosts, (item: ImageItem, index: number) => {
            FlowItem() {
              Column() {
                ImageCard({
                  item: {
                    id: item.id,
                    imageUrl: item.imageUrl,
                    title: item.title,
                    description: item.description || '分享生活中的美好瞬间，记录每一个值得纪念的时刻。',
                    userAvatar: item.userAvatar,
                    userId: item.userId,
                    likeCount: this.getItemLikeCount(item.id),
                    isLiked: this.isItemLiked(item.id),
                    imageHeight: item.imageHeight
                  },
                  onLikeClick: (id: string) => {
                    this.handleLikeClick(id)
                  },
                  onCardClick: (id: string) => {
                    this.handleCardClick(id)
                  }
                })
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 8, color: '#10000000', offsetY: 2 })
            }
          })
        }
        .columnsTemplate('1fr')
        .rowsGap(16)
        .padding({ left: 16, right: 16, bottom: 16 })
        .width('100%')
        .opacity(this.postsOpacity)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
    }
  }

  async handleLikeClick(id: string): Promise<void> {
    const isCurrentlyLiked = this.isItemLiked(id)
    const response = isCurrentlyLiked ? await unlikePost(id) : await likePost(id)

    if (response.success && response.data) {
      if (response.data.has_liked) {
        this.likedItems.add(id)
      } else {
        this.likedItems.delete(id)
      }
      this.likeCounts.set(id, response.data.like_count)
    }
  }

  handleCardClick(id: string): void {
    router.pushUrl({
      url: 'pages/PostDetailPage',
      params: {
        postId: id
      }
    }).catch((error: Error) => {
      console.error('Navigation failed:', error.message)
    })
  }
}


