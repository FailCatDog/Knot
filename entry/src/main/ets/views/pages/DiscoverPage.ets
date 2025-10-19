import { ImageCard, ImageItem } from '../components/ImageCard'
import { DiscoverViewModel } from '../../viewmodels/DiscoverViewModel'
import { PostEntity, likePost, unlikePost } from '../../services/api/PostApi'
import { PostStateManager } from '../../common/utils/PostStateManager'
import { LoadingComponent } from '../components/LoadingComponent'

interface PostDetailNavParam {
  post_id: string
}


@Component
export struct DiscoverPage {
  @State viewModel: DiscoverViewModel = new DiscoverViewModel()
  @State likedItems: Set<string> = new Set()
  @State likeCounts: Map<string, number> = new Map()
  @State imageList: ImageItem[] = []
  @State isInitialLoading: boolean = true
  @Consume('NavPathStack') navPathStack: NavPathStack
  private scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    await this.loadInitialData()
  }

  onPageShow(): void {
    this.syncPostStates()
  }

  syncPostStates(): void {
    const postStateManager = PostStateManager.getInstance()
    this.imageList.forEach(item => {
      if (postStateManager.hasPostState(item.id)) {
        const state = postStateManager.getPostState(item.id)
        if (state) {
          if (state.isLiked) {
            this.likedItems.add(state.postId)
          } else {
            this.likedItems.delete(state.postId)
          }
          this.likeCounts.set(state.postId, state.likeCount)
          postStateManager.clearPostState(state.postId)
        }
      }
    })
  }

  async loadInitialData(): Promise<void> {
    this.isInitialLoading = true
    await this.viewModel.loadPosts(true)
    this.updateImageList()
    this.isInitialLoading = false
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
    const isLiked = this.likedItems.has(post.post_id) ? this.isItemLiked(post.post_id) : post.has_liked
    const likeCount = this.likeCounts.has(post.post_id) ? this.getItemLikeCount(post.post_id) : post.like_count
    
    if (post.has_liked && !this.likedItems.has(post.post_id)) {
      this.likedItems.add(post.post_id)
    }
    
    return {
      id: post.post_id,
      imageUrl: firstImage?.file_url || '',
      title: post.title,
      description: post.description || '',
      userAvatar: post.author?.avatar_url || post.avatar_url || 'https://picsum.photos/40/40',
      userId: post.author?.username || post.username || `用户${post.user_id}`,
      likeCount: likeCount,
      isLiked: isLiked,
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
      if (this.isInitialLoading) {
        LoadingComponent()
      } else {
        this.buildContent()
      }
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
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .onReachEnd(() => {
      if (this.viewModel.hasMore && !this.viewModel.isLoading) {
        this.loadMoreData()
      }
    })
  }

  async handleLikeClick(id: string): Promise<void> {
    const isCurrentlyLiked = this.isItemLiked(id)
    const response = isCurrentlyLiked ? await unlikePost(id) : await likePost(id)

    if (response.success && response.data) {
      if (response.data.has_liked) {
        this.likedItems.add(id)
      } else {
        this.likedItems.delete(id)
      }
      this.likeCounts.set(id, response.data.like_count)
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
    const param: PostDetailNavParam = { post_id: id }
    this.navPathStack.pushPathByName('PostDetailPage', param, false)
  }
}