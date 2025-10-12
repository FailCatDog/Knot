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
 * 上传图片返回参数
 */
export interface ImageEntity {
  id: number;
  image_id: string;
  user_id: number;
  title: string;
  description: string;
  file_url: string;
  thumbnail_url: string;
  file_size: number;
  width: number;
  height: number;
  mime_type: string;
  like_count: number;
  favorite_count: number;
  view_count: number;
  status: "APPROVED" | "PENDING" | "REJECTED";
  create_time: number;
  update_time: number;
}
export interface PostEntity {
  id: number;
  post_id: string;
  user_id: number;
  title: string;
  description: string | null;
  image_count: number;
  like_count: number;
  favorite_count: number;
  view_count: number;
  share_count: number;
  comment_count: number;
  status: "APPROVED" | "PENDING" | "REJECTED";
  create_time: string;
  update_time: string;
  images: ImageEntity[];
  tags: string[];
}
export interface SubmitImageData {
  post: PostEntity;
}
export interface SubmitImageResponse {
  success: boolean;
  message: string;
  data: SubmitImageData;
  timestamp: number;
}
export interface GetPostsResponse {
  success: boolean;
  message: string;
  posts: PostEntity[];
  total: number;
  page: number;
  pageSize: number;
  timestamp: number;
}

export const submitImage = async (
  param: CreatePostParams
): Promise<ApiResponse<SubmitImageResponse>> => {
  console.log('[PostApi] submitImage 被调用，参数:', JSON.stringify({
    title: param.title,
    description: param.description,
    imageFilesCount: param.imageFiles.length,
    imageFilesSizes: param.imageFiles.map(buf => buf.byteLength),
    tags: param.tags
  }));
  return httpRequest.post<SubmitImageResponse, CreatePostParams>(
    ApiConstants.ENDPOINTS.CREATE_POST,
    param
  )
}

export interface GetPostDetailResponse {
  success: boolean;
  message: string;
  post: PostEntity;
  timestamp: number;
}

export const getPosts = async (page: number, pageSize: number): Promise<ApiResponse<GetPostsResponse>> => {
  console.log('[PostApi] getPosts 被调用，参数:', { page, pageSize });
  return httpRequest.get<GetPostsResponse>(`${ApiConstants.ENDPOINTS.GET_FEED}?page=${page}&pageSize=${pageSize}`);
}

export const getPostDetail = async (postId: string): Promise<ApiResponse<GetPostDetailResponse>> => {
  console.log('[PostApi] getPostDetail 被调用，参数:', { postId });
  const url = ApiConstants.ENDPOINTS.GET_POST_DETAIL.replace('{post_id}', postId);
  return httpRequest.get<GetPostDetailResponse>(url);
}
