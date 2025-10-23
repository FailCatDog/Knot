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
  CREATE_POST: string;
  GET_FEED: string;
  GET_POST_DETAIL: string;
  UPDATE_POST: string;
  DELETE_POST: string;
  GET_USER_POSTS: string;
  ADD_POST_IMAGE: string;
  DELETE_POST_IMAGE: string;
  UPDATE_POST_IMAGES_ORDER: string;
  FAVORITE_POST: string;
  GET_FAVORITE_STATUS: string;
  LIKE_POST: string;
  UNLIKE_POST: string;
  GET_LIKE_STATUS: string;
  SHARE_POST: string;
}

interface UserEndpoints {
  REGISTER: string;
  LOGIN: string;
  GET_USER_INFO: string;
  UPDATE_USER_INFO: string;
  CHANGE_PASSWORD: string;
  FOLLOW_USER: string;
  GET_FOLLOW_STATUS: string;
  GET_MY_FAVORITES: string;
  GET_USER_PUBLIC_INFO: string;
  GET_FOLLOWING_LIST: string;
  UPLOAD_AVATAR: string;
}

interface CommentEndpoints {
  CREATE_COMMENT: string;
  GET_COMMENTS: string;
  DELETE_COMMENT: string;
}

interface ShareEndpoints {
  CREATE_SHARE: string;
  GET_RECEIVED_SHARES: string;
  GET_SENT_SHARES: string;
  DELETE_SHARE: string;
}

export class ApiConstants {
  static readonly BASE_URL = 'http://43.142.157.145:8080/api/v1';
  static readonly TIMEOUT = 10000;

  static readonly ENDPOINTS: PostEndpoints = {
    CREATE_POST: '/posts',
    GET_FEED: '/posts',
    GET_POST_DETAIL: '/posts/{post_id}',
    UPDATE_POST: '/posts/{post_id}',
    DELETE_POST: '/posts/{post_id}',
    GET_USER_POSTS: '/users/{user_id}/posts',
    ADD_POST_IMAGE: '/posts/{post_id}/images',
    DELETE_POST_IMAGE: '/posts/{post_id}/images/{image_id}',
    UPDATE_POST_IMAGES_ORDER: '/posts/{post_id}/images/order',
    FAVORITE_POST: '/posts/{post_id}/favorite',
    GET_FAVORITE_STATUS: '/posts/{post_id}/favorite/status',
    LIKE_POST: '/posts/{post_id}/like',
    UNLIKE_POST: '/posts/{post_id}/like',
    GET_LIKE_STATUS: '/posts/{post_id}/like/status',
    SHARE_POST: '/shares/posts'
  };

  static readonly USER_ENDPOINTS: UserEndpoints = {
    REGISTER: '/auth/register',
    LOGIN: '/auth/login',
    GET_USER_INFO: '/users/profile',
    UPDATE_USER_INFO: '/users/profile',
    CHANGE_PASSWORD: '/auth/password',
    FOLLOW_USER: '/users/{user_id}/follow',
    GET_FOLLOW_STATUS: '/users/{user_id}/follow/status',
    GET_FOLLOWING_LIST: '/users/{user_id}/following',
    GET_MY_FAVORITES: '/my/favorites',
    GET_USER_PUBLIC_INFO: '/users/{user_id}',
    UPLOAD_AVATAR: '/users/avatar'
  };

  static readonly COMMENT_ENDPOINTS: CommentEndpoints = {
    CREATE_COMMENT: '/posts/{post_id}/comments',
    GET_COMMENTS: '/posts/{post_id}/comments',
    DELETE_COMMENT: '/posts/{post_id}/comments/{comment_id}'
  };

  static readonly SHARE_ENDPOINTS: ShareEndpoints = {
    CREATE_SHARE: '/shares/posts',
    GET_RECEIVED_SHARES: '/shares/received',
    GET_SENT_SHARES: '/shares/sent',
    DELETE_SHARE: '/shares/{share_id}'
  };

  static readonly HTTP_STATUS: HttpStatus = {
    SUCCESS: 200,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    NOT_FOUND: 404,
    SERVER_ERROR: 500
  };
}