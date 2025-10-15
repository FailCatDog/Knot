import http from '@ohos.net.http'
import { ApiConstants } from './ApiConstants'
// import { CreatePostParams } from './PostApi';
// 通用API响应结构（根据实际API响应格式调整）
export interface ApiResponse<T> {
  success: boolean;
  code: number;
  message: string;
  data: T
}

// HTTP响应结果接口
export interface HttpResponseResult {
  result: string | object
  responseCode: number
}

// 导出http模块，以便其他地方可以直接使用
export { http }

// 定义请求数据的基础类型（键值对结构）-wei
interface RequestData {
  key: string | number | boolean | object | undefined
}

// // 定义请求数据的基础类型-hgy
// type RequestData =
//   | Record<string, string | number | boolean | object | undefined>
//   | CreatePostParams;

interface FileUploadData {//-h
  filename: string;
  type: string;
  data: ArrayBuffer;
}

class HttpRequest {
  private httpRequest: http.HttpRequest
  private authToken: string = ''

  constructor() {
    this.httpRequest = http.createHttp()
  }

  setAuthToken(token: string): void {
    this.authToken = token
  }

  // 生成请求头（带认证逻辑）
  private getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`
    }
    return headers
  }

  // 通用请求逻辑（使用泛型明确数据类型）
  private async request<T, D = RequestData>(
    method: http.RequestMethod,
    url: string,
    data?: D
  ): Promise<ApiResponse<T>> {
    const fullUrl = `${ApiConstants.BASE_URL}${url}`
    const options: http.HttpRequestOptions = {
      method,
      header: this.getHeaders(),
      readTimeout: ApiConstants.TIMEOUT,
      connectTimeout: ApiConstants.TIMEOUT,
      extraData: data ? JSON.stringify(data) : undefined
    }

    const response: HttpResponseResult = await this.httpRequest.request(fullUrl, options) as HttpResponseResult

    if (response.responseCode === ApiConstants.HTTP_STATUS.SUCCESS) {
      const resultStr: string = response.result as string
      const parsedResponse: ApiResponse<T> = JSON.parse(resultStr) as ApiResponse<T>
      return parsedResponse
    } else {
      // 尝试解析错误响应中的消息
      const resultStr: string = response.result as string

      // 首先检查结果是否为空
      if (!resultStr) {
        const errorMsg: string = `HTTP ${response.responseCode}`
        throw new Error(errorMsg)
      }

      try {
        const errorResponse: ApiResponse<T> = JSON.parse(resultStr) as ApiResponse<T>
        if (errorResponse && typeof errorResponse === 'object' && errorResponse.message) {
          throw new Error(errorResponse.message)
        } else {
          const errorMsg: string = `HTTP ${response.responseCode}: ${resultStr}`
          throw new Error(errorMsg)
        }
      } catch (parseError) {
        // 如果是JSON解析错误，则直接使用原始响应文本
        if (parseError instanceof SyntaxError) {
          const errorMsg: string = `HTTP ${response.responseCode}: ${resultStr}`
          throw new Error(errorMsg)
        } else {
          // 如果是其他错误且已经是Error类型，则重新抛出
          if (parseError instanceof Error) {
            throw parseError
          } else {
            // 否则转换为Error类型再抛出
            const errorMsg: string = `HTTP ${response.responseCode}: ${String(parseError)}`
            throw new Error(errorMsg)
          }
        }
      }
    }
  }
  // GET请求
  async get<T>(url: string): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.GET, url)
  }

  // POST请求（使用泛型D明确请求数据类型）
  async post<T, D = RequestData>(url: string, data?: D): Promise<ApiResponse<T>> {
    return this.request<T, D>(http.RequestMethod.POST, url, data)
  }

  async put<T, D = RequestData>(url: string, data?: D): Promise<ApiResponse<T>> {
    return this.request<T, D>(http.RequestMethod.PUT, url, data)
  }

  // 销毁HTTP实例
  destroy(): void {
    this.httpRequest.destroy()
  }
}

export const httpRequest = new HttpRequest()