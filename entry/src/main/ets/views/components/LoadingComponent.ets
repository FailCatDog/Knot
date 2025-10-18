@Component
export struct LoadingComponent {
  build() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#ffdd0223')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

