import { getCurrentUserInfo, UserInfo, getUserPosts, Post, UserPostsResponse } from '../services/api/UserApi'
import { TokenManager } from '../services/TokenManager'
import { ImageItem } from '../views/components/ImageCard'

@Observed
export class ProfileViewModel {
  // 用户信息相关
  isUserLoggedIn: boolean = false
  userInfo: UserInfo = {
    id: 0,
    user_id: '',
    username: '',
    email: '',
    phone: '',
    real_name: '',
    avatar_url: '',
    bio: '',
    location: '',
    gender: '',
    role: '',
    status: '',
    create_time: 0,
    update_time: 0,
    device_count: 0
  }
  isLoading: boolean = true

  // 作品相关状态
  workLikedItems: Set<string> = new Set()
  workLikeCounts: Map<string, number> = new Map()
  workItems: ImageItem[] = []
  workPosts: Post[] = []
  workPage: number = 1
  workTotalCount: number = 0
  workLoading: boolean = false
  workHasMore: boolean = true

  // 收藏相关状态
  likeLikedItems: Set<string> = new Set()
  likeLikeCounts: Map<string, number> = new Map()
  likeItems: ImageItem[] = []

  // 检查用户登录状态
  async checkUserLoginStatus(): Promise<void> {
    this.isLoading = true

    try {
      const tokenManager = TokenManager.getInstance()
      const token = await tokenManager.getToken()

      if (token) {
        const response = await getCurrentUserInfo()
        if (response.success && response.data) {
          this.userInfo = response.data
          this.isUserLoggedIn = true
          
          // 登录后加载用户作品
          if (this.userInfo.id > 0) {
            await this.loadUserPosts(true)
          }
        } else {
          await tokenManager.clearToken()
          this.isUserLoggedIn = false
        }
      } else {
        this.isUserLoggedIn = false
      }
    } catch (error) {
      console.error('[ProfileViewModel] 检查用户登录状态失败:', error)
      this.isUserLoggedIn = false
    } finally {
      this.isLoading = false
    }
  }

  // 更新用户信息（用于登录后）
  updateUserInfo(userInfo: UserInfo): void {
    this.userInfo = userInfo
    this.isUserLoggedIn = true
    
    // 加载用户作品
    if (userInfo.id > 0) {
      this.loadUserPosts(true)
    }
  }

  // 退出登录
  logout(): void {
    this.isUserLoggedIn = false
    this.userInfo = {
      id: 0,
      user_id: '',
      username: '',
      email: '',
      phone: '',
      real_name: '',
      avatar_url: '',
      bio: '',
      location: '',
      gender: '',
      role: '',
      status: '',
      create_time: 0,
      update_time: 0,
      device_count: 0
    }
    this.workItems = []
    this.workPosts = []
    this.workPage = 1
    this.workTotalCount = 0
    this.workHasMore = true
  }

  // 将Post转换为ImageItem
  private postToImageItem(post: Post): ImageItem {
    const imageUrl: string = post.cover_image_url || 
      (post.images && post.images.length > 0 ? post.images[0].thumbnail_url : '')
    
    return {
      id: post.post_id,
      imageUrl: imageUrl,
      title: post.title,
      description: post.description,
      userAvatar: this.userInfo.avatar_url || $r('app.media.head'),
      userId: this.userInfo.username,
      likeCount: post.like_count,
      isLiked: false,
      imageHeight: 200
    }
  }

  // 加载用户帖子
  async loadUserPosts(refresh: boolean = false): Promise<void> {
    if (this.workLoading || (!refresh && !this.workHasMore)) {
      return
    }

    this.workLoading = true

    try {
      const page: number = refresh ? 1 : this.workPage
      const response = await getUserPosts({
        user_id: this.userInfo.id,
        page: page,
        pageSize: 20
      })

      if (response.success && response.data) {
        const data: UserPostsResponse = response.data
        const posts: Post[] = data.posts
        const total: number = data.total
        const currentPage: number = data.page
        
        if (refresh) {
          this.workPosts = posts
          this.workItems = posts.map(post => this.postToImageItem(post))
          this.workPage = 1
        } else {
          this.workPosts = [...this.workPosts, ...posts]
          this.workItems = [...this.workItems, ...posts.map(post => this.postToImageItem(post))]
        }
        
        this.workTotalCount = total
        this.workPage = currentPage + 1
        this.workHasMore = this.workPosts.length < total
      }
    } catch (error) {
      console.error('[ProfileViewModel] 加载用户帖子失败:', error)
    } finally {
      this.workLoading = false
    }
  }

  // 点赞作品
  handleWorkLikeClick(id: string): void {
    const currentCount: number = this.getWorkItemLikeCount(id)
    const isCurrentlyLiked: boolean = this.isWorkItemLiked(id)

    if (isCurrentlyLiked) {
      this.workLikedItems.delete(id)
      this.workLikeCounts.set(id, currentCount - 1)
    } else {
      this.workLikedItems.add(id)
      this.workLikeCounts.set(id, currentCount + 1)
    }
  }

  // 点赞收藏
  handleLikeLikeClick(id: string): void {
    const currentCount: number = this.getLikeItemLikeCount(id)
    const isCurrentlyLiked: boolean = this.isLikeItemLiked(id)

    if (isCurrentlyLiked) {
      this.likeLikedItems.delete(id)
      this.likeLikeCounts.set(id, currentCount - 1)
    } else {
      this.likeLikedItems.add(id)
      this.likeLikeCounts.set(id, currentCount + 1)
    }
  }

  // 获取作品点赞状态
  isWorkItemLiked(id: string): boolean {
    return this.workLikedItems.has(id)
  }

  // 获取作品点赞数
  getWorkItemLikeCount(id: string): number {
    return this.workLikeCounts.get(id) || 0
  }

  // 获取收藏点赞状态
  isLikeItemLiked(id: string): boolean {
    return this.likeLikedItems.has(id)
  }

  // 获取收藏点赞数
  getLikeItemLikeCount(id: string): number {
    return this.likeLikeCounts.get(id) || 0
  }

  // 转换性别文本
  getGenderText(gender: string): string {
    switch (gender) {
      case 'male':
        return '男'
      case 'female':
        return '女'
      case 'other':
        return '其他'
      case 'prefer_not_to_say':
        return '保密'
      default:
        return gender
    }
  }
}

