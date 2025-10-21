import { updateUserInfo, UpdateUserInfoRequest, UserInfo, getCurrentUserInfo, uploadAvatar } from '../services/api/UserApi'
import { picker } from '@kit.CoreFileKit'
import { fileIo } from '@kit.CoreFileKit'

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

@Observed
export class EditProfileViewModel {
  // 表单数据
  realName: string = ''
  phone: string = ''
  email: string = ''
  bio: string = ''
  gender: string = ''
  location: string = ''
  avatarUrl: string = ''

  // 状态
  isLoading: boolean = false
  errorMessage: string = ''
  isUploadingAvatar: boolean = false

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

      console.log('[EditProfileViewModel] 调用updateUserInfo，参数:', JSON.stringify(updateParam))
      const response = await updateUserInfo(updateParam)
      console.log('[EditProfileViewModel] updateUserInfo响应:', JSON.stringify(response))

      this.isLoading = false

      if (response.success) {
        return { 
          success: true, 
          message: '更新成功',
          userInfo: response.data
        }
      } else {
        this.errorMessage = response.message || '更新失败'
        console.error('[EditProfileViewModel] 更新失败:', response.message)
        return { 
          success: false, 
          message: response.message || '更新失败'
        }
      }
    } catch (error) {
      console.error('[EditProfileViewModel] 更新用户信息异常:', error)
      console.error('[EditProfileViewModel] 异常详情:', JSON.stringify(error))
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

  // 选择并上传头像
  async selectAndUploadAvatar(): Promise<OperationResult> {
    try {
      // 创建图片选择器
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      
      const photoPicker = new picker.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)
      
      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        const imageUri = photoSelectResult.photoUris[0]
        console.log('[EditProfileViewModel] 选择的图片URI:', imageUri)
        
        // 上传头像
        return await this.uploadAvatarFromUri(imageUri)
      } else {
        return { success: false, message: '未选择图片' }
      }
    } catch (error) {
      console.error('[EditProfileViewModel] 选择图片失败:', error)
      return { success: false, message: '选择图片失败' }
    }
  }

  // 从URI上传头像
  async uploadAvatarFromUri(imageUri: string): Promise<OperationResult> {
    this.isUploadingAvatar = true
    
    try {
      console.log('[EditProfileViewModel] 开始读取图片文件:', imageUri)
      
      // 读取图片文件
      const file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY)
      const stat = fileIo.statSync(file.fd)
      const buffer = new ArrayBuffer(stat.size)
      fileIo.readSync(file.fd, buffer)
      fileIo.closeSync(file.fd)
      
      console.log('[EditProfileViewModel] 图片文件大小:', stat.size)
      
      // 从URI提取文件名
      const fileName = imageUri.substring(imageUri.lastIndexOf('/') + 1)
      console.log('[EditProfileViewModel] 文件名:', fileName)
      
      // 上传头像
      console.log('[EditProfileViewModel] 开始上传头像')
      const response = await uploadAvatar(buffer, fileName)
      console.log('[EditProfileViewModel] 上传头像响应:', JSON.stringify(response))
      
      if (response.success && response.data) {
        this.avatarUrl = response.data.avatar_url
        console.log('[EditProfileViewModel] 头像上传成功，URL:', this.avatarUrl)
        this.isUploadingAvatar = false
        return { success: true, message: '头像上传成功' }
      } else {
        console.error('[EditProfileViewModel] 头像上传失败:', response.message)
        this.isUploadingAvatar = false
        return { success: false, message: response.message || '头像上传失败' }
      }
    } catch (error) {
      console.error('[EditProfileViewModel] 上传头像异常:', error)
      this.isUploadingAvatar = false
      return { success: false, message: '上传失败，请稍后重试' }
    }
  }
}

