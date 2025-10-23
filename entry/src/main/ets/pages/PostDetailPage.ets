import { PostDetailEntity } from '../models/entities/PostDetailEntity'
import { ShareDrawer } from '../views/components/ShareDrawer'
import { favoritePost, unfavoritePost, getPostDetail, getFavoriteStatus, likePost, unlikePost, getLikeStatus, sharePost } from '../services/api/PostApi'
import { ToastUtil } from '../common/utils/ToastUtil'
import { PostStateManager } from '../common/utils/PostStateManager'
import { LoadingComponent } from '../views/components/LoadingComponent'
import { followUser, getCurrentUserInfo, getFollowStatus, getFollowingList, type FollowingUserInfo } from '../services/api/UserApi'
import { TokenManager } from '../services/TokenManager'
import { CommentSection } from '../views/components/CommentSection'
import { createComment, getComments, type CommentEntity } from '../services/api/CommentApi'
import { PostShareCardPreview } from '../views/components/PostShareCardPreview'

interface UserProfileParam {
  user_id: string
}

@Builder
export function PostDetailPageBuilder() {
  PostDetailPage()
}

@Component
struct PostDetailPage {
  @State postDetail: PostDetailEntity | null = null
  @State showShareDrawer: boolean = false
  @State showImagePreview: boolean = false
  @State currentImageIndex: number = 0
  @State isLoading: boolean = true
  @State isFollowing: boolean = false
  @State isOwnPost: boolean = false
  @State currentUserId: string = ''
  @State commentText: string = ''
  @State commentCount: number = 0
  @State refreshTimestamp: number = 0
  @State initialComments: CommentEntity[] = []
  @State showShareCardPreview: boolean = false
  @State showFriendSelector: boolean = false
  @State followingList: FollowingUserInfo[] = []
  @State selectedFriend: FollowingUserInfo | null = null
  @State showShareConfirm: boolean = false
  @Consume('NavPathStack') navPathStack: NavPathStack
  pathInfos: NavPathStack = new NavPathStack()
  private postId: string = ''
  private passedUserAvatar: string = ''
  private passedUserName: string = ''

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          if (this.postDetail) {
            PostStateManager.getInstance().updatePostState(
              this.postDetail.postId,
              this.postDetail.isLiked,
              this.postDetail.likeCount
            )
          }
          this.navPathStack.pop()
        })

      if (!this.isLoading && this.postDetail) {
        Row({ space: 8 }) {
          Image(this.postDetail.userAvatar)
            .width(32)
            .height(32)
            .borderRadius(16)
            .onClick(() => {
              this.handleUserClick()
            })

          Text(this.postDetail.userName)
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.handleUserClick()
            })

          if (!this.isOwnPost) {
            Row({ space: 4 }) {
              Image($r('app.media.ic_add'))
                .width(14)
                .height(14)
                .fillColor(this.isFollowing ? '#999999' : '#ffdd0223')

              Text(this.isFollowing ? '已关注' : '关注')
                .fontSize(12)
                .fontColor(this.isFollowing ? '#999999' : '#ffdd0223')
            }
            .padding({ left: 8, right: 10, top: 4, bottom: 4 })
            .borderRadius(12)
            .border({ width: 1, color: this.isFollowing ? '#E0E0E0' : '#ffdd0223' })
            .backgroundColor(this.isFollowing ? '#F5F5F5' : '#FFF5F5')
            .onClick(() => {
              this.handleFollow()
            })
          }
        }
        .layoutWeight(1)
        .margin({ left: 16 })

        Image($r('app.media.ic_more'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            this.handleShare()
          })
      } else {
        Row()
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildContent() {
    if (this.isLoading) {
      LoadingComponent()
    } else if (this.postDetail) {
      Scroll() {
        Column() {
          // 图片内容
          if (this.postDetail.imageUrls && this.postDetail.imageUrls.length > 0) {
            Swiper() {
              ForEach(this.postDetail.imageUrls, (imageUrl: string, index: number) => {
                Image(imageUrl)
                  .width('100%')
                  .objectFit(ImageFit.Contain)
                  .borderRadius(12)
                  .backgroundColor('#FFFFFF')
                  .onClick(() => {
                    this.currentImageIndex = index
                    this.showImagePreview = true
                  })
              })
            }
            .width('100%')
            .height(400)
            .autoPlay(false)
            .indicator(this.postDetail.imageUrls.length > 1 ? 
              DotIndicator.dot()
                .color('#66FFFFFF')
                .selectedColor('#ffdd0223') : false)
            .loop(false)
            .onChange((index: number) => {
              this.currentImageIndex = index
            })
          }

          // 标题
          Text(this.postDetail.title)
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({ top: 16, bottom: 12 })

          // 描述
          Text(this.postDetail.description)
            .fontSize(16)
            .fontColor('#666666')
            .lineHeight(24)
            .width('100%')
            .margin({ bottom: 16 })

          // 发布日期
          Row() {
            Text(this.postDetail.publishDate)
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 评论区
          Divider()
            .color('#F0F0F0')
            .strokeWidth(8)
            .margin({ top: 16 })
          CommentSection({
            postId: this.postDetail.postId,
            refreshTimestamp: this.refreshTimestamp,
            initialComments: this.initialComments,
            onCommentCountChange: (count: number) => {
              this.commentCount = count
            }
          })
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 12, bottom: 12 })
        .margin(0)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({ bottom: 64 })
      .margin(0)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .align(Alignment.TopStart)
    }
  }

  handleShare(): void {
    this.showShareDrawer = true
  }

  handleUserClick(): void {
    if (!this.postDetail || !this.postDetail.userId) return
    
    // 如果是自己的帖子，不跳转（或者跳转到自己的个人页面）
    if (this.isOwnPost) {
      console.log('[PostDetailPage] 点击了自己的头像，不跳转')
      return
    }
    
    // 跳转到用户公开页面
    console.log('[PostDetailPage] 跳转到用户页面:', this.postDetail.userId)
    const param: UserProfileParam = {
      user_id: this.postDetail.userId
    }
    this.navPathStack.pushPathByName('UserProfilePage', param, false)
  }

  /**
   * 处理关注按钮点击
   * @returns
   */
  async handleFollow(): Promise<void> {
    if (!this.postDetail) return
    
    const response = await followUser(this.postDetail.userId)
    if (response.success) {
      this.isFollowing = !this.isFollowing
      ToastUtil.getInstance().show(this.isFollowing ? '关注成功' : '取消关注')
    }
  }

  /**
   * 处理喜欢
   * @returns
   */
  async handleLike(): Promise<void> {
    if (!this.postDetail) return

    const currentLiked = this.postDetail.isLiked
    const response = currentLiked ? await unlikePost(this.postDetail.postId) : await likePost(this.postDetail.postId)

    if (response.success && response.data) {
      this.postDetail.isLiked = response.data.has_liked
      this.postDetail.likeCount = response.data.like_count
      ToastUtil.getInstance().show(response.data.has_liked ? '点赞成功' : '取消点赞')
    }
  }

  // 抽屉的一堆按钮
  handleCopyLink(): void {
    this.showShareDrawer = false
  }
  handleShareWeChat(): void {
    this.showShareDrawer = false
  }
  handleShareMoments(): void {
    this.showShareDrawer = false
  }
  handleShareQQ(): void {
    this.showShareDrawer = false
  }
  handleShareQZone(): void {
    this.showShareDrawer = false
  }
  handleRepost(): void {
    this.showShareDrawer = false
    this.generateShareCard()
  }
  async handleMessage(): Promise<void> {
    this.showShareDrawer = false
    const response = await getFollowingList(this.currentUserId)
    if (response.success && response.data) {
      this.followingList = response.data.users
      if (this.followingList.length === 0) {
        ToastUtil.getInstance().show('暂无关注的好友')
        return
      }
      this.showFriendSelector = true
    } else {
      ToastUtil.getInstance().show(response.message || '获取关注列表失败')
    }
  }
  handleFeedback(): void {
    this.showShareDrawer = false
  }
  handleReport(): void {
    this.showShareDrawer = false
  }
  handleEdit(): void {
    this.showShareDrawer = false
  }

  /**
   * 生成分享卡片
   */
  async generateShareCard() {
    if (!this.postDetail) return

    this.showShareCardPreview = true
  }

  async handleCollect(): Promise<void> {
    this.showShareDrawer = false
    if (!this.postDetail) return

    const currentFavorited = this.postDetail.isFavorited
    const response = currentFavorited ? await unfavoritePost(this.postDetail.postId) : await favoritePost(this.postDetail.postId)

    if (response.success && response.data) {
      this.postDetail.isFavorited = response.data.has_favorited
      this.postDetail.favoriteCount = response.data.favorite_count
      ToastUtil.getInstance().show(response.data.has_favorited ? '收藏成功' : '取消收藏')
    }
  }


  /**
   * 放大查看
   */
  @Builder
  buildImagePreview() {
    if (this.postDetail && this.postDetail.imageUrls.length > 0) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .onClick(() => {
            this.showImagePreview = false
          })

        Swiper() {
          ForEach(this.postDetail.imageUrls, (imageUrl: string) => {
            Image(imageUrl)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)  // 图片完整展示，保持比例
          })
        }
        .width('100%')
        .height('100%')
        .index(this.currentImageIndex)  // 从点击的图片开始
        .indicator(this.postDetail.imageUrls.length > 1 ? 
          DotIndicator.dot()
            .color('#66FFFFFF')
            .selectedColor('#ffdd0223') : false)
        .loop(false)  // 不循环
        .gesture(
          // 手势处理，上下滑动退出
          PanGesture({ direction: PanDirection.Vertical })
            .onActionEnd((event: GestureEvent) => {
              if (Math.abs(event.offsetY) > 50) { // 滑动超过50px
                this.showImagePreview = false
              }
            })
        )
        .onClick(() => {
          this.showImagePreview = false
        })
      }
      .width('100%')
      .height('100%')
      .transition(TransitionEffect.OPACITY.animation({ duration: 400, curve: Curve.EaseInOut }))  // 淡入淡出动画
    }
  }

  @Builder
  buildShareCardPreviewDialog() {
    if (this.postDetail) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#CC000000')
          .onClick(() => {
            this.showShareCardPreview = false
          })

        Column() {
          PostShareCardPreview({
            postTitle: this.postDetail.title,
            postDescription: this.postDetail.description,
            coverImage: this.postDetail.imageUrls && this.postDetail.imageUrls.length > 0 ? 
              this.postDetail.imageUrls[0] : '',
            userName: this.postDetail.userName,
            userAvatar: this.postDetail.userAvatar,
            likeCount: this.postDetail.likeCount,
            favoriteCount: this.postDetail.favoriteCount
          })

          Text('长按保存图片')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .margin({ top: 20 })
        }
      }
      .width('100%')
      .height('100%')
      .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
    }
  }

  @Builder
  buildFriendSelector() {
    if (this.showFriendSelector) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.showFriendSelector = false
          })

        Column() {
          Row() {
            Text('选择好友')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .layoutWeight(1)

            Image($r('app.media.ic_close'))
              .width(24)
              .height(24)
              .fillColor('#999999')
              .onClick(() => {
                this.showFriendSelector = false
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })

          Divider()
            .color('#F0F0F0')

          List({ space: 0 }) {
            ForEach(this.followingList, (friend: FollowingUserInfo) => {
              ListItem() {
                Row({ space: 12 }) {
                  Image(friend.avatar_url)
                    .width(48)
                    .height(48)
                    .borderRadius(24)

                  Column({ space: 4 }) {
                    Text(friend.username)
                      .fontSize(16)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)

                    if (friend.bio) {
                      Text(friend.bio)
                        .fontSize(14)
                        .fontColor('#999999')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .onClick(() => {
                  this.selectedFriend = friend
                  this.showFriendSelector = false
                  this.showShareConfirm = true
                })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
        .width('100%')
        .height('70%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 16, topRight: 16 })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  buildShareConfirm() {
    if (this.showShareConfirm && this.selectedFriend) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.showShareConfirm = false
            this.selectedFriend = null
          })

        Column({ space: 0 }) {
          Column({ space: 8 }) {
            Text('确认分享')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Text(`将帖子分享给 ${this.selectedFriend.username}？`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(24)

          Divider()
            .color('#F0F0F0')

          Row() {
            Button('取消')
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .layoutWeight(1)
              .onClick(() => {
                this.showShareConfirm = false
                this.selectedFriend = null
              })

            Button('确定')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#ffdd0223')
              .layoutWeight(1)
              .onClick(() => {
                this.handleShareConfirm()
              })
          }
          .width('100%')
          .padding(16)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('80%')
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
      }
      .width('100%')
      .height('100%')
    }
  }

  async handleShareConfirm(): Promise<void> {
    if (!this.selectedFriend || !this.postDetail) return

    const response = await sharePost({
      post_id: this.postDetail.postId,
      receiver_id: this.selectedFriend.user_id
    })

    if (response.success) {
      ToastUtil.getInstance().show('分享成功')
      this.showShareConfirm = false
      this.selectedFriend = null
    } else {
      ToastUtil.getInstance().show(response.message || '分享失败')
    }
  }

  /**
   * 数据加载
   * @returns
   */
  async loadPostData(): Promise<void> {
    if (!this.postId) return

    this.isLoading = true

    // 1. 获取当前用户id
    const tokenManager = TokenManager.getInstance()
    const cachedUserId = await tokenManager.getUserId()
    if (cachedUserId) {
      this.currentUserId = cachedUserId
    }

    // 2. 获取帖子详情
    const detailResponse = await getPostDetail(this.postId)
    
    if (detailResponse.success && detailResponse.data) {
      const post = detailResponse.data.post
      const postUserId = typeof post.user_id === 'number' ? post.user_id.toString() : post.user_id
      this.isOwnPost = this.currentUserId === postUserId

      // 3. 并行并行并行
      const favoritePromise = getFavoriteStatus(this.postId)
      const likePromise = getLikeStatus(this.postId)
      const commentsPromise = getComments(this.postId, 1, 20)
      
      if (!this.isOwnPost) {
        const followPromise = getFollowStatus(postUserId)
        const results = await Promise.all([favoritePromise, likePromise, commentsPromise, followPromise])
        const favoriteResponse = results[0]
        const likeResponse = results[1]
        const commentsResponse = results[2]
        const followResponse = results[3]
        
        const imageUrls = post.images ? post.images.map(img => img.file_url) : []
        const publishDate = this.formatTimestamp(post.create_time)

        
        // 由于getPostDetail API没有返回author信息，我们需要从其他地方获取
        let userAvatar = this.passedUserAvatar || post.avatar_url || 'https://picsum.photos/60/60'
        let userName = this.passedUserName || post.username || `用户${postUserId}`
        
        // 尝试从用户作品API获取帖主信息
        try {
          const UserApi = await import('../services/api/UserApi')
          const userPostsResponse = await UserApi.getUserPosts({
            user_id: postUserId,
            page: 1,
            pageSize: 1
          })
          
          if (userPostsResponse.success && userPostsResponse.data && userPostsResponse.data.posts.length > 0) {
            const firstPost = userPostsResponse.data.posts[0]
            if (firstPost.author) {
              userAvatar = firstPost.author.avatar_url || userAvatar
              userName = firstPost.author.username || userName
            }
          }
        } catch (error) {
          console.error('[PostDetailPage] 获取用户作品信息失败:', error)
        }
        

        // 4. 构造
        this.postDetail = {
          postId: post.post_id,
          imageUrls: imageUrls,
          title: post.title,
          description: post.description || '',
          userAvatar: userAvatar,
          userId: postUserId,
          userName: userName,
          publishDate: publishDate,
          likeCount: post.like_count,
          isLiked: likeResponse.success && likeResponse.data ? likeResponse.data.has_liked : false,
          favoriteCount: post.favorite_count,
          isFavorited: favoriteResponse.success && favoriteResponse.data ? favoriteResponse.data.has_favorited : false
        }

        if (followResponse.success && followResponse.data) {
          this.isFollowing = followResponse.data.is_following
        }

        if (commentsResponse.success && commentsResponse.data) {
          this.initialComments = commentsResponse.data.comments
          this.commentCount = commentsResponse.data.total
        }
      } else {
        const results = await Promise.all([favoritePromise, likePromise, commentsPromise])
        const favoriteResponse = results[0]
        const likeResponse = results[1]
        const commentsResponse = results[2]
        
        const imageUrls = post.images ? post.images.map(img => img.file_url) : []
        const publishDate = this.formatTimestamp(post.create_time)
        const userAvatar = this.passedUserAvatar || post.author?.avatar_url || post.avatar_url || 'https://picsum.photos/60/60'
        const userName = this.passedUserName || post.author?.username || post.username || `用户${postUserId}`

        this.postDetail = {
          postId: post.post_id,
          imageUrls: imageUrls,
          title: post.title,
          description: post.description || '',
          userAvatar: userAvatar,
          userId: postUserId,
          userName: userName,
          publishDate: publishDate,
          likeCount: post.like_count,
          isLiked: likeResponse.success && likeResponse.data ? likeResponse.data.has_liked : false,
          favoriteCount: post.favorite_count,
          isFavorited: favoriteResponse.success && favoriteResponse.data ? favoriteResponse.data.has_favorited : false
        }

        if (commentsResponse.success && commentsResponse.data) {
          this.initialComments = commentsResponse.data.comments
          this.commentCount = commentsResponse.data.total
        }
      }
    } else {
      ToastUtil.getInstance().show(detailResponse.message || '加载失败')
    }

    this.isLoading = false
  }

  /**
   * 时间序列化
   * @param timestamp
   * @returns
   */
  formatTimestamp(timestamp: number): string {
    const date = new Date(timestamp * 1000)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  /**
   * 处理评论发送
   * @returns
   */
  async handleSendComment(): Promise<void> {
    if (!this.commentText.trim() || !this.postId) return

    const content = this.commentText.trim()
    const response = await createComment(this.postId, content)

    if (response.success) {
      this.commentText = ''
      ToastUtil.getInstance().show('评论成功')
      this.refreshTimestamp = Date.now()
    } else {
      ToastUtil.getInstance().show(response.message || '评论失败')
    }
  }

  /**
   * 底部操作栏
   */
  @Builder
  buildBottomBar() {
    Row({ space: 12 }) {
      TextInput({ placeholder: '说点什么...', text: this.commentText })
        .layoutWeight(1)
        .height(40)
        .fontSize(14)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.commentText = value
        })

      // 发送按钮
      Button('发送')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#ffdd0223')
        .height(40)
        .padding({ left: 16, right: 16 })
        .borderRadius(20)
        .enabled(this.commentText.trim().length > 0)
        .opacity(this.commentText.trim().length > 0 ? 1 : 0.5)
        .onClick(() => {
          this.handleSendComment()
        })

      // 点赞按钮
      Row({ space: 4 }) {
        Image(this.postDetail?.isLiked ? $r('app.media.ic_heart_filled') : $r('app.media.ic_heart_outline'))
          .width(24)
          .height(24)
          .fillColor(this.postDetail?.isLiked ? '#FF4757' : '#666666')

        if (this.postDetail && this.postDetail.likeCount > 0) {
          Text(this.postDetail.likeCount.toString())
            .fontSize(12)
            .fontColor('#666666')
        }
      }
      .onClick(() => {
        this.handleLike()
      })

      // 收藏
      Row({ space: 4 }) {
        Image(this.postDetail?.isFavorited ? $r('app.media.ic_favorite_filled') : $r('app.media.ic_favorite_outline'))
          .width(24)
          .height(24)
          .fillColor(this.postDetail?.isFavorited ? '#FFD700' : '#666666')

        if (this.postDetail && this.postDetail.favoriteCount > 0) {
          Text(this.postDetail.favoriteCount.toString())
            .fontSize(12)
            .fontColor('#666666')
        }
      }
      .onClick(() => {
        this.handleCollect()
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 8, color: '#1F000000', offsetY: -2 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          this.buildHeader()
          this.buildContent()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')

        if (!this.isLoading && this.postDetail) {
          this.buildBottomBar()
        }

        if (this.showShareDrawer) {
          ShareDrawer({
            visible: this.showShareDrawer,
            isFavorited: this.postDetail?.isFavorited || false,
            isOwnPost: this.isOwnPost,
            onClose: () => this.showShareDrawer = false,
            onCopyLink: () => this.handleCopyLink(),
            onShareWeChat: () => this.handleShareWeChat(),
            onShareMoments: () => this.handleShareMoments(),
            onShareQQ: () => this.handleShareQQ(),
            onShareQZone: () => this.handleShareQZone(),
            onRepost: () => this.handleRepost(),
            onMessage: () => this.handleMessage(),
            onCollect: () => this.handleCollect(),
            onFeedback: () => this.handleFeedback(),
            onReport: () => this.handleReport(),
            onEdit: () => this.handleEdit()
          })
        }

        if (this.showImagePreview) {
          this.buildImagePreview()
        }

        if (this.showShareCardPreview) {
          this.buildShareCardPreviewDialog()
        }

        if (this.showFriendSelector) {
          this.buildFriendSelector()
        }

        if (this.showShareConfirm) {
          this.buildShareConfirm()
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathInfos = context.pathStack
      const param = context.pathInfo.param as Record<string, Object>
      this.postId = param.post_id as string
      this.passedUserAvatar = param.user_avatar as string || ''
      this.passedUserName = param.user_name as string || ''
      if (this.postId) {
        this.loadPostData()
      }
    })
  }
}
