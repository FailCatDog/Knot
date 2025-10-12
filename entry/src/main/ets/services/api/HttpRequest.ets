import http from '@ohos.net.http';
import { ApiConstants } from './ApiConstants';
import { CreatePostParams } from './PostApi';

// 通用API响应结构
export interface ApiResponse<T> {
  success: boolean;
  code: number;
  message: string;
  data: T;
}

// 定义请求数据的基础类型
type RequestData =
  | Record<string, string | number | boolean | object | undefined>
  | CreatePostParams;

interface FileUploadData {
  filename: string;
  type: string;
  data: ArrayBuffer;
}

class HttpRequest {
  private httpRequest: http.HttpRequest;
  private authToken: string = '';

  constructor() {
    this.httpRequest = http.createHttp();
  }

  setAuthToken(token: string): void {
    this.authToken = token;
  }

  // 生成请求头
  private getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }
    return headers;
  }

  // 通用请求逻辑 - 泛型约束确保 D 兼容 RequestData
  private async request<T, D extends RequestData = RequestData>(
    method: http.RequestMethod,
    url: string,
    data?: D
  ): Promise<ApiResponse<T>> {
    const fullUrl = `${ApiConstants.BASE_URL}${url}`;

    let options: http.HttpRequestOptions;

    const isCreatePost = this.checkIsCreatePostParams(data);

    if (isCreatePost) {
      const postData = data as CreatePostParams;
      const formData = this.createFormData(postData);
      const headers = this.getHeaders();
      headers['Content-Type'] = 'multipart/form-data';
      options = {
        method,
        header: headers,
        readTimeout: ApiConstants.TIMEOUT,
        connectTimeout: ApiConstants.TIMEOUT,
        extraData: formData,
      };
    } else {
      options = {
        method,
        header: this.getHeaders(),
        readTimeout: ApiConstants.TIMEOUT,
        connectTimeout: ApiConstants.TIMEOUT,
        extraData: data ? JSON.stringify(data) : undefined,
      };
    }

    console.log('[HttpRequest] 发起请求:', method, fullUrl);
    console.log('[HttpRequest] 请求头:', JSON.stringify(options.header));
    console.log('[HttpRequest] 请求数据类型:', isCreatePost ? 'FormData' : 'JSON');
    if (isCreatePost) {
      console.log('[HttpRequest] FormData字段:', Object.keys(options.extraData as object));
    }

    try {
      const response = await this.httpRequest.request(fullUrl, options);

      console.log('[HttpRequest] 响应状态码:', response.responseCode);
      console.log('[HttpRequest] 响应结果:', response.result);

      if (response.responseCode === ApiConstants.HTTP_STATUS.SUCCESS) {
        // 此处 response.result 为 http.ResponseResult 类型，断言为 string 安全（JSON 响应场景）
        return JSON.parse(response.result as string) as ApiResponse<T>;
      } else {
        console.error('[HttpRequest] 请求失败:', response.responseCode, response.result);
        // 确保 throw Error 实例（符合 arkts-limited-throw）
        throw new Error(`HTTP ${response.responseCode}: ${response.result || '未知错误'}`);
      }
    } catch (error) {
      console.error('[HttpRequest] 请求异常:', error);
      // 统一包装为 Error 实例抛出
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  private checkIsCreatePostParams(data: RequestData | undefined): boolean {
    if (!data || typeof data !== 'object') {
      return false;
    }
    const obj = data as CreatePostParams;
    return typeof obj.title === 'string' && Array.isArray(obj.imageFiles);
  }

  private createFormData(data: CreatePostParams): object {
    const formData: Record<string, string | FileUploadData[]> = {};

    if (data.title) formData.title = data.title;
    if (data.description) formData.description = data.description;

    if (data.tags && data.tags.length > 0) {
      formData.tags = JSON.stringify(data.tags);
    }

    if (data.imageFiles && data.imageFiles.length > 0) {
      const imageFilesArray: FileUploadData[] = [];
      data.imageFiles.forEach((buffer: ArrayBuffer, index: number) => {
        console.log('[HttpRequest] 添加图片文件:', index, 'buffer大小:', buffer.byteLength);
        imageFilesArray.push({
          filename: `image_${index}.jpg`,
          type: 'image/jpeg',
          data: buffer,
        });
      });
      formData.imageFiles = imageFilesArray;
      console.log('[HttpRequest] imageFiles数组长度:', imageFilesArray.length);
    }

    console.log('[HttpRequest] FormData创建完成，字段:', Object.keys(formData));
    return formData;
  }

  // GET请求
  async get<T>(url: string): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.GET, url);
  }

  // POST请求
  async post<T, D extends RequestData = RequestData>(url: string, data?: D): Promise<ApiResponse<T>> {
    return this.request<T, D>(http.RequestMethod.POST, url, data);
  }

  // PUT请求
  async put<T, D extends RequestData = RequestData>(url: string, data?: D): Promise<ApiResponse<T>> {
    return this.request<T, D>(http.RequestMethod.PUT, url, data);
  }

  // DELETE请求
  async delete<T>(url: string): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.DELETE, url);
  }

  // 销毁HTTP实例
  destroy(): void {
    this.httpRequest.destroy();
  }
}

export const httpRequest = new HttpRequest();