import { getPosts, type PostEntity } from '../services/api/PostApi';
import { ToastUtil } from '../common/utils/ToastUtil';

@Observed
export class DiscoverViewModel {
  posts: PostEntity[] = [];
  currentPage: number = 1;
  pageSize: number = 20;
  total: number = 0;
  isLoading: boolean = false;
  hasMore: boolean = true;

  async loadPosts(isRefresh: boolean = false): Promise<void> {
    if (this.isLoading) {
      console.log('[DiscoverViewModel] 正在加载中，跳过');
      return;
    }

    if (isRefresh) {
      this.currentPage = 1;
      this.hasMore = true;
    }

    if (!this.hasMore) {
      console.log('[DiscoverViewModel] 没有更多数据');
      return;
    }

    console.log('[DiscoverViewModel] 开始加载数据，页码:', this.currentPage);
    this.isLoading = true;

    try {
      const response = await getPosts(this.currentPage, this.pageSize);

      console.log('[DiscoverViewModel] 响应结果:', JSON.stringify(response));

      if (response.success && response.data) {
        const newPosts: PostEntity[] = response.data.posts;
        this.total = response.data.total;

        if (isRefresh) {
          this.posts = newPosts;
        } else {
          // 使用数组拷贝而不是展开运算符
          const updatedPosts: PostEntity[] = [];
          for (let i = 0; i < this.posts.length; i++) {
            updatedPosts.push(this.posts[i]);
          }
          for (let i = 0; i < newPosts.length; i++) {
            updatedPosts.push(newPosts[i]);
          }
          this.posts = updatedPosts;
        }

        this.hasMore = this.posts.length < this.total;
        this.currentPage += 1;

        console.log('[DiscoverViewModel] 加载成功，当前帖子数:', this.posts.length, '总数:', this.total);
      } else {
        console.log('[DiscoverViewModel] 加载失败:', response.message);
        this.showError(response.message || '加载失败');
      }
    } catch (error) {
      console.error('[DiscoverViewModel] 加载异常:', error);
      this.showError('加载失败：' + (error as Error).message);
    } finally {
      this.isLoading = false;
    }
  }

  private showError(message: string): void {
    ToastUtil.getInstance().showWithBottom(message, 2000, 100);
  }
}

