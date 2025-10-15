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
// 帖子 API 端点 -hgy
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

// // 图片 API 端点
// interface ImageEndpoints {
//   // 上传图片
//   UPLOAD_IMAGE: string;
//   // 获取最新图片列表
//   GET_LATEST_IMAGES: string;
//   // 获取图片详情
//   GET_IMAGE_DETAIL: string;
//   // 更新图文配文
//   UPDATE_IMAGE_CAPTION: string;
//   // 删除图片
//   DELETE_IMAGE: string;
//   // 获取用户图片列表
//   GET_USER_IMAGES: string;
// }

// 用户 API 端点-玮
interface UserEndpoints {
  // 用户注册
  REGISTER: string;
  // 用户登录
  LOGIN: string;
  // 获取用户信息
  GET_USER_INFO: string;
  // 更新用户信息
  UPDATE_USER_INFO: string;
  // 修改密码
  CHANGE_PASSWORD: string;
}


export class ApiConstants {
  // 基础 API 地址
  static readonly BASE_URL = 'http://8.138.115.164:8080/api/v1';
  // 请求超时时间（毫秒）
  static readonly TIMEOUT = 10000;

  // // 图片相关 API 端点
  // static readonly ENDPOINTS: ImageEndpoints = {
  //   UPLOAD_IMAGE: '/images',
  //   GET_LATEST_IMAGES: '/images',
  //   GET_IMAGE_DETAIL: '/images/{id}',
  //   UPDATE_IMAGE_CAPTION: '/images/{id}',
  //   DELETE_IMAGE: '/images/{id}',
  //   GET_USER_IMAGES: '/users/{id}/images'
  // };

  // 用户相关 API 端点 - wei
  static readonly USER_ENDPOINTS: UserEndpoints = {
    REGISTER: '/auth/register',
    LOGIN: '/auth/login',
    GET_USER_INFO: '/users/profile',
    UPDATE_USER_INFO: '/users/profile',
    CHANGE_PASSWORD: '/auth/password'
  };

  // 帖子相关 API 端点 -hgy
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