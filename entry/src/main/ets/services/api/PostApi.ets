/**
 * 图片模块API实现
 */
import { httpRequest } from './HttpRequest'
import { ApiConstants } from './ApiConstants'
import { ApiResponse } from './HttpRequest'

/**
 * 创建帖子的请求参数
 * 注意：必填字段标记为非可选，可选字段标记为?
 */
export interface CreatePostParams {
  title: string;
  description?: string;
  imageFiles: ArrayBuffer[];
  tags?: string[];
}
/**
 * 图片实体
 */
export interface ImageEntity {
  image_id: string;
  post_id: number;
  display_order: number;
  file_url: string;
  thumbnail_url: string;
  file_size: number;
  width: number;
  height: number;
  mime_type: string;
  create_time: number;
}
export interface PostAuthor {
  user_id: number;
  username: string;
  avatar_url: string;
}

export interface PostEntity {
  post_id: string;
  user_id: number | string;
  username?: string;
  avatar_url?: string;
  author?: PostAuthor;
  title: string;
  description: string | null;
  image_count: number;
  like_count: number;
  has_liked: boolean;
  favorite_count: number;
  has_favorited: boolean;
  view_count: number;
  status: "APPROVED" | "PENDING" | "REJECTED";
  create_time: number;
  update_time: number;
  images: ImageEntity[];
}
export interface SubmitImageData {
  post: PostEntity;
}

export interface GetPostsData {
  posts: PostEntity[];
  total: number;
  page: number;
  page_size: number;
}

// 帖子详情页面参数
export interface PostDetailParam {
  post_id: string
  user_id?: number | string
  title?: string
  description?: string
  like_count?: number
  create_time?: string
  image_urls?: string[]
}

export const submitImage = async (
  param: CreatePostParams
): Promise<ApiResponse<SubmitImageData>> => {
  return httpRequest.post<SubmitImageData, CreatePostParams>(
    ApiConstants.ENDPOINTS.CREATE_POST,
    param
  )
}

export interface GetPostDetailData {
  post: PostEntity;
}

export const getPosts = async (page: number, pageSize: number): Promise<ApiResponse<GetPostsData>> => {
  console.log('[PostApi] getPosts 被调用，参数:', { page, pageSize });
  return httpRequest.get<GetPostsData>(`${ApiConstants.ENDPOINTS.GET_FEED}?page=${page}&page_size=${pageSize}`);
}

export const getPostDetail = async (postId: string): Promise<ApiResponse<GetPostDetailData>> => {
  console.log('[PostApi] getPostDetail 被调用，参数:', { postId });
  const url = ApiConstants.ENDPOINTS.GET_POST_DETAIL.replace('{post_id}', postId);
  return httpRequest.get<GetPostDetailData>(url);
}

export interface FavoritePostData {
  post_id: string;
  favorite_count: number;
  has_favorited: boolean;
}

export const favoritePost = async (postId: string): Promise<ApiResponse<FavoritePostData>> => {
  console.log('[PostApi] favoritePost 被调用，参数:', { postId });
  const url = ApiConstants.ENDPOINTS.FAVORITE_POST.replace('{post_id}', postId);
  return httpRequest.post<FavoritePostData>(url, {});
}

export const unfavoritePost = async (postId: string): Promise<ApiResponse<FavoritePostData>> => {
  console.log('[PostApi] unfavoritePost 被调用，参数:', { postId });
  const url = ApiConstants.ENDPOINTS.FAVORITE_POST.replace('{post_id}', postId);
  return httpRequest.delete<FavoritePostData>(url);
}

export interface FavoriteStatusData {
  has_favorited: boolean;
}

export const getFavoriteStatus = async (postId: string): Promise<ApiResponse<FavoriteStatusData>> => {
  const url = ApiConstants.ENDPOINTS.GET_FAVORITE_STATUS.replace('{post_id}', postId);
  return httpRequest.get<FavoriteStatusData>(url);
}

export interface LikePostData {
  post_id: string;
  like_count: number;
  has_liked: boolean;
}

export const likePost = async (postId: string): Promise<ApiResponse<LikePostData>> => {
  const url = ApiConstants.ENDPOINTS.LIKE_POST.replace('{post_id}', postId);
  return httpRequest.post<LikePostData>(url, {});
}

export const unlikePost = async (postId: string): Promise<ApiResponse<LikePostData>> => {
  const url = ApiConstants.ENDPOINTS.UNLIKE_POST.replace('{post_id}', postId);
  return httpRequest.delete<LikePostData>(url);
}

export interface LikeStatusData {
  has_liked: boolean;
}

export const getLikeStatus = async (postId: string): Promise<ApiResponse<LikeStatusData>> => {
  const url = ApiConstants.ENDPOINTS.GET_LIKE_STATUS.replace('{post_id}', postId);
  return httpRequest.get<LikeStatusData>(url);
}

export const getUserPosts = async (userId: string, page: number = 1, pageSize: number = 20): Promise<ApiResponse<GetPostsData>> => {
  const url = ApiConstants.ENDPOINTS.GET_USER_POSTS.replace('{user_id}', userId);
  return httpRequest.get<GetPostsData>(`${url}?page=${page}&page_size=${pageSize}`);
}