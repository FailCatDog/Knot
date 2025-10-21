import { getComments, CommentEntity, deleteComment } from '../../services/api/CommentApi'
import { ToastUtil } from '../../common/utils/ToastUtil'

interface CommentItem {
  id: string
  userId: string
  userAvatar: string
  userName: string
  content: string
  timestamp: string
}

@Component
export struct CommentSection {
  @State comments: CommentItem[] = []
  @State isLoading: boolean = false
  @State currentPage: number = 1
  @State hasMore: boolean = true
  @State totalCount: number = 0
  @Prop refreshTimestamp: number = 0
  @Prop initialComments: CommentEntity[] = []
  postId: string = ''
  onCommentCountChange?: (count: number) => void
  private lastRefreshTimestamp: number = 0
  private isInitialized: boolean = false

  aboutToAppear() {
    if (this.initialComments && this.initialComments.length > 0) {
      this.loadInitialComments()
    } else {
      this.loadComments()
    }
  }

  aboutToUpdate() {
    if (this.refreshTimestamp !== this.lastRefreshTimestamp && this.refreshTimestamp > 0) {
      this.lastRefreshTimestamp = this.refreshTimestamp
      this.refreshComments()
    }
  }

  loadInitialComments() {
    const newComments: CommentItem[] = this.initialComments.map((comment: CommentEntity): CommentItem => ({
      id: comment.comment_id,
      userId: comment.author.user_id,
      userAvatar: this.formatAvatarUrl(comment.author.avatar_url),
      userName: comment.author.username,
      content: comment.content,
      timestamp: this.formatTimestamp(comment.create_time)
    }))

    this.comments = newComments
    this.totalCount = newComments.length
    this.currentPage = 2
    this.isInitialized = true

    if (this.onCommentCountChange) {
      this.onCommentCountChange(this.totalCount)
    }
  }

  async loadComments() {
    if (this.isLoading) return
    if (this.currentPage > 1 && !this.hasMore) return

    this.isLoading = true
    const response = await getComments(this.postId, this.currentPage, 20)

    if (response.success && response.data) {
      const newComments: CommentItem[] = response.data.comments.map((comment: CommentEntity): CommentItem => ({
        id: comment.comment_id,
        userId: comment.author.user_id,
        userAvatar: this.formatAvatarUrl(comment.author.avatar_url),
        userName: comment.author.username,
        content: comment.content,
        timestamp: this.formatTimestamp(comment.create_time)
      }))

      if (this.currentPage === 1) {
        this.comments = newComments
      } else {
        this.comments = [...this.comments, ...newComments]
      }

      this.totalCount = response.data.total
      this.hasMore = response.data.has_more
      this.currentPage++

      if (this.onCommentCountChange) {
        this.onCommentCountChange(this.totalCount)
      }
    }

    this.isLoading = false
  }

  formatAvatarUrl(avatarUrl: string): string {
    if (!avatarUrl || avatarUrl.trim() === '') {
      return ''
    }
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl
    }
    return `http://43.142.157.145:8080${avatarUrl}`
  }

  formatTimestamp(timestamp: number): string {
    const now = Date.now()
    const diff = now - timestamp * 1000
    const seconds = Math.floor(diff / 1000)
    const minutes = Math.floor(seconds / 60)
    const hours = Math.floor(minutes / 60)
    const days = Math.floor(hours / 24)

    if (days > 0) {
      const date = new Date(timestamp * 1000)
      return `${date.getMonth() + 1}-${date.getDate()}`
    } else if (hours > 0) {
      return `${hours}小时前`
    } else if (minutes > 0) {
      return `${minutes}分钟前`
    } else {
      return '刚刚'
    }
  }

  async handleDeleteComment(commentId: string) {
    const response = await deleteComment(this.postId, commentId)
    if (response.success) {
      this.comments = this.comments.filter(comment => comment.id !== commentId)
      this.totalCount--
      if (this.onCommentCountChange) {
        this.onCommentCountChange(this.totalCount)
      }
      ToastUtil.getInstance().show('删除成功')
    } else {
      ToastUtil.getInstance().show(response.message || '删除失败')
    }
  }

  refreshComments() {
    this.currentPage = 1
    this.hasMore = true
    this.comments = []
    this.loadComments()
  }

  @Builder
  buildCommentItem(comment: CommentItem) {
    Row({ space: 12 }) {
      Image(comment.userAvatar && comment.userAvatar.trim() !== '' ? comment.userAvatar : $r('app.media.head'))
        .width(36)
        .height(36)
        .borderRadius(18)
        .objectFit(ImageFit.Cover)
        .alt($r('app.media.head'))

      Column({ space: 0 }) {
        Row() {
          Column({ space: 2 }) {
            Text(comment.userName)
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)

            Text(comment.timestamp)
              .fontSize(12)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Start)
          .height(36)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')

        Text(comment.content)
          .fontSize(15)
          .fontColor('#333333')
          .lineHeight(22)
          .width('100%')
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Top)
  }

  handleReply(commentId: string) {
  }

  build() {
    Column() {
      Row() {
        Text('评论')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)

        if (this.comments.length > 0) {
          Text(`${this.comments.length}`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 4 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      Divider()
        .color('#F0F0F0')
        .strokeWidth(1)

      if (this.comments.length > 0) {
        Column() {
          ForEach(this.comments, (comment: CommentItem) => {
            this.buildCommentItem(comment)
            Divider()
              .color('#F5F5F5')
              .strokeWidth(1)
          })
        }
      } else {
        Column() {
          Image($r('app.media.ic_message'))
            .width(80)
            .height(80)
            .fillColor('#D0D0D0')
            .margin({ top: 40 })

          Text('暂无评论')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12, bottom: 40 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}

