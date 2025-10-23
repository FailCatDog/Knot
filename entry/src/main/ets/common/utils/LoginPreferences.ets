import { preferences } from '@kit.ArkData'

/**
 * 登录信息本地存储管理类
 * 功能：管理用户登录信息的本地存储和读取
 * 关键特性：单例模式、安全存储、记住密码功能
 * 使用场景：登录页面自动填充、记住密码功能
 * 设计模式：单例模式，确保全局唯一实例
 */
export class LoginPreferences {
  // ========== 单例模式 ==========
  private static instance: LoginPreferences
  private preferences: preferences.Preferences | null = null
  
  // ========== 存储配置 ==========
  private readonly PREFERENCES_NAME = 'login_preferences'    // 存储文件名
  private readonly KEY_USERNAME = 'saved_username'           // 用户名存储键
  private readonly KEY_PASSWORD = 'saved_password'          // 密码存储键
  private readonly KEY_REMEMBER_PASSWORD = 'remember_password' // 记住密码状态键

  private constructor() {
    // 私有构造函数，确保单例模式
  }

  /**
   * 获取单例实例 - 核心方法
   * 功能：确保全局只有一个LoginPreferences实例
   * 设计模式：单例模式，节省内存，统一管理
   * 返回值：LoginPreferences实例
   */
  static getInstance(): LoginPreferences {
    if (!LoginPreferences.instance) {
      LoginPreferences.instance = new LoginPreferences()
    }
    return LoginPreferences.instance
  }

  /**
   * 初始化本地存储 - 关键方法
   * 功能：初始化preferences存储系统
   * 调用时机：页面初始化时调用
   * 参数：Context - 应用上下文
   * 关键：必须在使用前调用，否则无法进行存储操作
   */
  async init(context: Context): Promise<void> {
    try {
      // 🔑 关键：创建preferences存储实例
      this.preferences = await preferences.getPreferences(context, this.PREFERENCES_NAME)
      console.log('[LoginPreferences] 初始化成功')
    } catch (error) {
      console.error('[LoginPreferences] 初始化失败:', error)
    }
  }

  /**
   * 保存登录信息 - 核心功能
   * 功能：保存用户名、密码和记住密码状态
   * 安全策略：根据rememberPassword参数决定是否保存密码
   * 参数：username-用户名, password-密码, rememberPassword-是否记住密码
   * 关键流程：保存用户名 → 根据选择保存密码 → 写入磁盘
   */
  async saveLoginInfo(username: string, password: string, rememberPassword: boolean): Promise<void> {
    if (!this.preferences) {
      console.error('[LoginPreferences] Preferences未初始化')
      return
    }

    try {
      // 🔑 关键：始终保存用户名（用于自动填充）
      await this.preferences.put(this.KEY_USERNAME, username)
      
      // 🔑 关键：根据用户选择决定是否保存密码
      if (rememberPassword) {
        await this.preferences.put(this.KEY_PASSWORD, password)
        await this.preferences.put(this.KEY_REMEMBER_PASSWORD, true)
      } else {
        await this.preferences.delete(this.KEY_PASSWORD)
        await this.preferences.put(this.KEY_REMEMBER_PASSWORD, false)
      }
      
      // 🔑 关键：立即写入磁盘
      await this.preferences.flush()
      console.log('[LoginPreferences] 保存登录信息成功，记住密码:', rememberPassword)
    } catch (error) {
      console.error('[LoginPreferences] 保存登录信息失败:', error)
    }
  }

  /**
   * 获取保存的用户名 - 核心功能
   * 功能：从本地存储中读取用户名
   * 用途：登录页面自动填充用户名
   * 返回值：保存的用户名或空字符串
   * 安全：用户名始终保存，用于提升用户体验
   */
  async getSavedUsername(): Promise<string> {
    if (!this.preferences) {
      return ''
    }

    try {
      // 🔑 关键：获取保存的用户名
      const username = await this.preferences.get(this.KEY_USERNAME, '')
      return username as string
    } catch (error) {
      console.error('[LoginPreferences] 获取用户名失败:', error)
      return ''
    }
  }

  /**
   * 获取保存的密码 - 核心功能
   * 功能：从本地存储中读取密码
   * 用途：登录页面自动填充密码（仅当勾选记住密码时）
   * 安全策略：仅在用户明确选择记住密码时才返回密码
   * 返回值：保存的密码或空字符串
   */
  async getSavedPassword(): Promise<string> {
    if (!this.preferences) {
      return ''
    }

    try {
      // 🔑 关键：先检查是否选择了记住密码
      const rememberPassword = await this.preferences.get(this.KEY_REMEMBER_PASSWORD, false)
      if (rememberPassword) {
        // 🔑 关键：只有在记住密码时才返回密码
        const password = await this.preferences.get(this.KEY_PASSWORD, '')
        return password as string
      }
      return ''
    } catch (error) {
      console.error('[LoginPreferences] 获取密码失败:', error)
      return ''
    }
  }

  /**
   * 获取记住密码状态 - 核心功能
   * 功能：检查用户是否选择了记住密码
   * 用途：决定是否自动填充密码
   * 返回值：true-记住密码, false-不记住密码
   * 关键：用于UI状态同步
   */
  async getRememberPassword(): Promise<boolean> {
    if (!this.preferences) {
      return false
    }

    try {
      // 🔑 关键：获取记住密码状态
      const remember = await this.preferences.get(this.KEY_REMEMBER_PASSWORD, false)
      return remember as boolean
    } catch (error) {
      console.error('[LoginPreferences] 获取记住密码状态失败:', error)
      return false
    }
  }

  /**
   * 清除密码 - 安全功能
   * 功能：删除保存的密码，重置记住密码状态
   * 使用场景：用户取消记住密码时调用
   * 安全：确保密码不会意外保留
   */
  async clearPassword(): Promise<void> {
    if (!this.preferences) {
      return
    }

    try {
      // 🔑 关键：删除密码并重置状态
      await this.preferences.delete(this.KEY_PASSWORD)
      await this.preferences.put(this.KEY_REMEMBER_PASSWORD, false)
      await this.preferences.flush()
      console.log('[LoginPreferences] 清除密码成功')
    } catch (error) {
      console.error('[LoginPreferences] 清除密码失败:', error)
    }
  }

  /**
   * 清除所有登录信息 - 安全功能
   * 功能：删除所有保存的登录信息
   * 使用场景：用户登出、清除缓存时调用
   * 安全：完全清除敏感信息
   */
  async clearAll(): Promise<void> {
    if (!this.preferences) {
      return
    }

    try {
      // 🔑 关键：清除所有数据
      await this.preferences.clear()
      await this.preferences.flush()
      console.log('[LoginPreferences] 清除所有信息成功')
    } catch (error) {
      console.error('[LoginPreferences] 清除所有信息失败:', error)
    }
  }
}

