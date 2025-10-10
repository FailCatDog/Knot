import http from '@ohos.net.http'
import { ApiConstants } from './ApiConstants'

// 通用API响应结构
export interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

// 定义请求数据的基础类型（键值对结构）
type RequestData = Record<string, string | number | boolean | object | undefined>

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

    const response = await this.httpRequest.request(fullUrl, options)

    if (response.responseCode === ApiConstants.HTTP_STATUS.SUCCESS) {
      return JSON.parse(response.result as string) as ApiResponse<T>
    } else {
      throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
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

  // 销毁HTTP实例
  destroy(): void {
    this.httpRequest.destroy()
  }
}

export const httpRequest = new HttpRequest()
