import { router } from '@kit.ArkUI'

@Entry
@Component
struct SplashPage {
  @State fadeOpacity: number = 0
  @State scaleValue: number = 0.8

  aboutToAppear(): void {
    animateTo({
      duration: 800,
      curve: Curve.EaseOut
    }, () => {
      this.fadeOpacity = 1
      this.scaleValue = 1
    })

    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/MainPage'
      })
    }, 2500)
  }

  build() {
    Column() {
      Column() {
        Image($r('app.media.ic_icon'))
          .width(120)
          .height(120)
          .margin({ bottom: 24 })
          .opacity(this.fadeOpacity)
          .scale({ x: this.scaleValue, y: this.scaleValue })

        Text('Knot')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffdd0223')
          .letterSpacing(2)
          .margin({ bottom: 12 })
          .opacity(this.fadeOpacity)

        Text('发现生活的美好瞬间')
          .fontSize(14)
          .fontColor('#999999')
          .opacity(this.fadeOpacity)
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      Column() {
        Text('© 2025 Knot Team')
          .fontSize(12)
          .fontColor('#CCCCCC')
          .margin({ bottom: 24 })
          .opacity(this.fadeOpacity)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

