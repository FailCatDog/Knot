import { PostDetailEntity } from '../models/entities/PostDetailEntity'
import { getPostDetail, type PostEntity } from '../services/api/PostApi'
import promptAction from '@ohos.promptAction'

export class PostDetailViewModel {
  postDetail: PostDetailEntity | null = null
  isLoading: boolean = false

  async loadPostDetail(postId: string): Promise<void> {
    if (this.isLoading) return

    console.log('[PostDetailViewModel] 开始加载帖子详情:', postId)
    this.isLoading = true

    const response = await getPostDetail(postId)

    console.log('[PostDetailViewModel] 响应结果:', JSON.stringify(response))

    if (response.success && response.data) {
      const post = response.data.post
      this.postDetail = this.convertPostToDetail(post)
      console.log('[PostDetailViewModel] 加载成功')
    } else {
      console.log('[PostDetailViewModel] 加载失败:', response.message)
      this.showError(response.message || '加载失败')
    }

    this.isLoading = false
  }

  private convertPostToDetail(post: PostEntity): PostDetailEntity {
    const imageUrls = post.images ? post.images.map(img => img.file_url) : []
    const publishDate = post.create_time ? post.create_time.split(' ')[0] : ''
    
    return {
      id: post.post_id,
      imageUrls: imageUrls,
      title: post.title,
      description: post.description || '',
      userAvatar: 'https://picsum.photos/60/60',
      userId: `用户${post.user_id}`,
      userName: `用户${post.user_id}`,
      publishDate: publishDate,
      likeCount: post.like_count,
      isLiked: false
    }
  }

  toggleLike(): void {
    if (this.postDetail) {
      this.postDetail.isLiked = !this.postDetail.isLiked
      this.postDetail.likeCount += this.postDetail.isLiked ? 1 : -1
    }
  }

  getCurrentPost(): PostDetailEntity | null {
    return this.postDetail
  }

  private showError(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: 100
    })
  }
}
