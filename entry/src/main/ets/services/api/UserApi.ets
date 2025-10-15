import { httpRequest } from './HttpRequest'
import { ApiConstants } from './ApiConstants'
import { ApiResponse } from './HttpRequest'

export interface RegisterRequest extends Record<string, string | number | boolean | object | undefined> {
  username: string;
  password: string;
  email: string;
}

export interface LoginRequest extends Record<string, string | number | boolean | object | undefined> {
  username: string;
  password: string;
}

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

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  user: UserInfo;
}

export interface RegisterResponse {
  id: number;
  username: string;
  email: string;
  create_time: number;
}

export interface LogoutRequest extends Record<string, string | number | boolean | object | undefined> {
  access_token: string;
}

export interface ChangePasswordRequest extends Record<string, string | number | boolean | object | undefined> {
  user_id: number;
  old_password: string;
  new_password: string;
}

export interface UpdateUserInfoRequest extends Record<string, string | number | boolean | object | undefined> {
  real_name: string;
  email?: string;
  avatar_url?: string;
  phone: string;
  bio?: string;
  gender?: string;
  location?: string;
}

export const register = async (
  param: RegisterRequest
): Promise<ApiResponse<RegisterResponse>> => {
  return httpRequest.post<RegisterResponse, RegisterRequest>(
    ApiConstants.USER_ENDPOINTS.REGISTER,
    param
  )
}

export const login = async (
  param: LoginRequest
): Promise<ApiResponse<LoginResponse>> => {
  return httpRequest.post<LoginResponse, LoginRequest>(
    ApiConstants.USER_ENDPOINTS.LOGIN,
    param
  )
}

export const getCurrentUserInfo = async (): Promise<ApiResponse<UserInfo>> => {
  return httpRequest.get<UserInfo>(ApiConstants.USER_ENDPOINTS.GET_USER_INFO)
}

export const logout = async (
  param: LogoutRequest
): Promise<ApiResponse<null>> => {
  return httpRequest.post<null, LogoutRequest>(
    '/auth/logout',
    param
  )
}

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
