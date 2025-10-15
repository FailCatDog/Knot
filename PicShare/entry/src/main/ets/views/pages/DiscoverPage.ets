// pages/DiscoverPage.ets
import router from '@ohos.router'
import { ImageCard, ImageItem } from '../components/ImageCard'

@Component
export struct DiscoverPage {
  @State likedItems: Set<string> = new Set(['2', '5', '8', '11', '14'])
  @State likeCounts: Map<string, number> = new Map()
  @State imageList: ImageItem[] = [
    {
      id: '1',
      imageUrl: 'https://picsum.photos/280/350',
      title: '自然',
      description: '这是一张在山间拍摄的美丽风景照片，展现了大自然的壮丽景色。清晨的阳光透过云层洒向大地，形成了绝美的光影效果。',
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
      description: '精心收集的同人作品，每一张都充满了创作者的用心和热情。这些作品展现了不同的艺术风格和创意理念。',
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
      description: '简单的生活哲学，有时候不需要太多，十几就够了。在这个物欲横流的时代，学会知足常乐是一种智慧。',
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
      description: '城市与城市之间的对话，每个城市都有自己独特的魅力和故事。这张照片捕捉了都市建筑的几何美感。',
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
      description: '分享生活中的美好瞬间，记录每一个值得纪念的时刻。有时候无需言语，一张照片就能表达所有的情感。',
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
      description: '生活中处处都有美好，只要用心去发现。这个瞬间让我觉得特别有意思，想要与大家分享。',
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
      description: '记录每一道美味，分享制作的快乐和品尝的幸福。美食不仅要好吃，更要好看，每一道菜都是艺术品。',
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
      description: '旅行的意义不在于目的地，而在于路上的风景和心情。这次旅行让我收获满满，遇见了很多美好。',
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
      description: '随手拍下的这个瞬间，没有特别的故事，但就是觉得很美好。生活就是由这些小美好组成的。',
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
      description: '每个城市都有自己独特的魅力和故事，这张照片展现了现代都市的繁华与活力，钢筋水泥中也有诗意。',
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
      description: '手工制作需要耐心和技巧，每一个细节都体现了匠人的用心。这件作品花费了我整整一周的时间才完成。',
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
      description: '艺术来源于生活，又高于生活。这个作品想要表达的是内心深处的那份宁静与美好。',
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
      description: '生活中处处都有美好，只要用心去发现。今天随手拍下的这个瞬间，觉得特别有意思。',
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
      description: '运动带来的不仅是健康，更是积极向上的生活态度。每一次挥汗如雨都是对自己的超越。',
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
      description: '设计是一种语言，用视觉传达思想和情感。这个作品想要表达的是简约而不简单的美学理念。',
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
      description: '夜晚的城市总是充满魅力，霓虹灯闪烁，车流如织。这张照片捕捉了都市夜生活的精彩瞬间。',
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
    Column() {
      // 状态栏区域
      Row()
        .width('100%')
        .height(24)
        .backgroundColor('#F5F5F5')

      // 标题和搜索
      Row() {
        Text('发现')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Blank()

        // 搜索按钮
        Row() {
          Image($r('app.media.ic_search'))
            .width(20)
            .height(20)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildContent(): void {
    WaterFlow() {
      ForEach(this.imageList, (item: ImageItem, index: number) => {
        FlowItem() {
          ImageCard({
            item: {
              id: item.id,
              imageUrl: item.imageUrl,
              title: item.title,
              description: item.description,
              userAvatar: item.userAvatar,
              userId: item.userId,
              likeCount: this.getItemLikeCount(item.id),
              isLiked: this.isItemLiked(item.id),
              imageHeight: item.imageHeight
            },
            onLikeClick: (id: string) => this.handleLikeClick(id),
            onCardClick: (id: string) => this.handleCardClick(id)
          })
        }
        .width('100%')
        .constraintSize({
          /** 限制最大宽度，加强容器宽度约束是确保图片不会超出容器宽度的关键
           *  图片容器宽度继承错误会导致超出父容器，缺乏最大宽度限制内容会无线拓展
           */
          maxWidth: '100%',
          minWidth: 0
        })
        .margin({ right: 5 }) // 列间距
      })
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(8)
    .rowsGap(10)
    .padding({ left: 8, right: 8, top: 8, bottom: 16 })
    .width('100%')
    .layoutWeight(1)
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

  handleFollowClick(id: string): void {
    console.log(`关注用户: ${id}`)
  }

  handleCardClick(id: string): void {
    const item = this.imageList.find(item => item.id === id)
    if (item) {
      router.pushUrl({
        url: 'pages/PostDetailPage',
        params: {
          postId: id,
          imageUrl: item.imageUrl,
          title: item.title,
          description: item.description,
          userAvatar: item.userAvatar,
          userId: item.userId,
          likeCount: this.getItemLikeCount(id),
          isLiked: this.isItemLiked(id),
          imageHeight: item.imageHeight
        }
      }).catch((error: Error) => {
        console.error('Navigation failed:', error.message)
      })
    }
  }
}