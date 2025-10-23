import { getCurrentUserInfo, UserInfo, getUserPosts, Post, UserPostsResponse, getMyFavorites, MyFavoritesResponse, getUserPublicInfo, UserPublicInfo } from '../services/api/UserApi'
import { getPostDetail, likePost, unlikePost, LikePostData } from '../services/api/PostApi'
import { TokenManager } from '../services/TokenManager'
import { ImageItem } from '../views/components/ImageCard'
import { ApiResponse } from '../services/api/HttpRequest'

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
  isLoading: boolean = false

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
  likePosts: Post[] = []
  likePage: number = 1
  likeTotalCount: number = 0
  likeLoading: boolean = false
  likeHasMore: boolean = true
  
  // 用户信息缓存
  userInfoCache: Map<string, UserPublicInfo> = new Map()

  // 检查用户登录状态
  async checkUserLoginStatus(): Promise<void> {
    console.log('[ProfileViewModel] ========== 开始检查用户登录状态 ==========')
    console.log('[ProfileViewModel] 检查前状态 - isUserLoggedIn:', this.isUserLoggedIn, 'isLoading:', this.isLoading)
    this.isLoading = true

    try {
      const tokenManager = TokenManager.getInstance()
      const token = await tokenManager.getToken()
      console.log('[ProfileViewModel] Token 状态:', token ? '存在' : '不存在')

      if (token) {
        console.log('[ProfileViewModel] 调用 getCurrentUserInfo...')
        const response = await getCurrentUserInfo()
        console.log('[ProfileViewModel] API 响应:', response.success ? '成功' : '失败')
        
        if (response.success && response.data) {
          this.userInfo = response.data
          this.isUserLoggedIn = true
          console.log('[ProfileViewModel] 用户已登录，用户名:', this.userInfo.username)
          
          // 登录后加载用户作品和收藏
          if (this.userInfo.id > 0) {
            await this.loadUserPosts(true)
            await this.loadUserFavorites(true)
          }
        } else {
          console.log('[ProfileViewModel] 获取用户信息失败，清除 token')
          await tokenManager.clearToken()
          this.isUserLoggedIn = false
        }
      } else {
        console.log('[ProfileViewModel] 未找到 token，设置为未登录')
        this.isUserLoggedIn = false
      }
    } catch (error) {
      console.error('[ProfileViewModel] 检查用户登录状态失败:', error)
      this.isUserLoggedIn = false
    } finally {
      this.isLoading = false
      console.log('[ProfileViewModel] 检查完成 - isUserLoggedIn:', this.isUserLoggedIn, 'isLoading:', this.isLoading)
      console.log('[ProfileViewModel] ========== 检查用户登录状态结束 ==========')
    }
  }

  // 更新用户信息（用于登录后）
  updateUserInfo(userInfo: UserInfo): void {
    this.userInfo = userInfo
    this.isUserLoggedIn = true
    
    // 加载用户作品和收藏
    if (userInfo.id > 0) {
      this.loadUserPosts(true)
      this.loadUserFavorites(true)
    }
  }

  async logout(): Promise<void> {
    const tokenManager = TokenManager.getInstance()
    await tokenManager.clearToken()
    
    this.isUserLoggedIn = false
    this.isLoading = false  // 确保退出后不显示加载状态
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
    
    // 清空作品相关数据
    this.workItems = []
    this.workPosts = []
    this.workPage = 1
    this.workTotalCount = 0
    this.workHasMore = true
    this.workLikedItems.clear()
    this.workLikeCounts.clear()
    
    // 清空收藏相关数据
    this.likeItems = []
    this.likePosts = []
    this.likePage = 1
    this.likeTotalCount = 0
    this.likeHasMore = true
    this.likeLikedItems.clear()
    this.likeLikeCounts.clear()
    
    // 清空用户信息缓存
    this.userInfoCache.clear()
  }

  // 将Post转换为ImageItem
  private postToImageItem(post: Post, isCurrentUser: boolean = true): ImageItem {
    const firstImage = post.images && post.images.length > 0 ? post.images[0] : null
    const imageUrl: string = firstImage?.file_url || post.cover_image_url || ''
    
    // 根据是作品还是收藏，使用不同的状态管理
    const isLiked: boolean = isCurrentUser 
      ? (this.workLikedItems.has(post.post_id) ? this.isWorkItemLiked(post.post_id) : post.has_liked)
      : (this.likeLikedItems.has(post.post_id) ? this.isLikeItemLiked(post.post_id) : post.has_liked)
    
    const likeCount: number = isCurrentUser
      ? (this.workLikeCounts.has(post.post_id) ? this.getWorkItemLikeCount(post.post_id) : post.like_count)
      : (this.likeLikeCounts.has(post.post_id) ? this.getLikeItemLikeCount(post.post_id) : post.like_count)
    
    // 如果后端返回已点赞，初始化到本地状态
    if (post.has_liked) {
      if (isCurrentUser) {
        this.workLikedItems.add(post.post_id)
      } else {
        this.likeLikedItems.add(post.post_id)
      }
    }
    
    // 优先使用帖子中的作者信息，否则使用当前用户信息（仅作品）或默认值（收藏）
    const userAvatar = post.author?.avatar_url || post.avatar_url || 
      (isCurrentUser ? this.userInfo.avatar_url : '') || $r('app.media.head')
    const userName = post.author?.username || post.username || 
      (isCurrentUser ? this.userInfo.username : `用户${post.user_id}`)
    
    return {
      id: post.post_id,
      imageUrl: imageUrl,
      title: post.title,
      description: post.description,
      userAvatar: userAvatar,
      userId: userName,
      likeCount: likeCount,
      isLiked: isLiked,
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
  async handleWorkLikeClick(id: string): Promise<ApiResponse<LikePostData>> {
    const isCurrentlyLiked: boolean = this.isWorkItemLiked(id)
    const response: ApiResponse<LikePostData> = isCurrentlyLiked ? await unlikePost(id) : await likePost(id)

    if (response.success && response.data) {
      if (response.data.has_liked) {
        this.workLikedItems.add(id)
      } else {
        this.workLikedItems.delete(id)
      }
      this.workLikeCounts.set(id, response.data.like_count)
    }
    
    return response
  }

  // 点赞收藏
  async handleLikeLikeClick(id: string): Promise<ApiResponse<LikePostData>> {
    const isCurrentlyLiked: boolean = this.isLikeItemLiked(id)
    const response: ApiResponse<LikePostData> = isCurrentlyLiked ? await unlikePost(id) : await likePost(id)

    if (response.success && response.data) {
      if (response.data.has_liked) {
        this.likeLikedItems.add(id)
      } else {
        this.likeLikedItems.delete(id)
      }
      this.likeLikeCounts.set(id, response.data.like_count)
    }
    
    return response
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

  // 清空用户信息缓存
  clearUserInfoCache(): void {
    console.log('[ProfileViewModel] 清空用户信息缓存')
    this.userInfoCache.clear()
  }

  // 获取用户公开信息（带缓存）
  private async getUserInfoWithCache(userId: string): Promise<UserPublicInfo | null> {
    console.log('[ProfileViewModel] getUserInfoWithCache 被调用, userId:', userId)
    
    // 先检查缓存
    if (this.userInfoCache.has(userId)) {
      console.log('[ProfileViewModel] 从缓存获取用户信息')
      return this.userInfoCache.get(userId)!
    }

    try {
      console.log('[ProfileViewModel] 开始调用 getUserPublicInfo API')
      const response = await getUserPublicInfo(userId)
      console.log('[ProfileViewModel] getUserPublicInfo 响应:', JSON.stringify(response))
      
      if (response.success && response.data) {
        const userInfo = response.data  // 直接使用 response.data，不是 response.data.user
        console.log('[ProfileViewModel] 解析到的用户信息:', userInfo)
        this.userInfoCache.set(userId, userInfo)
        return userInfo
      } else {
        console.log('[ProfileViewModel] API调用失败:', response.message)
      }
    } catch (error) {
      console.error('[ProfileViewModel] 获取用户公开信息失败:', error)
    }
    
    return null
  }

  // 加载用户收藏列表
  async loadUserFavorites(refresh: boolean = false): Promise<void> {
    if (this.likeLoading || (!refresh && !this.likeHasMore)) {
      return
    }

    this.likeLoading = true

    try {
      const page = refresh ? 1 : this.likePage
      const response = await getMyFavorites({ page: page, page_size: 20 })

      if (response.success && response.data) {
        const posts = response.data.posts
        const total = response.data.total
        console.log('[ProfileViewModel] 收藏列表数据:', posts.length > 0 ? JSON.stringify(posts[0]) : '无数据')
        
        // 处理每个收藏帖子，获取完整信息
        const processedItems: ImageItem[] = []
        for (const post of posts) {
          try {
            // 1. 通过post_id获取帖子详情
            const postDetailResponse = await getPostDetail(post.post_id)
            if (postDetailResponse.success && postDetailResponse.data) {
              const postDetail = postDetailResponse.data.post
              console.log('[ProfileViewModel] 收藏列表原始 has_liked:', post.has_liked, 'like_count:', post.like_count)
              console.log('[ProfileViewModel] 帖子详情 has_liked:', postDetail.has_liked, 'like_count:', postDetail.like_count)
              
              // 如果帖子详情没有has_liked，使用收藏列表中的has_liked
              if (postDetail.has_liked === undefined && post.has_liked !== undefined) {
                postDetail.has_liked = post.has_liked
                console.log('[ProfileViewModel] 使用收藏列表的has_liked:', post.has_liked)
              }
              if (postDetail.like_count === undefined && post.like_count !== undefined) {
                postDetail.like_count = post.like_count
                console.log('[ProfileViewModel] 使用收藏列表的like_count:', post.like_count)
              }
              
              // 2. 通过user_id获取用户公开信息
              let username = `用户${postDetail.user_id}`
              let userAvatar = ''
              console.log('[ProfileViewModel] 帖子详情 user_id:', postDetail.user_id, '类型:', typeof postDetail.user_id)
              
              // 先尝试从post.author获取用户信息
              if (postDetail.author) {
                username = postDetail.author.username || postDetail.username || username
                userAvatar = postDetail.author.avatar_url || ''
                console.log('[ProfileViewModel] 从post.author获取用户信息 - 用户名:', username, ', 头像:', userAvatar)
              } else if (postDetail.user_id) {
                // 如果没有author，通过getUserPublicInfo获取
                const userIdStr = String(postDetail.user_id)
                console.log('[ProfileViewModel] 准备获取用户信息, userId:', userIdStr)
                
                const userInfo = await this.getUserInfoWithCache(userIdStr)
                console.log('[ProfileViewModel] 获取到的用户信息:', userInfo)
                
                if (userInfo) {
                  username = userInfo.username
                  userAvatar = userInfo.avatar_url || ''
                  console.log('[ProfileViewModel] 最终用户名:', username, ', 头像:', userAvatar)
                } else {
                  console.log('[ProfileViewModel] 获取用户信息失败，使用默认用户名')
                }
              }
              
              // 3. 创建ImageItem
              const firstImage = postDetail.images && postDetail.images.length > 0 ? postDetail.images[0] : null
              const imageUrl: string = firstImage?.file_url || ''
              
              // 先初始化ViewModel的点赞状态（必须在计算isLiked之前）
              if (postDetail.has_liked && !this.likeLikedItems.has(postDetail.post_id)) {
                this.likeLikedItems.add(postDetail.post_id)
                console.log('[ProfileViewModel] 收藏帖子已点赞:', postDetail.post_id, 'has_liked:', postDetail.has_liked)
              }
              if (!this.likeLikeCounts.has(postDetail.post_id)) {
                this.likeLikeCounts.set(postDetail.post_id, postDetail.like_count)
              }
              
              // 然后计算点赞状态
              const isLiked: boolean = this.likeLikedItems.has(postDetail.post_id) ? this.isLikeItemLiked(postDetail.post_id) : postDetail.has_liked
              const likeCount: number = this.likeLikeCounts.has(postDetail.post_id) ? this.getLikeItemLikeCount(postDetail.post_id) : postDetail.like_count
              
              console.log('[ProfileViewModel] 创建收藏ImageItem - post_id:', postDetail.post_id, 'isLiked:', isLiked, 'likeCount:', likeCount, 'has_liked:', postDetail.has_liked)
              
              const imageItem: ImageItem = {
                id: postDetail.post_id,
                imageUrl: imageUrl,
                title: postDetail.title,
                description: postDetail.description || '',
                userAvatar: userAvatar && userAvatar.trim() !== '' ? userAvatar : $r('app.media.head'),
                userId: username,
                likeCount: likeCount,
                isLiked: isLiked,
                imageHeight: 200
              }
              
              processedItems.push(imageItem)
            }
          } catch (error) {
            console.error('[ProfileViewModel] 处理收藏帖子失败:', post.post_id, error)
            // 如果获取详情失败，使用原始数据
            processedItems.push(this.postToImageItem(post, false))
          }
        }
        
        if (refresh) {
          this.likePosts = posts
          this.likeItems = processedItems
          this.likePage = 1
        } else {
          this.likePosts = [...this.likePosts, ...posts]
          this.likeItems = [...this.likeItems, ...processedItems]
        }
        
        this.likeTotalCount = total
        this.likePage = response.data.page + 1
        this.likeHasMore = this.likePosts.length < total
      }
    } catch (error) {
      console.error('[ProfileViewModel] 加载用户收藏失败:', error)
    } finally {
      this.likeLoading = false
    }
  }
}

