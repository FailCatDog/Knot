import { PostDetailViewModel } from '../viewmodels/PostDetailViewModel'

@Builder
export function PostDetailPageBuilder() {
  PostDetailPage()
}

@Component
struct PostDetailPage {
  @State viewModel: PostDetailViewModel = new PostDetailViewModel()
  @Consume('NavPathStack') navPathStack: NavPathStack
  pathInfos: NavPathStack = new NavPathStack()
  postId: string = ''

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
        Image(this.viewModel.postDetail?.userAvatar)
          .width(32)
          .height(32)
          .borderRadius(16)
          .margin({ right: 8 })

        Text(this.viewModel.postDetail?.userName)
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
    if (this.viewModel.postDetail) {
      Scroll() {
        Column() {
          Image(this.viewModel.postDetail.imageUrl)
            .width('100%')
            .objectFit(ImageFit.Cover)
            .borderRadius(12)

          Text(this.viewModel.postDetail.title)
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({ top: 16, bottom: 12 })

          Text(this.viewModel.postDetail.description)
            .fontSize(16)
            .fontColor('#666666')
            .lineHeight(24)
            .width('100%')
            .margin({ bottom: 16 })

          Row() {
            Text(this.viewModel.postDetail.publishDate)
              .fontSize(14)
              .fontColor('#999999')

            Blank()

            Row() {
              Image(this.viewModel.postDetail.isLiked ? $r('app.media.ic_heart_filled') : $r('app.media.ic_heart_outline'))
                .width(20)
                .height(20)
                .fillColor(this.viewModel.postDetail.isLiked ? '#FF4757' : '#999999')
                .animation({
                  duration: 200,
                  curve: Curve.EaseInOut
                })
                .onClick(() => {
                  this.handleLike()
                })

              Text(this.viewModel.postDetail.likeCount.toString())
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

  }

  handleLike(): void {
    this.viewModel.toggleLike()
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        this.buildContent()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathInfos = context.pathStack
      this.postId = context.pathInfo.param as string
      console.log('[PostDetailPage] 接收到的参数:', this.postId)
      this.viewModel.loadPostDetail(this.postId)
    })
  }
}
