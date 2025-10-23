export interface ImageItem {
  id: string
  imageUrl: string
  title: string
  description: string
  userAvatar: string | Resource
  userId: string
  likeCount: number
  isLiked: boolean
  imageHeight: number
}

interface ImageCompleteEvent {
  width: number
  height: number
}

@Component
export struct ImageCard {
  @Prop item: ImageItem
  onLikeClick: (id: string) => void = () => {}
  onFollowClick: (id: string) => void = () => {}
  onCardClick: (id: string) => void = () => {}

  @State private imageAspectRatio: number = 0.75

  build() {
    Column() {
      // 图片区域
      Stack({ alignContent: Alignment.TopEnd }) {
        // 图片
        Image(this.item.imageUrl)
          .width('100%')
          .aspectRatio(this.imageAspectRatio)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
          .onComplete((event: ImageCompleteEvent) => {
            if (event.width > 0 && event.height > 0) {
              this.imageAspectRatio = event.width / event.height
            }
          })
      }
      .width('100%')
      .clip(true)

      // 内容区域
      Column() {
        if (this.item.title && this.item.title.trim() !== '') {
          Text(this.item.title)
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ bottom: 4 })
        }

        Row() {
          Row() {
            Image(this.item.userAvatar)
              .width(24)
              .height(24)
              .borderRadius(12)
              .margin({ right: 6 })
              .objectFit(ImageFit.Cover)

            Text(this.item.userId)
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .alignItems(VerticalAlign.Center)
          .layoutWeight(1)

          Row() {
            Column() {
              Image(this.item.isLiked ? $r('app.media.ic_heart_filled') : $r('app.media.ic_heart_outline'))
                .width(20)
                .height(20)
                .fillColor(this.item.isLiked ? '#FF4757' : '#999999')
                .animation({
                  duration: 200,
                  curve: Curve.EaseInOut
                })
                .onClick(() => {
                  this.onLikeClick(this.item.id)
                })
            }
            .margin({ right: 4 })

            Text(this.item.likeCount.toString())
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .padding(8)
      .width('100%')
      .backgroundColor('#FFFFFF')
    }
    .borderRadius(12)//由于色差，为我的页面的帖子渲染添加圆角
    .width('100%')
    .clip(true)
    .onClick(() => {
      this.onCardClick(this.item.id)
    })
  }
}