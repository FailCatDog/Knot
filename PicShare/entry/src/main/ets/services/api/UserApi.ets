/**
 * 用户模块API实现
 */
import { httpRequest } from './HttpRequest'
import { ApiConstants } from './ApiConstants'
import { ApiResponse } from './HttpRequest'

/**
 * 用户注册请求参数
 */
export interface RegisterRequest {
  username: string;
  password: string;
  email: string;
}

/**
 * 用户登录请求参数
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 用户信息
 */
export interface UserInfo {
  id: number;
  user_id: string;
  username: string;
  email: string;
  phone: string;
  real_name: string;
  avatar_url: string;
  bio: string;
  location: string;
  gender: string;
  role: string;
  status: string;
  create_time: number;
  update_time: number;
  device_count: number;
}

/**
 * 登录响应数据
 */
export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  user: UserInfo;
}

/**
 * 注册响应数据
 */
export interface RegisterResponse {
  id: number;
  username: string;
  email: string;
  create_time: number;
}

/**
 * 登出请求参数
 */
export interface LogoutRequest {
  access_token: string;
}

/**
 * 修改密码请求参数
 */
export interface ChangePasswordRequest {
  user_id: number;
  old_password: string;
  new_password: string;
}

export interface UpdateUserInfoRequest {
  real_name: string;
  email?: string;
  avatar_url?: string;
  phone: string;
  bio?: string;
  gender?: string;
  location?: string;
}

/**
 * 用户注册
 * @param param 注册参数
 */
export const register = async (
  param: RegisterRequest
): Promise<ApiResponse<RegisterResponse>> => {
  return httpRequest.post<RegisterResponse, RegisterRequest>(
    ApiConstants.USER_ENDPOINTS.REGISTER,
    param
  )
}

/**
 * 用户登录
 * @param param 登录参数
 */
export const login = async (
  param: LoginRequest
): Promise<ApiResponse<LoginResponse>> => {
  return httpRequest.post<LoginResponse, LoginRequest>(
    ApiConstants.USER_ENDPOINTS.LOGIN,
    param
  )
}

/**
 * 获取当前用户信息
 */
export const getCurrentUserInfo = async (): Promise<ApiResponse<UserInfo>> => {
  return httpRequest.get<UserInfo>(ApiConstants.USER_ENDPOINTS.GET_USER_INFO)
}

/**
 * 用户登出
 * @param param 登出参数
 */
export const logout = async (
  param: LogoutRequest
): Promise<ApiResponse<null>> => {
  // 登出接口不需要认证头，所以我们需要一个特殊的httpRequest实例
  // 但当前API设计会自动添加Authorization头，所以直接使用现有的
  // 在实际项目中，可能需要后端支持在body中传递token而不是在header中
  return httpRequest.post<null, LogoutRequest>(
    '/auth/logout',
    param
  )
}

/**
 * 修改密码
 * @param param 修改密码参数
 */
export const changePassword = async (
  param: ChangePasswordRequest
): Promise<ApiResponse<null>> => {
  return httpRequest.put<null, ChangePasswordRequest>(
    ApiConstants.USER_ENDPOINTS.CHANGE_PASSWORD,
    param
  )
}

export const updateUserInfo = async (
  param: UpdateUserInfoRequest
): Promise<ApiResponse<UserInfo>> => {
  return httpRequest.put<UserInfo, UpdateUserInfoRequest>(
    ApiConstants.USER_ENDPOINTS.UPDATE_USER_INFO,
    param
  )
}