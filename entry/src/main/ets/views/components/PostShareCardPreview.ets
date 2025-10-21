@Component
export struct PostShareCardPreview {
  @Prop postTitle: string = ''
  @Prop postDescription: string = ''
  @Prop coverImage: string = ''
  @Prop userName: string = ''
  @Prop userAvatar: string = ''
  @Prop likeCount: number = 0
  @Prop favoriteCount: number = 0

  build() {
    Column() {
      Column() {
        if (this.coverImage && this.coverImage.trim() !== '') {
          Image(this.coverImage)
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 12, topRight: 12 })
        }

        Column() {
          Text(this.postTitle)
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ bottom: 8 })

          Text(this.postDescription)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(20)
            .width('100%')
            .margin({ bottom: 12 })

          Row({ space: 16 }) {
            Row({ space: 4 }) {
              Image($r('app.media.ic_heart_outline'))
                .width(16)
                .height(16)
                .fillColor('#999999')

              Text(this.likeCount.toString())
                .fontSize(12)
                .fontColor('#666666')
            }

            Row({ space: 4 }) {
              Image($r('app.media.ic_favorite_outline'))
                .width(16)
                .height(16)
                .fillColor('#999999')

              Text(this.favoriteCount.toString())
                .fontSize(12)
                .fontColor('#666666')
            }
          }
          .width('100%')
          .margin({ bottom: 12 })

          Divider()
            .color('#F0F0F0')
            .margin({ bottom: 12 })

          Row({ space: 8 }) {
            Image(this.userAvatar && this.userAvatar.trim() !== '' ? this.userAvatar : $r('app.media.head'))
              .width(24)
              .height(24)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.head'))

            Text(this.userName)
              .fontSize(12)
              .fontColor('#666666')

            Blank()

            Text('长按保存分享卡片')
              .fontSize(11)
              .fontColor('#999999')
          }
          .width('100%')
        }
        .padding(16)
      }
      .width(320)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 16, color: '#1A000000', offsetY: 4 })
    }
    .width(320)
    .padding(20)
    .backgroundColor('#F5F5F5')
  }
}

