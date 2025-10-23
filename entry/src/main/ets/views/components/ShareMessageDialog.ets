import { ImageItem } from './ImageCard'

// 分享消息项
export interface ShareMessageItem {
  id: string
  friendAvatar: string
  friendName: string
  postId: string
  postCover: string
  postTitle: string
  shareTime: number
  // 帖子作者信息（真实的帖主）
  authorAvatar?: string
  authorName?: string
  // 是否已读
  isRead: boolean
  // 分享描述
  shareDescription?: string
}

@Component
export struct ShareMessageDialog {
  @Link showDialog: boolean
  @State messageItems: ShareMessageItem[] = []
  onPostClick?: (postId: string) => void

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showDialog = false
        })

      // 弹窗内容
      Column() {
        // 标题栏
        Row() {
          Text('好友分享')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Image($r('app.media.ic_close'))
            .width(20)
            .height(20)
            .fillColor('#666666')
            .onClick(() => {
              this.showDialog = false
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })

        Divider()
          .color('#F0F0F0')

        // 消息列表
        if (this.messageItems.length === 0) {
          Column() {
            Image($r('app.media.ic_discover'))
              .width(60)
              .height(60)
              .fillColor('#CCCCCC')
              .margin({ bottom: 12 })

            Text('暂无分享消息')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Scroll() {
            Column({ space: 0 }) {
              ForEach(this.messageItems, (item: ShareMessageItem, index: number) => {
                this.buildMessageItem(item, index)
              })
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .align(Alignment.Top)
          .padding({ top: 8, bottom: 8 })
        }
      }
      .width('85%')
      .height('65%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .clip(true)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildMessageItem(item: ShareMessageItem, index: number) {
    Column() {
      // 好友信息
      Row({ space: 10 }) {
        Image(item.friendAvatar)
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.head'))

        Column({ space: 2 }) {
          Text(item.friendName)
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)

          Text(this.formatTime(item.shareTime))
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 分享描述
      if (item.shareDescription && item.shareDescription.trim() !== '') {
        Text(item.shareDescription)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .margin({ top: 8, left: 16, right: 16 })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .width('92%')
      }

      // 分享的帖子卡片
      Row({ space: 10 }) {
        Image(item.postCover)
          .width(70)
          .height(70)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.ic_discover'))

        Column({ space: 4 }) {
          Row({ space: 6 }) {
            Text(item.postTitle)
              .fontSize(14)
              .fontColor('#333333')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(20)
              .layoutWeight(1)
            
            // 未读标记
            if (!item.isRead) {
              Text('NEW')
                .fontSize(10)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF0000')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .fontWeight(FontWeight.Bold)
            }
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)

          // 帖主信息
          if (item.authorAvatar || item.authorName) {
            Row({ space: 6 }) {
              if (item.authorAvatar) {
                Image(item.authorAvatar)
                  .width(16)
                  .height(16)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                  .alt($r('app.media.head'))
              }
              
              Text(item.authorName || '未知用户')
                .fontSize(12)
                .fontColor('#999999')
            }
            .alignItems(VerticalAlign.Center)
            .margin({ top: 4 })
          } else {
            Text('点击查看详情')
              .fontSize(12)
              .fontColor('#ffdd0223')
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 12 })
      .margin({ top: 8 })
      .backgroundColor('#F8F8F8')
      .borderRadius(8)
      .onClick(() => {
        if (this.onPostClick) {
          this.onPostClick(item.postId)
          // 由父组件 ProfilePage 处理关闭和恢复逻辑
        }
      })

      // 分隔线
      if (index < this.messageItems.length - 1) {
        Divider()
          .color('#F0F0F0')
          .margin({ top: 12, bottom: 12 })
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  // 格式化时间
  formatTime(timestamp: number): string {
    const now = Date.now()
    const diff = now - timestamp
    const minutes = Math.floor(diff / 60000)
    const hours = Math.floor(diff / 3600000)
    const days = Math.floor(diff / 86400000)

    if (minutes < 1) {
      return '刚刚'
    } else if (minutes < 60) {
      return `${minutes}分钟前`
    } else if (hours < 24) {
      return `${hours}小时前`
    } else if (days < 7) {
      return `${days}天前`
    } else {
      const date = new Date(timestamp)
      return `${date.getMonth() + 1}-${date.getDate()}`
    }
  }
}

