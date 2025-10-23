import { httpRequest } from './HttpRequest'
import { ApiConstants } from './ApiConstants'
import { ApiResponse } from './HttpRequest'

// 分享请求参数
export interface CreateShareRequest extends Record<string, string | number | boolean | object | undefined> {
  post_id: string
  receiver_id: string
  share_message?: string
}

// 分享响应数据
export interface ShareData {
  share_id: string
  create_time: number
}

// 分享用户信息
export interface ShareUserInfo {
  id: number
  user_id: string
  username: string
  avatar_url: string
  bio: string
}

// 分享帖子信息
export interface SharePostInfo {
  id: number
  post_id: string
  title: string
  description: string
  cover_image: string
  like_count: number
  favorite_count: number
}

// 分享记录
export interface ShareRecord {
  share_id: string
  share_message: string
  create_time: number
  post: SharePostInfo
  sender?: ShareUserInfo  // 收到的分享有发送者信息
  receiver?: ShareUserInfo // 发出的分享有接收者信息
}

// 分享列表响应
export interface ShareListResponse {
  total: number
  page: number
  page_size: number
  has_more: boolean
  shares: ShareRecord[]
}

// 获取分享列表请求参数
export interface GetShareListRequest {
  page?: number
  page_size?: number
}

/**
 * 创建分享
 */
export const createShare = async (
  param: CreateShareRequest
): Promise<ApiResponse<ShareData>> => {
  return httpRequest.post<ShareData, CreateShareRequest>(
    ApiConstants.SHARE_ENDPOINTS.CREATE_SHARE,
    param
  )
}

/**
 * 获取收到的分享列表
 */
export const getReceivedShares = async (
  param?: GetShareListRequest
): Promise<ApiResponse<ShareListResponse>> => {
  const page = param?.page || 1
  const pageSize = param?.page_size || 10
  const queryString = `page=${page}&page_size=${pageSize}`
  
  return httpRequest.get<ShareListResponse>(
    `${ApiConstants.SHARE_ENDPOINTS.GET_RECEIVED_SHARES}?${queryString}`
  )
}

/**
 * 获取发出的分享列表
 */
export const getSentShares = async (
  param?: GetShareListRequest
): Promise<ApiResponse<ShareListResponse>> => {
  const page = param?.page || 1
  const pageSize = param?.page_size || 10
  const queryString = `page=${page}&page_size=${pageSize}`
  
  return httpRequest.get<ShareListResponse>(
    `${ApiConstants.SHARE_ENDPOINTS.GET_SENT_SHARES}?${queryString}`
  )
}

/**
 * 删除分享记录
 */
export const deleteShare = async (
  shareId: string
): Promise<ApiResponse<null>> => {
  const url = ApiConstants.SHARE_ENDPOINTS.DELETE_SHARE.replace('{share_id}', shareId)
  return httpRequest.delete<null>(url)
}
