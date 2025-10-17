@Component
export struct ShareDrawer {
  @Prop visible: boolean
  onClose: () => void = () => {}
  onCopyLink: () => void = () => {}
  onShareWeChat: () => void = () => {}
  onShareMoments: () => void = () => {}
  onShareQQ: () => void = () => {}
  onShareQZone: () => void = () => {}
  onRepost: () => void = () => {}
  onMessage: () => void = () => {}
  onCollect: () => void = () => {}
  onFeedback: () => void = () => {}
  onReport: () => void = () => {}

  @Builder
  buildShareItem(text: string, icon: Resource, onClick: () => void) {
    Column() {
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor('#333333')
      }
      .width(48)
      .height(48)
      .backgroundColor('#F5F5F5')
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)

      Text(text)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 8 })
    }
    .width(60)
    .onClick(onClick)
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.onClose()
          })
          .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))

        Column() {
          Column() {
            Row() {
              this.buildShareItem('复制链接', $r('app.media.ic_copy_link'), this.onCopyLink)
              this.buildShareItem('微信', $r('app.media.ic_wechat'), this.onShareWeChat)
              this.buildShareItem('朋友圈', $r('app.media.ic_moments'), this.onShareMoments)
              this.buildShareItem('QQ', $r('app.media.ic_qq'), this.onShareQQ)
              this.buildShareItem('QQ空间', $r('app.media.ic_qzone'), this.onShareQZone)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .margin({ bottom: 24 })

            Row() {
              this.buildShareItem('转发动态', $r('app.media.ic_repost'), this.onRepost)
              this.buildShareItem('私信好友', $r('app.media.ic_send'), this.onMessage)
              this.buildShareItem('收藏', $r('app.media.ic_collect'), this.onCollect)
              this.buildShareItem('内容反馈', $r('app.media.ic_heartbreak'), this.onFeedback)
              this.buildShareItem('举报', $r('app.media.ic_report'), this.onReport)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 24, bottom: 24 })
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 16, topRight: 16 })
        }
        .width('100%')
        .translate({ y: this.visible ? 0 : 500 })
        .animation({ duration: 300, curve: Curve.EaseInOut })
      }
      .width('100%')
      .height('100%')
    }
  }
}

