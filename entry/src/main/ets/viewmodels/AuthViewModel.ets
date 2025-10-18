import { login, register, LoginRequest, RegisterRequest, LoginResponse, RegisterResponse, UserInfo } from '../services/api/UserApi'
import { TokenManager } from '../services/TokenManager'

// 定义返回类型接口
export interface LoginResult {
  success: boolean
  message: string
  userInfo?: UserInfo
}

export interface RegisterResult {
  success: boolean
  message: string
}

@Observed
export class AuthViewModel {
  // 登录状态
  isLoginLoading: boolean = false
  loginErrorMessage: string = ''

  // 注册状态
  isRegisterLoading: boolean = false
  registerErrorMessage: string = ''

  // 登录
  async login(username: string, password: string): Promise<LoginResult> {
    // 表单验证
    if (!username.trim()) {
      this.loginErrorMessage = '请输入用户名'
      return { success: false, message: '请输入用户名' }
    }

    if (!password.trim()) {
      this.loginErrorMessage = '请输入密码'
      return { success: false, message: '请输入密码' }
    }

    if (password.length < 6 || password.length > 100) {
      this.loginErrorMessage = '密码长度需在6-100个字符之间'
      return { success: false, message: '密码长度需在6-100个字符之间' }
    }

    this.isLoginLoading = true
    this.loginErrorMessage = ''

    try {
      const loginParam: LoginRequest = {
        username: username,
        password: password
      }

      const response = await login(loginParam)

      if (response.success && response.data) {
        const loginData: LoginResponse = response.data
        
        const tokenManager = TokenManager.getInstance()
        await tokenManager.saveToken(loginData.access_token)
        await tokenManager.saveUserId(loginData.user.user_id)
        
        console.log('[AuthViewModel] 登录成功，用户:', loginData.user.username)
        
        this.isLoginLoading = false
        
        return { 
          success: true, 
          message: '登录成功',
          userInfo: loginData.user
        }
      } else {
        this.loginErrorMessage = response.message || '登录失败'
        this.isLoginLoading = false
        
        return { 
          success: false, 
          message: response.message || '登录失败'
        }
      }
    } catch (error) {
      console.error('[AuthViewModel] 登录失败:', error)
      this.loginErrorMessage = '网络请求失败'
      this.isLoginLoading = false
      
      return { 
        success: false, 
        message: '网络请求失败'
      }
    }
  }

  // 注册
  async register(username: string, realName: string, phone: string, email: string, password: string, confirmPassword: string): Promise<RegisterResult> {
    // 表单验证
    if (!username.trim()) {
      this.registerErrorMessage = '请输入用户名'
      return { success: false, message: '请输入用户名' }
    }

    if (username.length < 3 || username.length > 50) {
      this.registerErrorMessage = '用户名长度需在3-50个字符之间'
      return { success: false, message: '用户名长度需在3-50个字符之间' }
    }

    if (!realName.trim()) {
      this.registerErrorMessage = '请输入真实姓名'
      return { success: false, message: '请输入真实姓名' }
    }

    if (realName.length > 50) {
      this.registerErrorMessage = '真实姓名不能超过50字符'
      return { success: false, message: '真实姓名不能超过50字符' }
    }

    if (!phone.trim()) {
      this.registerErrorMessage = '请输入手机号'
      return { success: false, message: '请输入手机号' }
    }

    const phoneRegex: RegExp = /^1[3-9]\d{9}$/
    if (!phoneRegex.test(phone)) {
      this.registerErrorMessage = '手机号格式不正确'
      return { success: false, message: '手机号格式不正确' }
    }

    // 邮箱是可选的
    if (email.trim()) {
      const emailRegex: RegExp = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(email)) {
        this.registerErrorMessage = '邮箱格式不正确'
        return { success: false, message: '邮箱格式不正确' }
      }
    }

    if (!password.trim()) {
      this.registerErrorMessage = '请输入密码'
      return { success: false, message: '请输入密码' }
    }

    if (password.length < 6 || password.length > 100) {
      this.registerErrorMessage = '密码长度需在6-100个字符之间'
      return { success: false, message: '密码长度需在6-100个字符之间' }
    }

    if (password !== confirmPassword) {
      this.registerErrorMessage = '两次输入的密码不一致'
      return { success: false, message: '两次输入的密码不一致' }
    }

    this.isRegisterLoading = true
    this.registerErrorMessage = ''

    try {
      const registerParam: RegisterRequest = {
        username: username,
        real_name: realName,
        phone: phone,
        password: password
      }
      
      // 如果邮箱有值则添加
      if (email.trim()) {
        registerParam.email = email
      }

      const response = await register(registerParam)

      if (response.success) {
        console.log('[AuthViewModel] 注册成功')
        this.isRegisterLoading = false
        
        return { 
          success: true, 
          message: '注册成功，请登录'
        }
      } else {
        this.registerErrorMessage = response.message || '注册失败'
        this.isRegisterLoading = false
        
        return { 
          success: false, 
          message: response.message || '注册失败'
        }
      }
    } catch (error) {
      console.error('[AuthViewModel] 注册失败:', error)
      this.registerErrorMessage = '网络请求失败'
      this.isRegisterLoading = false
      
      return { 
        success: false, 
        message: '网络请求失败'
      }
    }
  }

  // 清除错误消息
  clearLoginError(): void {
    this.loginErrorMessage = ''
  }

  clearRegisterError(): void {
    this.registerErrorMessage = ''
  }
}

