import { httpRequest } from './HttpRequest'
import { ApiConstants } from './ApiConstants'
import { ApiResponse } from './HttpRequest'

export interface RegisterRequest extends Record<string, string | number | boolean | object | undefined> {
  username: string;
  password: string;
  real_name: string;
  phone: string;
  email?: string;
  role?: string;
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

// 帖子图片接口
export interface PostImage {
  id: number;
  image_id: string;
  post_id: number;
  user_id: number;
  file_url: string;
  thumbnail_url: string;
  width: number;
  height: number;
  file_size: number;
  mime_type: string;
  display_order: number;
  create_time: number;
  update_time: number;
}

// 帖子接口
export interface Post {
  id: number;
  post_id: string;
  user_id: number;
  title: string;
  description: string;
  cover_image_url?: string;
  image_count: number;
  images?: PostImage[];
  like_count: number;
  favorite_count: number;
  view_count: number;
  status: string;
  create_time: number;
  update_time: number;
}

// 用户帖子列表响应接口
export interface UserPostsResponse {
  page: number;
  page_size: number;
  total: number;
  posts: Post[];
}

// 获取用户帖子列表请求参数
export interface GetUserPostsRequest {
  user_id: number;
  page?: number;
  pageSize?: number;
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

// 获取用户帖子列表
export const getUserPosts = async (
  param: GetUserPostsRequest
): Promise<ApiResponse<UserPostsResponse>> => {
  const user_id: number = param.user_id;
  const page: number = param.page || 1;
  const pageSize: number = param.pageSize || 20;
  const url: string = ApiConstants.ENDPOINTS.GET_USER_POSTS.replace('{user_id}', user_id.toString());
  const queryString: string = `page=${page}&page_size=${pageSize}`;
  
  return httpRequest.get<UserPostsResponse>(`${url}?${queryString}`);
}

export interface FollowUserData {
  message: string;
}

export const followUser = async (userId: string): Promise<ApiResponse<FollowUserData>> => {
  const url = ApiConstants.USER_ENDPOINTS.FOLLOW_USER.replace('{user_id}', userId);
  return httpRequest.post<FollowUserData>(url, {});
}

export const unfollowUser = async (userId: string): Promise<ApiResponse<FollowUserData>> => {
  const url = ApiConstants.USER_ENDPOINTS.FOLLOW_USER.replace('{user_id}', userId);
  return httpRequest.delete<FollowUserData>(url);
}

export interface FollowStatusData {
  is_following: boolean;
}

export const getFollowStatus = async (userId: string): Promise<ApiResponse<FollowStatusData>> => {
  const url = ApiConstants.USER_ENDPOINTS.GET_FOLLOW_STATUS.replace('{user_id}', userId);
  return httpRequest.get<FollowStatusData>(url);
}

export interface FollowingUserInfo {
  user_id: string;
  username: string;
  real_name: string;
  avatar_url: string;
  bio: string;
  follower_count: number;
  is_following: boolean;
  followed_at: number;
}

export interface FollowingListData {
  page: number;
  page_size: number;
  total: number;
  users: FollowingUserInfo[];
}

export const getFollowingList = async (userId: string): Promise<ApiResponse<FollowingListData>> => {
  const url = ApiConstants.USER_ENDPOINTS.GET_FOLLOWING_LIST.replace('{user_id}', userId);
  return httpRequest.get<FollowingListData>(url);
}