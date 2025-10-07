import { ImageCard, ImageItem } from '../components/ImageCard'

@Component
export struct FollowPage {
  @State likedItems: Set<string> = new Set(['1', '3', '6', '8', '10'])
  @State likeCounts: Map<string, number> = new Map()
  @State imageList: ImageItem[] = [
    {
      id: '1',
      imageUrl: 'https://picsum.photos/280/350',
      title: '自然',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '青青草原',
      likeCount: 41,
      isLiked: false,
      imageHeight: 350
    },
    {
      id: '2',
      imageUrl: 'https://picsum.photos/280/160',
      title: '同人图鉴',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '青青草原',
      likeCount: 9,
      isLiked: true,
      imageHeight: 160
    },
    {
      id: '3',
      imageUrl: 'https://picsum.photos/280/280',
      title: '十几就行了',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'vivo影像',
      likeCount: 89,
      isLiked: false,
      imageHeight: 280
    },
    {
      id: '4',
      imageUrl: 'https://picsum.photos/280/140',
      title: 'City&City',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'vivo影像',
      likeCount: 167,
      isLiked: false,
      imageHeight: 140
    },
    {
      id: '5',
      imageUrl: 'https://picsum.photos/280/320',
      title: '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'vivo影像',
      likeCount: 203,
      isLiked: true,
      imageHeight: 320
    },
    {
      id: '6',
      imageUrl: 'https://picsum.photos/280/240',
      title: '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'pet_lover',
      likeCount: 145,
      isLiked: false,
      imageHeight: 240
    },
    {
      id: '7',
      imageUrl: 'https://picsum.photos/280/180',
      title: '美食日记',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '美食达人',
      likeCount: 89,
      isLiked: false,
      imageHeight: 120
    },
    {
      id: '8',
      imageUrl: 'https://picsum.photos/280/380',
      title: '旅行记录',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '旅行者',
      likeCount: 156,
      isLiked: true,
      imageHeight: 380
    },
    {
      id: '9',
      imageUrl: 'https://picsum.photos/280/150',
      title: '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '摄影师小王',
      likeCount: 78,
      isLiked: false,
      imageHeight: 150
    },
    {
      id: '10',
      imageUrl: 'https://picsum.photos/280/400',
      title: '城市印象',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '城市探索者',
      likeCount: 234,
      isLiked: false,
      imageHeight: 400
    },
    {
      id: '11',
      imageUrl: 'https://picsum.photos/280/170',
      title: '手工制作',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '手工爱好者',
      likeCount: 67,
      isLiked: true,
      imageHeight: 130
    },
    {
      id: '12',
      imageUrl: 'https://picsum.photos/280/360',
      title: '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '艺术家',
      likeCount: 189,
      isLiked: false,
      imageHeight: 360
    },
    {
      id: '13',
      imageUrl: 'https://picsum.photos/280/180',
      title: '生活随拍',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '生活记录者',
      likeCount: 123,
      isLiked: false,
      imageHeight: 180
    },
    {
      id: '14',
      imageUrl: 'https://picsum.photos/280/420',
      title: '运动时刻',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '运动达人',
      likeCount: 98,
      isLiked: true,
      imageHeight: 420
    },
    {
      id: '15',
      imageUrl: 'https://picsum.photos/280/110',
      title: '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '设计师',
      likeCount: 145,
      isLiked: false,
      imageHeight: 110
    },
    {
      id: '16',
      imageUrl: 'https://picsum.photos/280/340',
      title: '夜景摄影',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '夜拍专家',
      likeCount: 267,
      isLiked: false,
      imageHeight: 340
    }
  ]

  aboutToAppear(): void {
    this.imageList.forEach(item => {
      this.likeCounts.set(item.id, item.likeCount)
    })
  }

  isItemLiked(id: string): boolean {
    return this.likedItems.has(id)
  }

  getItemLikeCount(id: string): number {
    return this.likeCounts.get(id) || 0
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

  @Builder
  buildHeader() {
    Row() {
      Text('关注')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Blank()

      Button('搜索')
        .fontSize(14)
        .backgroundColor('#E0E0E0')
        .fontColor('#666666')
        .height(32)
        .borderRadius(16)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildContent() {
    Scroll() {
      WaterFlow() {
        ForEach(this.imageList, (item: ImageItem, index: number) => {
          FlowItem() {
            ImageCard({
              item: {
                id: item.id,
                imageUrl: item.imageUrl,
                title: item.title,
                userAvatar: item.userAvatar,
                userId: item.userId,
                likeCount: this.getItemLikeCount(item.id),
                isLiked: this.isItemLiked(item.id),
                imageHeight: item.imageHeight
              },
              onLikeClick: (id: string) => {
                this.handleLikeClick(id)
              }
            })
          }
        })
      }
      .columnsTemplate('1fr')
      .rowsGap(20)
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
  }

  handleLikeClick(id: string): void {
    const currentCount = this.getItemLikeCount(id)
    const isCurrentlyLiked = this.isItemLiked(id)

    if (isCurrentlyLiked) {
      this.likedItems.delete(id)
      this.likeCounts.set(id, currentCount - 1)
    } else {
      this.likedItems.add(id)
      this.likeCounts.set(id, currentCount + 1)
    }
  }
}


