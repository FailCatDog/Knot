import { PostDetailEntity } from '../models/entities/PostDetailEntity'
import { ShareDrawer } from '../views/components/ShareDrawer'
import { favoritePost, unfavoritePost, getPostDetail, getFavoriteStatus, likePost, unlikePost, getLikeStatus } from '../services/api/PostApi'
import { ToastUtil } from '../common/utils/ToastUtil'
import { PostStateManager } from '../common/utils/PostStateManager'
import { LoadingComponent } from '../views/components/LoadingComponent'
import { followUser, getCurrentUserInfo, getFollowStatus } from '../services/api/UserApi'
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

          Text(this.postDetail.title)
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({ top: 16, bottom: 12 })

          Text(this.postDetail.description)
            .fontSize(16)
            .fontColor('#666666')
            .lineHeight(24)
            .width('100%')
            .margin({ bottom: 16 })

          Row() {
            Text(this.postDetail.publishDate)
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .margin({ bottom: 8 })

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

  async handleFollow(): Promise<void> {
    if (!this.postDetail) return
    
    const response = await followUser(this.postDetail.userId)
    if (response.success) {
      this.isFollowing = !this.isFollowing
      ToastUtil.getInstance().show(this.isFollowing ? '关注成功' : '取消关注')
    }
  }

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

  handleMessage(): void {
    this.showShareDrawer = false
  }

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

  handleFeedback(): void {
    this.showShareDrawer = false
  }

  handleReport(): void {
    this.showShareDrawer = false
  }

  handleEdit(): void {
    this.showShareDrawer = false
  }

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
              .objectFit(ImageFit.Contain)
          })
        }
        .width('100%')
        .height('100%')
        .index(this.currentImageIndex)
        .indicator(this.postDetail.imageUrls.length > 1 ? 
          DotIndicator.dot()
            .color('#66FFFFFF')
            .selectedColor('#ffdd0223') : false)
        .loop(false)
        .gesture(
          PanGesture({ direction: PanDirection.Vertical })
            .onActionEnd((event: GestureEvent) => {
              if (Math.abs(event.offsetY) > 50) {
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
      .transition(TransitionEffect.OPACITY.animation({ duration: 400, curve: Curve.EaseInOut }))
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

  async loadPostData(): Promise<void> {
    if (!this.postId) return

    this.isLoading = true

    const tokenManager = TokenManager.getInstance()
    const cachedUserId = await tokenManager.getUserId()
    if (cachedUserId) {
      this.currentUserId = cachedUserId
    }

    const detailResponse = await getPostDetail(this.postId)

    if (detailResponse.success && detailResponse.data) {
      const post = detailResponse.data.post
      const postUserId = typeof post.user_id === 'number' ? post.user_id.toString() : post.user_id
      this.isOwnPost = this.currentUserId === postUserId

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

  formatTimestamp(timestamp: number): string {
    const date = new Date(timestamp * 1000)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

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
