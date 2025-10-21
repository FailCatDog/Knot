import { ImageCard, ImageItem } from '../components/ImageCard'
import { FavoritesViewModel } from '../../viewmodels/FavoritesViewModel'
import { Post } from '../../services/api/UserApi'
import { PostDetailParam } from '../../services/api/PostApi'

@Builder
export function FavoritesPageBuilder() {
  FavoritesPage()
}

@Component
export struct FavoritesPage {
  @Consume('NavPathStack') pathStack: NavPathStack
  @State viewModel: FavoritesViewModel = new FavoritesViewModel()
  @State favoriteItems: ImageItem[] = []

  aboutToAppear(): void {
    // 每次页面显示时重新加载收藏（确保数据最新）
    this.loadFavorites(true)
  }

  async loadFavorites(refresh: boolean): Promise<void> {
    if (refresh) {
      await this.viewModel.refreshFavorites()
    } else {
      await this.viewModel.loadMore()
    }
    this.updateFavoriteItems()
  }

  updateFavoriteItems(): void {
    this.favoriteItems = this.viewModel.favorites.map((post: Post) => this.postToImageItem(post))
  }

  private postToImageItem(post: Post): ImageItem {
    const imageUrl: string = post.cover_image_url || 
      (post.images && post.images.length > 0 ? post.images[0].thumbnail_url : '')
    
    return {
      id: post.post_id,
      imageUrl: imageUrl,
      title: post.title,
      description: post.description,
      userAvatar: post.author?.avatar_url || post.avatar_url || $r('app.media.head'),
      userId: post.author?.username || post.username || `用户${post.user_id}`,
      likeCount: post.like_count,
      isLiked: false,
      imageHeight: 200
    }
  }

  // 处理卡片点击
  handleCardClick(id: string): void {
    const item = this.favoriteItems.find(item => item.id === id)
    const userAvatar = typeof item?.userAvatar === 'string' ? item.userAvatar : undefined
    const param: PostDetailParam = {
      post_id: id,
      user_avatar: userAvatar,
      user_name: item?.userId
    }
    this.pathStack.pushPathByName('PostDetailPage', param, false)
  }

  build() {
    NavDestination() {
      Column() {
        // 标题栏
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
            .onClick(() => {
              this.pathStack.pop()
            })

          Text('我的收藏')
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })

          Blank()

          Text(`共${this.viewModel.getTotalCount()}个`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')

        // 内容区域
        if (this.viewModel.isLoading && this.favoriteItems.length === 0) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .margin({ bottom: 16 })
            
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else if (this.favoriteItems.length === 0) {
          Column() {
            Image($r('app.media.ic_discover'))
              .width(80)
              .height(80)
              .fillColor('#CCCCCC')
              .margin({ bottom: 16 })

            Text('还没有收藏哦')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Refresh({ refreshing: this.viewModel.isLoading && this.favoriteItems.length > 0 }) {
            WaterFlow() {
              ForEach(this.favoriteItems, (item: ImageItem) => {
                FlowItem() {
                  ImageCard({
                    item: item,
                    onLikeClick: (id: string) => {
                      // 点赞功能
                    },
                    onCardClick: (id: string) => this.handleCardClick(id)
                  })
                }
                .width('100%')
                .constraintSize({
                  maxWidth: '100%',
                  minWidth: 0
                })
              })

              if (this.viewModel.hasMore || this.viewModel.isLoading) {
                FlowItem() {
                  Column() {
                    if (this.viewModel.isLoading) {
                      LoadingProgress()
                        .width(24)
                        .height(24)
                        .margin({ bottom: 8 })
                      Text('加载中...')
                        .fontSize(12)
                        .fontColor('#999999')
                    } else {
                      Text('点击加载更多')
                        .fontSize(12)
                        .fontColor('#666666')
                        .padding(8)
                    }
                  }
                  .width('100%')
                  .height(60)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    if (!this.viewModel.isLoading && this.viewModel.hasMore) {
                      this.loadFavorites(false)
                    }
                  })
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
                this.loadFavorites(false)
              }
            })
          }
          .onRefreshing(() => {
            this.loadFavorites(true)
          })
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
    }
    .hideTitleBar(true)
  }
}



