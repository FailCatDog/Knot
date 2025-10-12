/**
 * 全局API统一管理
 */

interface HttpStatus {
  SUCCESS: number;
  BAD_REQUEST: number;
  UNAUTHORIZED: number;
  NOT_FOUND: number;
  SERVER_ERROR: number;
}

// 帖子 API 端点
interface PostEndpoints {
  // 创建帖子
  CREATE_POST: string;
  // 获取Feed流
  GET_FEED: string;
  // 获取帖子详情
  GET_POST_DETAIL: string;
  // 更新帖子
  UPDATE_POST: string;
  // 删除帖子
  DELETE_POST: string;
  // 获取用户帖子列表
  GET_USER_POSTS: string;
  // 向帖子添加图片
  ADD_POST_IMAGE: string;
  // 删除帖子中的图片
  DELETE_POST_IMAGE: string;
  // 调整帖子图片顺序
  UPDATE_POST_IMAGES_ORDER: string;
}

export class ApiConstants {
  // 基础 API 地址
  static readonly BASE_URL = 'http://8.138.115.164:8080/api/v1';
  // 请求超时时间（毫秒）
  static readonly TIMEOUT = 10000;

  // 帖子相关 API 端点
  static readonly ENDPOINTS: PostEndpoints = {
    CREATE_POST: '/posts',
    GET_FEED: '/posts',
    GET_POST_DETAIL: '/posts/{post_id}',
    UPDATE_POST: '/posts/{post_id}',
    DELETE_POST: '/posts/{post_id}',
    GET_USER_POSTS: '/users/{user_id}/posts',
    ADD_POST_IMAGE: '/posts/{post_id}/images',
    DELETE_POST_IMAGE: '/posts/{post_id}/images/{image_id}',
    UPDATE_POST_IMAGES_ORDER: '/posts/{post_id}/images/order'
  };

  // HTTP 状态码
  static readonly HTTP_STATUS: HttpStatus = {
    SUCCESS: 200,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    NOT_FOUND: 404,
    SERVER_ERROR: 500
  };
}