import { PostDetailEntity } from '../models/entities/PostDetailEntity'
import { ShareDrawer } from '../views/components/ShareDrawer'

@Builder
export function PostDetailPageBuilder() {
  PostDetailPage()
}

@Component
struct PostDetailPage {
  @State postDetail: PostDetailEntity | null = null
  @State showShareDrawer: boolean = false
  @Consume('NavPathStack') navPathStack: NavPathStack
  pathInfos: NavPathStack = new NavPathStack()

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
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
    if (this.postDetail) {
      Scroll() {
        Column() {
          if (this.postDetail.imageUrls && this.postDetail.imageUrls.length > 0) {
            Swiper() {
              ForEach(this.postDetail.imageUrls, (imageUrl: string) => {
                Image(imageUrl)
                  .width('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)
              })
            }
            .width('100%')
            .height(400)
            .autoPlay(false)
            .indicator(this.postDetail.imageUrls.length > 1)
            .loop(false)
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

            Row() {
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
                .margin({ left: 4 })
                .animation({
                  duration: 200,
                  curve: Curve.EaseInOut
                })
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

  handleLike(): void {
    if (this.postDetail) {
      this.postDetail.isLiked = !this.postDetail.isLiked
      this.postDetail.likeCount += this.postDetail.isLiked ? 1 : -1
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

  handleCollect(): void {
    this.showShareDrawer = false
  }

  handleFeedback(): void {
    this.showShareDrawer = false
  }

  handleReport(): void {
    this.showShareDrawer = false
  }

  convertPostToDetail(post: Record<string, Object>): PostDetailEntity {
    const createTime = post.create_time
    const publishDate = typeof createTime === 'string' && createTime ? createTime.split(' ')[0] : ''
    const imageUrls = post.image_urls as Object
    const fullImageUrls: string[] = Array.isArray(imageUrls) ? imageUrls : []
    
    return {
      id: post.post_id as string,
      imageUrls: fullImageUrls,
      title: post.title as string,
      description: post.description as string,
      userAvatar: 'https://picsum.photos/60/60',
      userId: `用户${post.user_id}`,
      userName: `用户${post.user_id}`,
      publishDate: publishDate,
      likeCount: post.like_count as number,
      isLiked: false
    }
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
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathInfos = context.pathStack
      const post = context.pathInfo.param as Record<string, Object>
      console.log('[PostDetailPage] 接收到的参数:', JSON.stringify(post))
      if (post) {
        this.postDetail = this.convertPostToDetail(post)
      }
    })
  }
}
