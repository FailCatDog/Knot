interface CourseItem {
  id: number;
  image: Resource;
  title: string;
  subtitle: string;
  author: string;
  courseTitle: string;
}

interface ActivityItem {
  id: number;
  image: Resource;
  title: string;
  subtitle: string;
  daysLeft: string;
  tag: string;
}

@Component
export struct MessagePage {
  build() {
    Column() {
      // 头部
      Row() {
        Text('影像馆')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Blank()

        Image($r('app.media.layered_image'))
          .width(24)
          .height(24)
          .fillColor('#666666')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .shadow({ radius: 2, color: '#0A000000', offsetX: 0, offsetY: 2 })

      // 主内容区
      Scroll() {
        Column() {
          Column() {
            Row() {
              Text('学院')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')

              Blank()

              Row() {
                Text('更多')
                  .fontSize(13)
                  .fontColor('#999999')

                Image($r('app.media.layered_image'))
                  .width(12)
                  .height(12)
                  .margin({ left: 4 })
                  .fillColor('#999999')
              }
            }
            .width('100%')
            .height(48)
            .margin({top:-24})
            .alignItems(VerticalAlign.Center)

            // 第一个课程卡片
            Column() {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image('https://tse2-mm.cn.bing.net/th/id/OIP-C.fi1mWfDePiid5iAb5qUoqAHaE7?w=242&h=180&c=7&r=0&o=7&cb=12&dpr=1.4&pid=1.7&rm=3')
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                  .borderRadius({ topLeft: 12, topRight: 12 })

                Column()
                  .width('100%')
                  .height('100%')
                  .borderRadius({ topLeft: 12, topRight: 12 })
                  .linearGradient({
                    angle: 180,
                    colors: [[0x00000000, 0.0], [0x11000000, 1.0]]
                  })

                Column() {
                  Row() {
                    Text('手机摄影教程')
                      .fontSize(11)
                      .fontColor('#E0E0E0')

                    Blank()

                    Row() {
                      Text('@我叫花花')
                        .fontSize(10)
                        .fontColor('#E0E0E0')

                      Text('1.44万')
                        .fontSize(10)
                        .fontColor('#E0E0E0')
                        .margin({ left: 4 })
                    }
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  Text('水面镜像拍摄攻略')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .margin({ bottom: 12 })

                  Row() {
                    Text('#城市微度假')
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor('rgba(33, 150, 243, 0.9)')
                      .borderRadius(12)
                      .margin({ right: 8 })

                    Text('#出片攻略')
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor('rgba(33, 150, 243, 0.9)')
                      .borderRadius(12)
                  }
                }
                .padding({ left: 16, right: 16, bottom: 16 })
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
              .height(200)

              Row() {
                Text('城市微度假｜利用水面镜像拍法攻略')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .padding({ left: 16, top: 12, bottom: 12, right: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius({ bottomLeft: 12, bottomRight: 12 })
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 20 })
            .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })

            // 课程网格
            Grid() {
              ForEach([
                {
                  id: 1,
                  image: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.311iFSAdr4jp1WGJCBHG2wHaE1?w=298&h=194&c=7&r=0&o=7&cb=12&dpr=1.4&pid=1.7&rm=3',
                  title: '地铁站时光隧道拍摄攻略',
                  subtitle: '城市微度假｜地铁站拍...',
                  author: '@我叫花88',
                  courseTitle: '手机摄影教程'
                },
                {
                  id: 2,
                  image: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.ZUpX5MfAhXZGaptmJ43LAgHaE7?w=253&h=180&c=7&r=0&o=7&cb=12&dpr=1.4&pid=1.7&rm=3',
                  title: '手机怎么给小朋友拍大片',
                  subtitle: '在家拍小朋友没有故事...',
                  author: '@高小尚摄影',
                  courseTitle: '手机摄影教程'
                }
              ], (item: CourseItem) => {
                GridItem() {
                  Column() {
                    Stack({ alignContent: Alignment.TopStart }) {
                      Image(item.image)
                        .width('100%')
                        .height(128)
                        .objectFit(ImageFit.Cover)
                        .borderRadius({ topLeft: 12, topRight: 12 })

                      Column()
                        .width('100%')
                        .height('100%')
                        .borderRadius({ topLeft: 12, topRight: 12 })
                        .linearGradient({
                          angle: 180,
                          colors: [[0x00000000, 0.0], [0x11000000, 1.0]]
                        })

                      Text(item.courseTitle)
                        .fontSize(10)
                        .fontColor('#000000')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .backgroundColor('#FFFFFF')
                        .borderRadius(4)
                        .margin({ top: 100, left: 8 })

                      Column() {
                        Text(item.title)
                          .fontSize(12)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#FFFFFF')
                          .margin({ bottom: 4 })
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })

                        Text(item.author)
                          .fontSize(10)
                          .fontColor('#E0E0E0')
                      }
                      .padding({ top:4,left: 8, right: 8, bottom: 8 })
                      .alignItems(HorizontalAlign.Start)
                      .width('100%')
                      .alignSelf(ItemAlign.End)
                    }
                    .height(128)

                    Row() {
                      Text(item.subtitle)
                        .fontSize(12)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                    }
                    .padding({ left: 12, top: 12, bottom: 12, right: 12 })
                    .backgroundColor('#FFFFFF')
                    .borderRadius({ bottomLeft: 12, bottomRight: 12 })
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })
                }
              }, (item: CourseItem) => item.id.toString())
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .margin({ bottom: 24 })
          }
          .padding({ left: 16, right: 16, top: 20 })

          Column() {
            Row() {
              Text('活动')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')

              Blank()

              Row() {
                Text('更多')
                  .fontSize(13)
                  .fontColor('#999999')

                Image($r('app.media.layered_image'))
                  .width(12)
                  .height(12)
                  .margin({ left: 4 })
                  .fillColor('#999999')
              }
            }
            .width('100%')
            .height(48)
            .alignItems(VerticalAlign.Center)

            // 活动网格
            Grid() {
              ForEach([
                {
                  id: 1,
                  image: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.9Ak4jO_XVB2_WIDH6epDYQHaE7?w=265&h=180&c=7&r=0&o=7&cb=12&dpr=1.4&pid=1.7&rm=3',
                  title: '城市微度假·出片攻略分享',
                  subtitle: '分享你的城市微度假美照攻略，赢教程达人...',
                  daysLeft: '距结束2日',
                  tag: '大赛'
                },
                {
                  id: 2,
                  image: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.unBDPaq5zy7pTDILISk9vgHaE8?w=296&h=197&c=7&r=0&o=7&cb=12&dpr=1.4&pid=1.7&rm=3',
                  title: 'Hi,靓仔来分享！',
                  subtitle: '你的国庆"高光时刻"',
                  daysLeft: '距结束5日',
                  tag: '互动话题'
                }
              ], (item: ActivityItem) => {
                GridItem() {
                  Stack({ alignContent: Alignment.TopStart }) {
                    Image(item.image)
                      .width('100%')
                      .height(160)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(12)

                    Column()
                      .width('100%')
                      .height('100%')
                      .borderRadius(12)
                      .linearGradient({
                        angle: 180,
                        colors: [[0x00000000, 0.0], [0x11000000, 1.0]]
                      })

                    Row() {
                      Text(item.daysLeft)
                        .fontSize(10)
                        .fontColor('#000000')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .backgroundColor('#FFFFFF')
                        .borderRadius(4)

                      Blank()

                      Text(item.tag)
                        .fontSize(10)
                        .fontColor('#FFFFFF')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .backgroundColor('#FF5252')
                        .borderRadius(4)

                    }

                    .width('100%')
                    .padding({ left: 8, right: 8, top: 130 })

                    Column() {
                      Text(item.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                        .margin({ top:4,bottom: 4 })
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(item.subtitle)
                        .fontSize(10)
                        .fontColor('#E0E0E0')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .padding({ left: 12, right: 12, bottom: 12 })
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                    .alignSelf(ItemAlign.End)
                  }
                  .height(160)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })
                }
              }, (item: ActivityItem) => item.id.toString())
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
      }
      .layoutWeight(1)
      // .edgeEffect(EdgeEffect.Spring)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}