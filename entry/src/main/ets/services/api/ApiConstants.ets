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

// 图片 API 端点
interface ImageEndpoints {
  // 上传图片
  UPLOAD_IMAGE: string;
  // 获取最新图片列表
  GET_LATEST_IMAGES: string;
  // 获取图片详情
  GET_IMAGE_DETAIL: string;
  // 更新图文配文
  UPDATE_IMAGE_CAPTION: string;
  // 删除图片
  DELETE_IMAGE: string;
  // 获取用户图片列表
  GET_USER_IMAGES: string;
}

export class ApiConstants {
  // 基础 API 地址
  static readonly BASE_URL = 'http://localhost:8080/api';
  // 请求超时时间（毫秒）
  static readonly TIMEOUT = 10000;

  // 图片相关 API 端点
  static readonly ENDPOINTS: ImageEndpoints = {
    UPLOAD_IMAGE: '/images',
    GET_LATEST_IMAGES: '/images',
    GET_IMAGE_DETAIL: '/images/{id}',
    UPDATE_IMAGE_CAPTION: '/images/{id}',
    DELETE_IMAGE: '/images/{id}',
    GET_USER_IMAGES: '/users/{id}/images'
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