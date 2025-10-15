// /**
//  * 图片模块API实现
//  */
// import { httpRequest } from './HttpRequest'
// import { ApiConstants } from './ApiConstants'
// import { ApiResponse } from './HttpRequest'
//
// /**
//  * 上传图片参数
//  */
// export interface SubmitImageParam {
//   image: string,
//   title: string,
//   description: string,
//   tags: string
// }
// /**
//  * 上传图片返回参数
//  */
// // 1. 图片实体接口
// export interface ImageEntity {
//   id: number;
//   image_id: string;
//   user_id: number;
//   title: string;
//   description: string;
//   file_url: string;
//   thumbnail_url: string;
//   file_size: number;
//   width: number;
//   height: number;
//   mime_type: string;
//   like_count: number;
//   favorite_count: number;
//   view_count: number;
//   status: "APPROVED" | "PENDING" | "REJECTED";
//   create_time: number;
//   update_time: number;
// }
// // 2. 最外层响应接口
// export interface SubmitImageResponse<T = ImageEntity> {
//   success: boolean;
//   message: string;
//   data: T;
//   timestamp: number;
// }
// export const submitImage = async (
//   param: SubmitImageParam
// ): Promise<ApiResponse<SubmitImageResponse>> => {
//   return httpRequest.post<SubmitImageResponse, SubmitImageParam>(
//     ApiConstants.ENDPOINTS.UPLOAD_IMAGE,
//     param
//   )
// }
