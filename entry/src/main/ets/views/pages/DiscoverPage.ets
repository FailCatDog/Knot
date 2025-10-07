// pages/DiscoverPage.ets
import { ImageCard, ImageItem } from '../components/ImageCard'

@Component
export struct DiscoverPage {
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
            item: item,
            onLikeClick: (id: string) => this.handleLikeClick(id),
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
    const index = this.imageList.findIndex(item => item.id === id)
    if (index !== -1) {
      this.imageList[index].isLiked = !this.imageList[index].isLiked
      this.imageList[index].likeCount += this.imageList[index].isLiked ? 1 : -1
      this.imageList = [...this.imageList]
    }
  }
}