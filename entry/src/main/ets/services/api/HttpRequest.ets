import http from '@ohos.net.http';
import util from '@ohos.util';
import { ApiConstants } from './ApiConstants';
import { CreatePostParams } from './PostApi';
import { TokenManager } from '../TokenManager';

export { http };

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

class HttpRequest {
  private httpRequest: http.HttpRequest;
  private authToken: string = '';
  private noAuthPaths: string[] = [
    '/auth/register',
    '/auth/login'
  ];

  constructor() {
    this.httpRequest = http.createHttp();
  }

  setAuthToken(token: string): void {
    this.authToken = token;
  }

  addNoAuthPath(path: string): void {
    if (!this.noAuthPaths.includes(path)) {
      this.noAuthPaths.push(path);
    }
  }

  removeNoAuthPath(path: string): void {
    const index = this.noAuthPaths.indexOf(path);
    if (index > -1) {
      this.noAuthPaths.splice(index, 1);
    }
  }

  private isNoAuthPath(url: string): boolean {
    return this.noAuthPaths.some(path => url.includes(path));
  }

  private async getHeaders(url: string): Promise<Record<string, string>> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (!this.isNoAuthPath(url)) {
      let token = this.authToken;
      if (!token) {
        const tokenManager = TokenManager.getInstance();
        const savedToken = await tokenManager.getToken();
        if (savedToken) {
          token = savedToken;
          this.authToken = token;
        }
      }
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }

    return headers;
  }

  // 通用请求逻辑 - 泛型约束确保 D 兼容 RequestData
  private async request<T, D extends RequestData = RequestData>(
    method: http.RequestMethod,
    url: string,
    data?: D
  ): Promise<ApiResponse<T>> {
    // 如果 URL 以 http:// 或 https:// 开头，则直接使用，否则拼接 BASE_URL
    const fullUrl = url.startsWith('http://') || url.startsWith('https://')
      ? url
      : `${ApiConstants.BASE_URL}${url}`;

    let options: http.HttpRequestOptions;

    const isCreatePost = this.checkIsCreatePostParams(data);

    const headers = await this.getHeaders(fullUrl);

    if (isCreatePost) {
      const postData = data as CreatePostParams;
      const multipartData = this.buildMultipartFormData(postData);
      const multipartHeaders: Record<string, string> = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json'
      };
      if (headers['Authorization']) {
        multipartHeaders['Authorization'] = headers['Authorization'];
      }
      
      options = {
        method,
        header: multipartHeaders,
        readTimeout: ApiConstants.TIMEOUT,
        connectTimeout: ApiConstants.TIMEOUT,
        multiFormDataList: multipartData,
      };
    } else {
      options = {
        method,
        header: headers,
        readTimeout: ApiConstants.TIMEOUT,
        connectTimeout: ApiConstants.TIMEOUT,
        extraData: data ? JSON.stringify(data) : undefined,
      };
    }

    console.log('[HttpRequest] 发起请求:', method, fullUrl);
    console.log('[HttpRequest] 请求头:', JSON.stringify(options.header));
    console.log('[HttpRequest] Authorization:', options.header?.['Authorization'] || '未携带token');
    console.log('[HttpRequest] 请求数据类型:', isCreatePost ? 'multipart/form-data' : 'JSON');
    if (isCreatePost && options.multiFormDataList) {
      console.log('[HttpRequest] multipart 字段数量:', options.multiFormDataList.length);
    }

    try {
      const response = await this.httpRequest.request(fullUrl, options);

      console.log('[HttpRequest] 响应状态码:', response.responseCode);
      console.log('[HttpRequest] 响应结果:', response.result);

      if (response.responseCode === ApiConstants.HTTP_STATUS.SUCCESS) {
        return JSON.parse(response.result as string) as ApiResponse<T>;
      } else {
        // 尝试解析错误响应体，可能包含详细的错误信息
        try {
          const errorResponse = JSON.parse(response.result as string) as ApiResponse<T>;
          console.error('[HttpRequest] 请求失败:', response.responseCode, errorResponse.message);
          // 返回解析后的错误响应，而不是抛出异常
          return errorResponse;
        } catch (parseError) {
          // 如果无法解析响应体，则抛出原始错误
          console.error('[HttpRequest] 无法解析错误响应:', response.result);
          throw new Error(`HTTP ${response.responseCode}: ${response.result || '未知错误'}`);
        }
      }
    } catch (error) {
      if (error instanceof Error) {
        console.error('[HttpRequest] 请求异常:', error.message);
        console.error('[HttpRequest] 错误堆栈:', error.stack);
        throw error;
      } else {
        console.error('[HttpRequest] 请求异常:', JSON.stringify(error));
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

  /**
   * 构建 multipart/form-data 格式的数据
   * 用于文件上传（多图片上传）
   */
  private buildMultipartFormData(data: CreatePostParams): http.MultiFormData[] {
    const formData: http.MultiFormData[] = [];

    // 添加文本字段：title
    if (data.title) {
      formData.push({
        name: 'title',
        contentType: 'text/plain',
        data: new util.TextEncoder().encode(data.title).buffer
      });
      console.log('[HttpRequest] 添加字段 title:', data.title);
    }

    // 添加文本字段：description
    if (data.description) {
      formData.push({
        name: 'description',
        contentType: 'text/plain',
        data: new util.TextEncoder().encode(data.description).buffer
      });
      console.log('[HttpRequest] 添加字段 description:', data.description);
    }

    // 添加文本字段：tags（转为 JSON 字符串）
    if (data.tags && data.tags.length > 0) {
      formData.push({
        name: 'tags',
        contentType: 'text/plain',
        data: new util.TextEncoder().encode(JSON.stringify(data.tags)).buffer
      });
      console.log('[HttpRequest] 添加字段 tags:', data.tags);
    }

    // 添加文件字段：imageFiles（多个文件使用相同的 name）
    if (data.imageFiles && data.imageFiles.length > 0) {
      data.imageFiles.forEach((buffer: ArrayBuffer, index: number) => {
        // 生成文件名（根据实际情况可以优化，比如传入真实文件名）
        const fileName = `image_${index}.jpg`;
        
        formData.push({
          name: 'imageFiles',  // 使用相同的字段名，后端会接收为数组
          contentType: 'image/jpeg',  // MIME 类型，可以根据实际图片格式调整
          remoteFileName: fileName,
          data: buffer  // 直接使用 ArrayBuffer，不转 Base64
        });
        
        console.log(`[HttpRequest] 添加文件 [${index}]: ${fileName}, 大小: ${buffer.byteLength} bytes`);
      });
      console.log('[HttpRequest] 总共添加', data.imageFiles.length, '个文件');
    }

    console.log('[HttpRequest] multipart/form-data 构建完成，总字段数:', formData.length);
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