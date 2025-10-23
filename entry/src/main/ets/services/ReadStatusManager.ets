import preferences from '@ohos.data.preferences'
import { BusinessError } from '@ohos.base'
import { common } from '@kit.AbilityKit'

export class ReadStatusManager {
  private static instance: ReadStatusManager
  private prefs: preferences.Preferences | null = null
  private static readonly READ_POSTS_KEY = 'read_share_posts'
  private static readonly PREFS_NAME = 'read_status_prefs'

  private constructor() {
  }

  static getInstance(): ReadStatusManager {
    if (!ReadStatusManager.instance) {
      ReadStatusManager.instance = new ReadStatusManager()
    }
    return ReadStatusManager.instance
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, ReadStatusManager.PREFS_NAME)
      console.log('[ReadStatusManager] 初始化成功')
    } catch (error) {
      const businessError = error as BusinessError
      console.error('[ReadStatusManager] 初始化失败:', businessError.message)
      throw new Error('初始化ReadStatusManager失败')
    }
  }

  async saveReadPost(postId: string): Promise<void> {
    if (!this.prefs) {
      console.error('[ReadStatusManager] Preferences未初始化')
      return
    }

    try {
      const readPosts = await this.getReadPosts()
      if (!readPosts.includes(postId)) {
        readPosts.push(postId)
        await this.prefs.put(ReadStatusManager.READ_POSTS_KEY, JSON.stringify(readPosts))
        await this.prefs.flush()
        console.log('[ReadStatusManager] 已保存已读状态:', postId)
      }
    } catch (error) {
      const businessError = error as BusinessError
      console.error('[ReadStatusManager] 保存已读状态失败:', businessError.message)
    }
  }

  async getReadPosts(): Promise<string[]> {
    if (!this.prefs) {
      console.error('[ReadStatusManager] Preferences未初始化')
      return []
    }

    try {
      const readPostsJson = await this.prefs.get(ReadStatusManager.READ_POSTS_KEY, '[]')
      return JSON.parse(readPostsJson as string) || []
    } catch (error) {
      const businessError = error as BusinessError
      console.error('[ReadStatusManager] 获取已读状态失败:', businessError.message)
      return []
    }
  }

  async isPostRead(postId: string): Promise<boolean> {
    const readPosts = await this.getReadPosts()
    return readPosts.includes(postId)
  }

  async clearReadStatus(): Promise<void> {
    if (!this.prefs) {
      console.error('[ReadStatusManager] Preferences未初始化')
      return
    }

    try {
      await this.prefs.delete(ReadStatusManager.READ_POSTS_KEY)
      await this.prefs.flush()
      console.log('[ReadStatusManager] 已清除所有已读状态')
    } catch (error) {
      const businessError = error as BusinessError
      console.error('[ReadStatusManager] 清除已读状态失败:', businessError.message)
    }
  }
}


