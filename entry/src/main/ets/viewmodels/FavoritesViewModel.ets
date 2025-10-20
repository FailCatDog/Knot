import { getMyFavorites, Post, MyFavoritesResponse } from '../services/api/UserApi'
import { ToastUtil } from '../common/utils/ToastUtil'

@Observed
export class FavoritesViewModel {
  favorites: Post[] = []
  isLoading: boolean = false
  hasMore: boolean = true
  currentPage: number = 1
  total: number = 0
  totalPages: number = 0

  // 加载收藏列表
  async loadFavorites(refresh: boolean = false): Promise<void> {
    if (this.isLoading || (!refresh && !this.hasMore)) {
      return
    }

    this.isLoading = true

    try {
      const page = refresh ? 1 : this.currentPage
      const response = await getMyFavorites({ page: page, page_size: 20 })

      if (response.success && response.data) {
        if (refresh) {
          this.favorites = response.data.posts
          this.currentPage = 1
        } else {
          this.favorites = [...this.favorites, ...response.data.posts]
        }

        this.total = response.data.total
        this.totalPages = response.data.total_pages
        this.currentPage = response.data.page + 1
        this.hasMore = this.favorites.length < this.total
      } else {
        ToastUtil.getInstance().showWithBottom(response.message || '加载失败', 2000, 100)
      }
    } catch (error) {
      console.error('[FavoritesViewModel] 加载收藏列表失败:', error)
      ToastUtil.getInstance().showWithBottom('网络请求失败', 2000, 100)
    } finally {
      this.isLoading = false
    }
  }

  // 刷新收藏列表
  async refreshFavorites(): Promise<void> {
    await this.loadFavorites(true)
  }

  // 加载更多
  async loadMore(): Promise<void> {
    await this.loadFavorites(false)
  }

  // 获取收藏总数
  getTotalCount(): number {
    return this.total
  }

  // 检查是否有收藏
  hasFavorites(): boolean {
    return this.favorites.length > 0
  }
}

