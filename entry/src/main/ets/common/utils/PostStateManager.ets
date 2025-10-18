export interface PostState {
  postId: string
  isLiked: boolean
  likeCount: number
}

export class PostStateManager {
  private static instance: PostStateManager
  private postStates: Map<string, PostState> = new Map()

  private constructor() {}

  static getInstance(): PostStateManager {
    if (!PostStateManager.instance) {
      PostStateManager.instance = new PostStateManager()
    }
    return PostStateManager.instance
  }

  updatePostState(postId: string, isLiked: boolean, likeCount: number): void {
    this.postStates.set(postId, { postId, isLiked, likeCount })
  }

  getPostState(postId: string): PostState | null {
    return this.postStates.get(postId) || null
  }

  clearPostState(postId: string): void {
    this.postStates.delete(postId)
  }

  hasPostState(postId: string): boolean {
    return this.postStates.has(postId)
  }
}

