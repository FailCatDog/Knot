import { updateUserInfo, UpdateUserInfoRequest, UserInfo, getCurrentUserInfo } from '../services/api/UserApi'

// 定义返回类型接口
export interface OperationResult {
  success: boolean
  message: string
}

export interface SaveUserInfoResult {
  success: boolean
  message: string
  userInfo?: UserInfo
}

@ObservedV2
export class EditProfileViewModel {
  // 表单数据
  @Trace realName: string = ''
  @Trace phone: string = ''
  @Trace email: string = ''
  @Trace bio: string = ''
  @Trace gender: string = ''
  @Trace location: string = ''
  @Trace avatarUrl: string = ''

  // 状态
  @Trace isLoading: boolean = false
  @Trace errorMessage: string = ''

  // 加载用户信息
  async loadUserInfo(): Promise<OperationResult> {
    this.isLoading = true

    try {
      const response = await getCurrentUserInfo()
      
      if (response.success && response.data) {
        const userInfo: UserInfo = response.data
        this.realName = userInfo.real_name || ''
        this.phone = userInfo.phone || ''
        this.email = userInfo.email || ''
        this.bio = userInfo.bio || ''
        this.gender = userInfo.gender || ''
        this.location = userInfo.location || ''
        this.avatarUrl = userInfo.avatar_url || ''
        
        this.isLoading = false
        
        return { success: true, message: '加载成功' }
      } else {
        this.errorMessage = response.message || '获取用户信息失败'
        this.isLoading = false
        
        return { success: false, message: response.message || '获取用户信息失败' }
      }
    } catch (error) {
      console.error('[EditProfileViewModel] 加载用户信息失败:', error)
      this.errorMessage = '网络请求失败'
      this.isLoading = false
      
      return { success: false, message: '网络请求失败' }
    }
  }

  // 保存用户信息
  async saveUserInfo(): Promise<SaveUserInfoResult> {
    // 表单验证
    if (!this.realName.trim()) {
      this.errorMessage = '请输入真实姓名'
      return { success: false, message: '请输入真实姓名' }
    }

    if (!this.phone.trim()) {
      this.errorMessage = '请输入手机号'
      return { success: false, message: '请输入手机号' }
    }

    const phoneRegex: RegExp = /^1[3-9]\d{9}$/
    if (!phoneRegex.test(this.phone)) {
      this.errorMessage = '手机号格式不正确'
      return { success: false, message: '手机号格式不正确' }
    }

    if (this.bio.length > 500) {
      this.errorMessage = '个人简介不能超过500个字符'
      return { success: false, message: '个人简介不能超过500个字符' }
    }

    this.isLoading = true
    this.errorMessage = ''

    try {
      const updateParam: UpdateUserInfoRequest = {
        real_name: this.realName,
        phone: this.phone
      }

      if (this.email.trim()) {
        updateParam.email = this.email
      }
      if (this.bio.trim()) {
        updateParam.bio = this.bio
      }
      if (this.gender) {
        updateParam.gender = this.gender
      }
      if (this.location.trim()) {
        updateParam.location = this.location
      }
      if (this.avatarUrl.trim()) {
        updateParam.avatar_url = this.avatarUrl
      }

      const response = await updateUserInfo(updateParam)

      this.isLoading = false

      if (response.success) {
        return { 
          success: true, 
          message: '更新成功',
          userInfo: response.data
        }
      } else {
        this.errorMessage = response.message || '更新失败'
        return { 
          success: false, 
          message: response.message || '更新失败'
        }
      }
    } catch (error) {
      console.error('[EditProfileViewModel] 更新用户信息失败:', error)
      this.errorMessage = '网络请求失败，请稍后重试'
      this.isLoading = false
      
      return { 
        success: false, 
        message: '网络请求失败，请稍后重试'
      }
    }
  }

  // 更新字段
  updateField(field: string, value: string): void {
    switch (field) {
      case 'realName':
        this.realName = value
        break
      case 'phone':
        this.phone = value
        break
      case 'email':
        this.email = value
        break
      case 'bio':
        this.bio = value
        break
      case 'gender':
        this.gender = value
        break
      case 'location':
        this.location = value
        break
      case 'avatarUrl':
        this.avatarUrl = value
        break
    }
  }

  // 清除错误消息
  clearError(): void {
    this.errorMessage = ''
  }
}

