import router from '@ohos.router'
import { PostDetailEntity } from '../models/entities/PostDetailEntity'
import { PostDetailViewModel } from '../viewmodels/PostDetailViewModel'

interface RouterParams {
  postId: string
  imageUrl?: string
  title?: string
  description?: string
  userAvatar?: string
  userId?: string
  likeCount?: number
  isLiked?: boolean
  imageHeight?: number
}

@Builder
export function PostDetailPageBuilder() {
  PostDetailPage()
}

@Entry
@Component
struct PostDetailPage {
  @State postDetail: PostDetailEntity | null = null
  private viewModel: PostDetailViewModel = new PostDetailViewModel()

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams
    if (params && params.postId) {
      if (params.imageUrl && params.title !== undefined && params.userAvatar && params.userId) {
        const detailData: PostDetailEntity = {
          id: params.postId,
          imageUrl: params.imageUrl,
          title: params.title,
          description: params.description || '',
          userAvatar: params.userAvatar,
          userId: params.userId,
          userName: params.userId,
          publishDate: this.getDateForId(params.postId),
          likeCount: params.likeCount || 0,
          isLiked: params.isLiked || false
        }
        this.viewModel.setPostDetail(detailData)
        this.postDetail = detailData
      } else {
        this.postDetail = this.viewModel.getPostDetail(params.postId)
      }
    }
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          router.back()
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
          Image(this.postDetail.imageUrl)
            .width('100%')
            .objectFit(ImageFit.Cover)
            .borderRadius(12)

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

  getDateForId(id: string): string {
    const dates = [
      '2024-01-15', '2024-02-20', '2024-03-10', '2024-04-05',
      '2024-05-18', '2024-06-22', '2024-07-08', '2024-08-12',
      '2024-09-25', '2024-10-30', '2024-11-14', '2024-12-03'
    ]
    return dates[parseInt(id) % dates.length] || '2024-01-01'
  }

  handleShare(): void {

  }

  handleLike(): void {
    this.viewModel.toggleLike()
    this.postDetail = this.viewModel.getCurrentPost()
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
