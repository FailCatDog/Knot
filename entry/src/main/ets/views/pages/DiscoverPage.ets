import { ImageCard, ImageItem } from '../components/ImageCard'
import { DiscoverViewModel } from '../../viewmodels/DiscoverViewModel'
import { PostEntity } from '../../services/api/PostApi'

interface PostDetailParam {
  post_id: string
  user_id: number
  title: string
  description: string
  like_count: number
  create_time: string
  image_urls: string[]
}

@Component
export struct DiscoverPage {
  @State viewModel: DiscoverViewModel = new DiscoverViewModel()
  @State likedItems: Set<string> = new Set()
  @State likeCounts: Map<string, number> = new Map()
  @State imageList: ImageItem[] = []
  @Consume('NavPathStack') navPathStack: NavPathStack
  private scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    await this.loadInitialData()
  }

  async loadInitialData(): Promise<void> {
    await this.viewModel.loadPosts(true)
    this.updateImageList()
  }

  async loadMoreData(): Promise<void> {
    await this.viewModel.loadPosts(false)
    this.updateImageList()
  }

  updateImageList(): void {
    this.imageList = this.viewModel.posts.map((post: PostEntity) => this.convertPostToImageItem(post))
    this.imageList.forEach(item => {
      if (!this.likeCounts.has(item.id)) {
        this.likeCounts.set(item.id, item.likeCount)
      }
    })
  }

  convertPostToImageItem(post: PostEntity): ImageItem {
    const firstImage = post.images && post.images.length > 0 ? post.images[0] : null
    return {
      id: post.post_id,
      imageUrl: firstImage?.file_url || '',
      title: post.title,
      description: post.description || '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: `用户${post.user_id}`,
      likeCount: post.like_count,
      isLiked: this.likedItems.has(post.post_id),
      imageHeight: firstImage ? Math.min(Math.max(firstImage.height / firstImage.width * 280, 150), 420) : 280
    }
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
      Text('发现')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Blank()

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
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildContent(): void {
    WaterFlow({ scroller: this.scroller }) {
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
          maxWidth: '100%',
          minWidth: 0
        })
        .margin({ right: 5 })
      })

      if (this.viewModel.isLoading) {
        FlowItem() {
          Row() {
            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
      }
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(8)
    .rowsGap(10)
    .padding({ left: 8, right: 8, top: 8, bottom: 16 })
    .width('100%')
    .layoutWeight(1)
    .onReachEnd(() => {
      if (this.viewModel.hasMore && !this.viewModel.isLoading) {
        this.loadMoreData()
      }
    })
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

  // 将时间戳转换为日期字符串
  private formatTimestamp(timestamp: string | number): string {
    // 处理字符串或数字类型的时间戳
    const ts = typeof timestamp === 'string' ? parseInt(timestamp) : timestamp
    const date = new Date(ts * 1000) // 转换为毫秒
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
  }

  handleCardClick(id: string): void {
    const post = this.viewModel.posts.find(p => p.post_id === id)
    if (post) {
      const imageUrls = post.images ? post.images.map(img => img.file_url) : []
      const postData: PostDetailParam = {
        post_id: post.post_id,
        user_id: post.user_id,
        title: post.title,
        description: post.description || '',
        like_count: post.like_count,
        create_time: this.formatTimestamp(post.create_time),
        image_urls: imageUrls
      }
      this.navPathStack.pushPathByName('PostDetailPage', postData, false)
    }
  }
}