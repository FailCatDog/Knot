import { httpRequest, ApiResponse } from './HttpRequest'
import { ApiConstants } from './ApiConstants'

export interface CommentAuthor {
  user_id: string;
  username: string;
  avatar_url: string;
}

export interface CommentEntity {
  comment_id: string;
  post_id: string;
  content: string;
  author: CommentAuthor;
  create_time: number;
  comment_count?: number;
}

export interface CreateCommentData {
  comment_id: string;
  post_id: string;
  content: string;
  author: CommentAuthor;
  create_time: number;
  comment_count: number;
}

export interface GetCommentsData {
  comments: CommentEntity[];
  total: number;
  page: number;
  page_size: number;
  has_more: boolean;
}

export interface DeleteCommentData {
  comment_id: string;
  comment_count: number;
}

export const createComment = async (postId: string, content: string): Promise<ApiResponse<CreateCommentData>> => {
  const url = ApiConstants.COMMENT_ENDPOINTS.CREATE_COMMENT.replace('{post_id}', postId);
  return httpRequest.post<CreateCommentData>(url, { content });
}

export const getComments = async (postId: string, page: number = 1, pageSize: number = 20): Promise<ApiResponse<GetCommentsData>> => {
  const url = ApiConstants.COMMENT_ENDPOINTS.GET_COMMENTS.replace('{post_id}', postId);
  return httpRequest.get<GetCommentsData>(`${url}?page=${page}&page_size=${pageSize}`);
}

export const deleteComment = async (postId: string, commentId: string): Promise<ApiResponse<DeleteCommentData>> => {
  const url = ApiConstants.COMMENT_ENDPOINTS.DELETE_COMMENT
    .replace('{post_id}', postId)
    .replace('{comment_id}', commentId);
  return httpRequest.delete<DeleteCommentData>(url);
}

