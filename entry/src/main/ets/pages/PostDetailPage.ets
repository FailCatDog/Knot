import { PostDetailEntity } from '../models/entities/PostDetailEntity'
import { ShareDrawer } from '../views/components/ShareDrawer'
import { favoritePost, getPostDetail, getFavoriteStatus, likePost, unlikePost, getLikeStatus } from '../services/api/PostApi'
import { ToastUtil } from '../common/utils/ToastUtil'
import { PostStateManager } from '../common/utils/PostStateManager'
import { LoadingComponent } from '../views/components/LoadingComponent'

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
  @Consume('NavPathStack') navPathStack: NavPathStack
  pathInfos: NavPathStack = new NavPathStack()
  private postId: string = ''

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

      Row() {
        Image(this.postDetail?.userAvatar)
          .width(32)
          .height(32)
          .borderRadius(16)
          .margin({ right: 8 })

        Text(this.postDetail?.userName)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
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
            .indicator(this.postDetail.imageUrls.length > 1)
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

            Blank()

            Row({ space: 16 }) {
              Row({ space: 4 }) {
                Image(this.postDetail.isFavorited ? $r('app.media.ic_favorite_filled') : $r('app.media.ic_favorite_outline'))
                  .width(20)
                  .height(20)
                  .fillColor(this.postDetail.isFavorited ? '#FFD700' : '#999999')
                  .animation({
                    duration: 200,
                    curve: Curve.EaseInOut
                  })
                  .onClick(() => {
                    this.handleCollect()
                  })

                Text(this.postDetail.favoriteCount.toString())
                  .fontSize(14)
                  .fontColor('#666666')
                  .animation({
                    duration: 200,
                    curve: Curve.EaseInOut
                  })
              }

              Row({ space: 4 }) {
                Image(this.postDetail.isLiked ? $r('app.media.ic_heart_filled') : $r('app.media.ic_heart_outline'))
                  .width(20)
                  .height(20)
                  .fillColor(this.postDetail.isLiked ? '#FF4757' : '#999999')
                  .animation({
                    duration: 200,
                    curve: Curve.EaseInOut
                  })
                  .onClick(() => {
                    this.handleLike()
                  })

                Text(this.postDetail.likeCount.toString())
                  .fontSize(14)
                  .fontColor('#666666')
                  .animation({
                    duration: 200,
                    curve: Curve.EaseInOut
                  })
              }
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 12, bottom: 12 })
        .margin(0)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding(0)
      .margin(0)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .align(Alignment.TopStart)
    }
  }

  handleShare(): void {
    this.showShareDrawer = true
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
  }

  handleMessage(): void {
    this.showShareDrawer = false
  }

  async handleCollect(): Promise<void> {
    this.showShareDrawer = false
    if (!this.postDetail) return
    
    const response = await favoritePost(this.postDetail.postId)
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

  async loadPostData(): Promise<void> {
    if (!this.postId) return

    this.isLoading = true

    const results = await Promise.all([
      getPostDetail(this.postId),
      getFavoriteStatus(this.postId),
      getLikeStatus(this.postId)
    ])
    
    const detailResponse = results[0]
    const favoriteResponse = results[1]
    const likeResponse = results[2]

    if (detailResponse.success && detailResponse.data) {
      const post = detailResponse.data.post
      const imageUrls = post.images ? post.images.map(img => img.file_url) : []
      const publishDate = this.formatTimestamp(post.create_time)

      this.postDetail = {
        postId: post.post_id,
        imageUrls: imageUrls,
        title: post.title,
        description: post.description || '',
        userAvatar: 'https://picsum.photos/60/60',
        userId: `用户${post.user_id}`,
        userName: `用户${post.user_id}`,
        publishDate: publishDate,
        likeCount: post.like_count,
        isLiked: likeResponse.success && likeResponse.data ? likeResponse.data.has_liked : false,
        favoriteCount: post.favorite_count,
        isFavorited: favoriteResponse.success && favoriteResponse.data ? favoriteResponse.data.has_favorited : false
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

        if (this.showShareDrawer) {
          ShareDrawer({
            visible: this.showShareDrawer,
            isFavorited: this.postDetail?.isFavorited || false,
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
            onReport: () => this.handleReport()
          })
        }

        if (this.showImagePreview) {
          this.buildImagePreview()
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
      if (this.postId) {
        this.loadPostData()
      }
    })
  }
}
