import preferences from '@ohos.data.preferences'
import { BusinessError } from '@ohos.base'
import { common } from '@kit.AbilityKit'
import util from '@ohos.util'

export class TokenManager {
  private static instance: TokenManager
  private prefs: preferences.Preferences | null = null
  private static readonly TOKEN_KEY = 'auth_token'
  private static readonly USER_ID_KEY = 'current_user_id'
  private static readonly PREFS_NAME = 'user_prefs'
  private static onTokenExpiredCallback: (() => void) | null = null

  private constructor() {
  }

  static getInstance(): TokenManager {
    if (!TokenManager.instance) {
      TokenManager.instance = new TokenManager()
    }
    return TokenManager.instance
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, TokenManager.PREFS_NAME)
    } catch (error) {
      const businessError = error as BusinessError
      console.error('初始化Preferences失败:', businessError.message)
      throw new Error('初始化Preferences失败')
    }
  }

  async saveToken(token: string): Promise<void> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      await this.prefs.put(TokenManager.TOKEN_KEY, token)
      await this.prefs.flush()
      console.log('[TokenManager] Token保存成功')
    } catch (error) {
      const businessError = error as BusinessError
      console.error('保存token失败:', businessError.message)
      throw new Error('保存token失败')
    }
  }

  async getToken(): Promise<string | null> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      const token = await this.prefs.get(TokenManager.TOKEN_KEY, '')
      const result = token === '' ? null : token as string
      console.log('[TokenManager] 获取token:', result ? '成功' : '未找到')
      return result
    } catch (error) {
      const businessError = error as BusinessError
      console.error('获取token失败:', businessError.message)
      return null
    }
  }

  async clearToken(): Promise<void> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      await this.prefs.delete(TokenManager.TOKEN_KEY)
      await this.prefs.delete(TokenManager.USER_ID_KEY)
      await this.prefs.flush()
    } catch (error) {
      const businessError = error as BusinessError
      console.error('清除token失败:', businessError.message)
      throw new Error('清除token失败')
    }
  }

  async saveUserId(userId: string): Promise<void> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      await this.prefs.put(TokenManager.USER_ID_KEY, userId)
      await this.prefs.flush()
    } catch (error) {
      const businessError = error as BusinessError
      console.error('保存userId失败:', businessError.message)
      throw new Error('保存userId失败')
    }
  }

  async getUserId(): Promise<string | null> {
    if (!this.prefs) {
      throw new Error('Preferences未初始化')
    }
    try {
      const userId = await this.prefs.get(TokenManager.USER_ID_KEY, '')
      return userId === '' ? null : userId as string
    } catch (error) {
      const businessError = error as BusinessError
      console.error('获取userId失败:', businessError.message)
      return null
    }
  }

  decodeToken(token: string): Record<string, Object> | null {
    const parts = token.split('.')
    if (parts.length !== 3) {
      return null
    }

    const payload = parts[1]
    const decodedPayload = this.base64UrlDecode(payload)
    return JSON.parse(decodedPayload) as Record<string, Object>
  }

  private base64UrlDecode(str: string): string {
    let base64 = str.replace(/-/g, '+').replace(/_/g, '/')
    const pad = base64.length % 4
    if (pad) {
      if (pad === 1) {
        throw new Error('Invalid base64url string')
      }
      base64 += new Array(5 - pad).join('=')
    }

    const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    const bytes: number[] = []
    
    for (let i = 0; i < base64.length; i += 4) {
      const encoded1 = base64Chars.indexOf(base64[i])
      const encoded2 = base64Chars.indexOf(base64[i + 1])
      const encoded3 = base64Chars.indexOf(base64[i + 2])
      const encoded4 = base64Chars.indexOf(base64[i + 3])
      
      bytes.push((encoded1 << 2) | (encoded2 >> 4))
      if (encoded3 !== -1) {
        bytes.push(((encoded2 & 15) << 4) | (encoded3 >> 2))
      }
      if (encoded4 !== -1) {
        bytes.push(((encoded3 & 3) << 6) | encoded4)
      }
    }

    const decoder = util.TextDecoder.create('utf-8')
    const uint8Array = new Uint8Array(bytes)
    return decoder.decodeToString(uint8Array)
  }

  isTokenExpired(token: string): boolean {
    const payload = this.decodeToken(token)
    if (!payload || !payload.exp) {
      return true
    }

    const exp = payload.exp as number
    const now = Math.floor(Date.now() / 1000)
    return now >= exp
  }

  async checkAndClearExpiredToken(): Promise<boolean> {
    const token = await this.getToken()
    if (!token) {
      return false
    }

    if (this.isTokenExpired(token)) {
      await this.clearToken()
      if (TokenManager.onTokenExpiredCallback) {
        TokenManager.onTokenExpiredCallback()
      }
      return true
    }

    return false
  }

  async clearUserData(): Promise<void> {
    await this.clearToken()
  }

  static setTokenExpiredCallback(callback: () => void): void {
    TokenManager.onTokenExpiredCallback = callback
  }
}

export const getToken = async (): Promise<string | null> => {
  const tokenManager = TokenManager.getInstance()
  return await tokenManager.getToken()
}
