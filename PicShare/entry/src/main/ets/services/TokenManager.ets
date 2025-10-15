import preferences from '@ohos.data.preferences'
import { BusinessError } from '@ohos.base'
import { common } from '@kit.AbilityKit'

// Token管理器
export class TokenManager {
  private static instance: TokenManager
  private prefs: preferences.Preferences | null = null
  private static readonly TOKEN_KEY = 'auth_token'
  private static readonly PREFS_NAME = 'user_prefs'

  private constructor() {
  }

  // 获取TokenManager单例实例
  static getInstance(): TokenManager {
    if (!TokenManager.instance) {
      TokenManager.instance = new TokenManager()
    }
    return TokenManager.instance
  }

  // 初始化Preferences
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, TokenManager.PREFS_NAME)
    } catch (error) {
      const businessError = error as BusinessError
      console.error('初始化Preferences失败:', businessError.message)
      throw new Error('初始化Preferences失败')
    }
  }

  // 保存token
  async saveToken(token: string): Promise<void> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      await this.prefs.put(TokenManager.TOKEN_KEY, token)
      await this.prefs.flush()
    } catch (error) {
      const businessError = error as BusinessError
      console.error('保存token失败:', businessError.message)
      throw new Error('保存token失败')
    }
  }

  // 获取token
  async getToken(): Promise<string | null> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      const token = await this.prefs.get(TokenManager.TOKEN_KEY, '')
      return token === '' ? null : token as string
    } catch (error) {
      const businessError = error as BusinessError
      console.error('获取token失败:', businessError.message)
      return null
    }
  }

  // 清除token
  async clearToken(): Promise<void> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      await this.prefs.delete(TokenManager.TOKEN_KEY)
      await this.prefs.flush()
    } catch (error) {
      const businessError = error as BusinessError
      console.error('清除token失败:', businessError.message)
      throw new Error('清除token失败')
    }
  }
}

// 导出一个全局的getToken方法供其他模块使用
export const getToken = async (): Promise<string | null> => {
  const tokenManager = TokenManager.getInstance()
  return await tokenManager.getToken()
}