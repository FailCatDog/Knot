import { changePassword, ChangePasswordRequest, getCurrentUserInfo } from '../services/api/UserApi'

// 定义返回类型接口
export interface OperationResult {
  success: boolean
  message: string
}

@Observed
export class ChangePasswordViewModel {
  // 表单数据
  oldPassword: string = ''
  newPassword: string = ''
  confirmPassword: string = ''
  
  // 状态
  isSubmitting: boolean = false
  errorMessage: string = ''
  userId: number = 0

  // 初始化，获取用户ID
  async initialize(): Promise<OperationResult> {
    try {
      const response = await getCurrentUserInfo()
      if (response.success && response.data) {
        this.userId = response.data.id
        return { success: true, message: '初始化成功' }
      } else {
        this.errorMessage = '获取用户信息失败'
        return { success: false, message: '获取用户信息失败' }
      }
    } catch (error) {
      console.error('[ChangePasswordViewModel] 初始化失败:', error)
      this.errorMessage = '网络请求失败'
      return { success: false, message: '网络请求失败' }
    }
  }

  // 修改密码
  async changePassword(): Promise<OperationResult> {
    // 表单验证
    if (!this.oldPassword) {
      this.errorMessage = '请输入旧密码'
      return { success: false, message: '请输入旧密码' }
    }

    if (!this.newPassword) {
      this.errorMessage = '请输入新密码'
      return { success: false, message: '请输入新密码' }
    }

    if (this.newPassword.length < 6 || this.newPassword.length > 100) {
      this.errorMessage = '新密码长度需在8-100个字符之间'
      return { success: false, message: '新密码长度需在8-100个字符之间' }
    }

    if (this.newPassword !== this.confirmPassword) {
      this.errorMessage = '两次输入的新密码不一致'
      return { success: false, message: '两次输入的新密码不一致' }
    }

    if (this.oldPassword === this.newPassword) {
      this.errorMessage = '新密码不能与旧密码相同'
      return { success: false, message: '新密码不能与旧密码相同' }
    }

    this.isSubmitting = true
    this.errorMessage = ''

    try {
      const param: ChangePasswordRequest = {
        user_id: this.userId,
        old_password: this.oldPassword,
        new_password: this.newPassword
      }

      const response = await changePassword(param)

      this.isSubmitting = false

      if (response.success) {
        return { success: true, message: '密码修改成功' }
      } else {
        this.errorMessage = response.message || '密码修改失败'
        
        let message: string = '密码修改失败'
        switch (response.message) {
          case '旧密码不正确':
            message = '旧密码不正确'
            break
          case '新密码格式不正确':
            message = '新密码格式不正确'
            break
          default:
            message = response.message || '密码修改失败'
        }
        
        return { success: false, message: message }
      }
    } catch (error) {
      console.error('[ChangePasswordViewModel] 修改密码失败:', error)
      this.errorMessage = '网络请求失败，请稍后重试'
      this.isSubmitting = false
      
      return { success: false, message: '网络请求失败，请稍后重试' }
    }
  }

  // 更新字段
  updateOldPassword(value: string): void {
    this.oldPassword = value
  }

  updateNewPassword(value: string): void {
    this.newPassword = value
  }

  updateConfirmPassword(value: string): void {
    this.confirmPassword = value
  }

  // 清除错误消息
  clearError(): void {
    this.errorMessage = ''
  }

  // 重置表单
  reset(): void {
    this.oldPassword = ''
    this.newPassword = ''
    this.confirmPassword = ''
    this.errorMessage = ''
  }
}

