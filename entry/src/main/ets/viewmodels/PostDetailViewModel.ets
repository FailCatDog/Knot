import { PostDetailEntity } from '../models/entities/PostDetailEntity'

export class PostDetailViewModel {
  private postDetail: PostDetailEntity | null = null

  setPostDetail(data: PostDetailEntity): void {
    this.postDetail = data
  }

  getPostDetail(id: string): PostDetailEntity | null {
    if (this.postDetail && this.postDetail.id === id) {
      return this.postDetail
    }
    const mockData: PostDetailEntity = {
      id: id,
      imageUrl: `https://picsum.photos/400/600?random=${id}`,
      title: this.getMockTitle(id),
      description: this.getMockDescription(id),
      userAvatar: 'https://picsum.photos/60/60',
      userId: this.getMockUserId(id),
      userName: this.getMockUserName(id),
      publishDate: this.getMockDate(id),
      likeCount: Math.floor(Math.random() * 500) + 50,
      isLiked: Math.random() > 0.5
    }
    this.postDetail = mockData
    return this.postDetail
  }

  private getMockTitle(id: string): string {
    const titles = [
      '美丽的自然风光',
      '城市夜景摄影',
      '手工艺术作品',
      '美食制作过程',
      '旅行记录分享',
      '生活随拍瞬间'
    ]
    return titles[parseInt(id) % titles.length] || '精彩内容分享'
  }

  private getMockDescription(id: string): string {
    const descriptions = [
      '这是一张在山间拍摄的美丽风景照片，展现了大自然的壮丽景色。清晨的阳光透过云层洒向大地，形成了绝美的光影效果。',
      '夜晚的城市总是充满魅力，霓虹灯闪烁，车流如织。这张照片捕捉了都市夜生活的精彩瞬间。',
      '手工制作需要耐心和技巧，每一个细节都体现了匠人的用心。这件作品花费了我整整一周的时间才完成。',
      '美食不仅要好吃，更要好看。分享一下今天制作的精美料理，希望大家喜欢。',
      '旅行的意义不在于目的地，而在于路上的风景和心情。这次旅行让我收获满满。',
      '生活中处处都有美好，只要用心去发现。今天随手拍下的这个瞬间，觉得特别有意思。'
    ]
    return descriptions[parseInt(id) % descriptions.length] || '分享生活中的美好瞬间'
  }

  private getMockUserId(id: string): string {
    const userIds = ['青青草原', 'vivo影像', '摄影师小王', '美食达人', '旅行者', '艺术家']
    return userIds[parseInt(id) % userIds.length] || '用户'
  }

  private getMockUserName(id: string): string {
    return this.getMockUserId(id)
  }

  private getMockDate(id: string): string {
    const dates = [
      '2024-01-15',
      '2024-02-20',
      '2024-03-10',
      '2024-04-05',
      '2024-05-18',
      '2024-06-22'
    ]
    return dates[parseInt(id) % dates.length] || '2024-01-01'
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
}
