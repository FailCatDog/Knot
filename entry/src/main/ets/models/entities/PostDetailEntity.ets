export interface PostDetailEntity {
  postId: string
  imageUrls: string[]
  title: string
  description: string
  userAvatar: string
  userId: string
  userName: string
  publishDate: string
  likeCount: number
  isLiked: boolean
  favoriteCount: number
  isFavorited: boolean
}
