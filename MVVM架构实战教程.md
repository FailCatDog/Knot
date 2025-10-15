# HarmonyOS MVVM架构实战教程

## 📚 目录

1. [MVVM架构概述](#mvvm架构概述)
2. [项目结构说明](#项目结构说明)
3. [完整案例：创建帖子功能](#完整案例创建帖子功能)
4. [数据流转详解](#数据流转详解)
5. [最佳实践](#最佳实践)

---

## MVVM架构概述

### 什么是MVVM？

MVVM（Model-View-ViewModel）是一种软件架构模式，将应用程序分为三个核心组件：

```
┌──────────┐      ┌──────────────┐      ┌─────────┐      ┌─────────┐
│   View   │ ←──→ │  ViewModel   │ ←──→ │ Service │ ←──→ │  Model  │
│  (UI层)  │      │  (业务逻辑)   │      │ (API层)  │      │ (数据)  │
└──────────┘      └──────────────┘      └─────────┘      └─────────┘
```

- **Model（模型层）**：定义数据结构和实体
- **Service（服务层）**：处理网络请求、数据存储等
- **ViewModel（视图模型层）**：处理业务逻辑、数据验证、状态管理
- **View（视图层）**：负责UI展示和用户交互

### 为什么使用MVVM？

✅ **关注点分离**：UI、业务逻辑、数据分离，代码更清晰  
✅ **可测试性强**：ViewModel独立于UI，易于单元测试  
✅ **可维护性高**：修改业务逻辑不影响UI，反之亦然  
✅ **可复用性好**：ViewModel和Service可在多个页面复用  

---

## 项目结构说明

### 目录组织

```
entry/src/main/ets/
├── models/                    # Model层：数据模型
│   └── entities/
│       ├── PostEntity.ets     # 帖子实体
│       └── PostDetailEntity.ets
│
├── services/                  # Service层：服务和API
│   ├── api/
│   │   ├── HttpRequest.ets    # HTTP请求封装
│   │   ├── PostApi.ets        # 帖子相关API
│   │   └── ApiConstants.ets   # API常量配置
│   └── local/                 # 本地数据服务
│
├── viewmodels/                # ViewModel层：业务逻辑
│   ├── CreatePostViewModel.ets
│   ├── DiscoverViewModel.ets
│   └── PostDetailViewModel.ets
│
└── pages/                     # View层：页面视图
    ├── CreatePostPage.ets
    ├── MainPage.ets
    └── PostDetailPage.ets
```

---

## 完整案例：创建帖子功能

我们以**创建帖子**功能为例，完整演示MVVM架构的实现流程。

### 步骤1：定义Model（数据模型）

**文件位置**：`services/api/PostApi.ets`

```typescript
/**
 * 创建帖子的请求参数
 */
export interface CreatePostParams {
  title: string;              // 标题（必填）
  description?: string;       // 描述（可选）
  imageFiles: ArrayBuffer[];  // 图片文件数组（必填）
  tags?: string[];            // 标签（可选）
}

/**
 * 图片实体
 */
export interface ImageEntity {
  id: number;
  image_id: string;
  user_id: number;
  file_url: string;           // 图片URL
  thumbnail_url: string;      // 缩略图URL
  width: number;
  height: number;
  // ... 其他字段
}

/**
 * 帖子实体
 */
export interface PostEntity {
  id: number;
  post_id: string;
  user_id: number;
  title: string;
  description: string | null;
  image_count: number;
  like_count: number;
  create_time: string;
  images: ImageEntity[];      // 关联的图片数组
  tags: string[];
  // ... 其他字段
}

/**
 * 提交帖子的响应数据
 */
export interface SubmitImageResponse {
  success: boolean;
  message: string;
  data: {
    post: PostEntity;         // 返回创建的帖子信息
  };
  timestamp: number;
}
```

**说明**：
- 定义清晰的数据结构，明确必填和可选字段
- 使用TypeScript接口保证类型安全
- Model只包含数据定义，不包含业务逻辑

---

### 步骤2：实现Service层（API服务）

#### 2.1 HTTP请求基础封装

**文件位置**：`services/api/HttpRequest.ets`

```typescript
import http from '@ohos.net.http';
import util from '@ohos.util';

// 通用API响应结构
export interface ApiResponse<T> {
  success: boolean;
  code: number;
  message: string;
  data: T;
}

class HttpRequest {
  private httpRequest: http.HttpRequest;
  private authToken: string = '';

  constructor() {
    this.httpRequest = http.createHttp();
  }

  // 设置认证Token
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

  // POST请求封装
  async post<T, D extends RequestData = RequestData>(
    url: string, 
    data?: D
  ): Promise<ApiResponse<T>> {
    // 检查是否为文件上传请求
    const isCreatePost = this.checkIsCreatePostParams(data);
    
    let options: http.HttpRequestOptions;
    
    if (isCreatePost) {
      // 构建multipart/form-data格式数据
      const postData = data as CreatePostParams;
      const multipartData = this.buildMultipartFormData(postData);
      
      options = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': `Bearer ${this.authToken}`
        },
        multiFormDataList: multipartData,
      };
    } else {
      // 普通JSON请求
      options = {
        method: http.RequestMethod.POST,
        header: this.getHeaders(),
        extraData: data ? JSON.stringify(data) : undefined,
      };
    }

    const response = await this.httpRequest.request(url, options);
    
    if (response.responseCode === 200) {
      return JSON.parse(response.result as string) as ApiResponse<T>;
    } else {
      throw new Error(`HTTP ${response.responseCode}: ${response.result}`);
    }
  }

  /**
   * 构建multipart/form-data格式数据（用于文件上传）
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
    }

    // 添加文本字段：description
    if (data.description) {
      formData.push({
        name: 'description',
        contentType: 'text/plain',
        data: new util.TextEncoder().encode(data.description).buffer
      });
    }

    // 添加文本字段：tags（转为JSON字符串）
    if (data.tags && data.tags.length > 0) {
      formData.push({
        name: 'tags',
        contentType: 'text/plain',
        data: new util.TextEncoder().encode(JSON.stringify(data.tags)).buffer
      });
    }

    // 添加文件字段：imageFiles
    if (data.imageFiles && data.imageFiles.length > 0) {
      data.imageFiles.forEach((buffer: ArrayBuffer, index: number) => {
        formData.push({
          name: 'imageFiles',           // 使用相同字段名，后端接收为数组
          contentType: 'image/jpeg',
          remoteFileName: `image_${index}.jpg`,
          data: buffer                  // 直接使用ArrayBuffer
        });
      });
    }

    return formData;
  }

  // GET请求
  async get<T>(url: string): Promise<ApiResponse<T>> {
    // ... GET实现
  }
}

export const httpRequest = new HttpRequest();
```

**核心要点**：
- 封装通用的HTTP请求逻辑
- 支持JSON和multipart/form-data两种请求格式
- 统一的错误处理和响应格式
- 可复用的认证机制

#### 2.2 业务API接口

**文件位置**：`services/api/PostApi.ets`

```typescript
import { httpRequest } from './HttpRequest'
import { ApiResponse } from './HttpRequest'

/**
 * 提交帖子（创建帖子）
 */
export const submitImage = async (
  param: CreatePostParams
): Promise<ApiResponse<SubmitImageResponse>> => {
  console.log('[PostApi] 提交帖子，参数:', {
    title: param.title,
    description: param.description,
    imageFilesCount: param.imageFiles.length,
    tags: param.tags
  });
  
  return httpRequest.post<SubmitImageResponse, CreatePostParams>(
    'http://10.34.31.81:9001/api/v1/posts',
    param
  );
}

/**
 * 获取帖子列表
 */
export const getPosts = async (
  page: number, 
  pageSize: number
): Promise<ApiResponse<GetPostsResponse>> => {
  return httpRequest.get<GetPostsResponse>(
    `${ApiConstants.ENDPOINTS.GET_FEED}?page=${page}&pageSize=${pageSize}`
  );
}
```

**说明**：
- Service层只负责调用API，不包含业务逻辑
- 提供清晰的函数签名和类型定义
- 添加日志便于调试

---

### 步骤3：实现ViewModel（业务逻辑层）

**文件位置**：`viewmodels/CreatePostViewModel.ets`

```typescript
import { submitImage, type CreatePostParams } from '../services/api/PostApi';
import promptAction from '@ohos.promptAction';
import { router } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';

export class CreatePostViewModel {
  // === 状态数据 ===
  title: string = '';                   // 标题
  description: string = '';             // 描述
  selectedImages: string[] = [];        // 选中的图片URI列表
  tags: string[] = [];                  // 标签列表
  isSubmitting: boolean = false;        // 提交状态

  // === 数据设置方法 ===
  
  setTitle(title: string): void {
    this.title = title;
  }

  setDescription(desc: string): void {
    this.description = desc;
  }

  setImages(images: string[]): void {
    this.selectedImages = images;
  }

  addTag(tag: string): void {
    if (tag.trim() && !this.tags.includes(tag.trim())) {
      this.tags.push(tag.trim());
    }
  }

  removeTag(tag: string): void {
    const index = this.tags.indexOf(tag);
    if (index > -1) {
      this.tags.splice(index, 1);
    }
  }

  // === 数据验证 ===
  
  private validate(): boolean {
    if (!this.title.trim()) {
      this.showError('标题不能为空');
      return false;
    }
    if (this.selectedImages.length === 0) {
      this.showError('请选择至少一张图片');
      return false;
    }
    return true;
  }

  // === 核心业务逻辑：提交帖子 ===
  
  async submitPost(): Promise<void> {
    // 1. 防重复提交
    if (!this.validate() || this.isSubmitting) return;

    console.log('[CreatePostViewModel] 开始提交帖子');
    this.isSubmitting = true;

    try {
      // 2. 读取图片文件为ArrayBuffer
      const imageFiles: ArrayBuffer[] = [];
      for (let i = 0; i < this.selectedImages.length; i++) {
        const imageUri = this.selectedImages[i];
        const file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY);
        const stat = fileIo.statSync(file.fd);
        const buffer = new ArrayBuffer(stat.size);
        fileIo.readSync(file.fd, buffer);
        fileIo.closeSync(file);
        imageFiles.push(buffer);
      }

      // 3. 构建请求参数
      const params: CreatePostParams = {
        title: this.title,
        description: this.description || undefined,
        imageFiles: imageFiles,
        tags: this.tags.length > 0 ? this.tags : undefined
      };

      // 4. 调用API提交
      const response = await submitImage(params);

      // 5. 处理响应
      if (response.success && response.data) {
        console.log('[CreatePostViewModel] 发布成功');
        this.showSuccess('发布成功');
        router.back();  // 返回上一页
      } else {
        console.log('[CreatePostViewModel] 发布失败:', response.message);
        this.showError(response.message || '发布失败');
      }
    } catch (error) {
      console.error('[CreatePostViewModel] 提交异常:', error);
      this.showError('网络异常，请稍后重试');
    } finally {
      this.isSubmitting = false;
    }
  }

  // === 重置表单 ===
  
  reset(): void {
    this.title = '';
    this.description = '';
    this.selectedImages = [];
    this.tags = [];
    this.isSubmitting = false;
  }

  // === UI交互方法 ===
  
  private showError(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: 100
    });
  }

  private showSuccess(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: 100
    });
  }
}
```

**ViewModel核心职责**：
1. ✅ **状态管理**：维护页面所需的所有状态数据
2. ✅ **业务逻辑**：数据验证、数据转换、流程控制
3. ✅ **API调用**：通过Service层获取/提交数据
4. ✅ **UI交互**：提供方法供View层调用
5. ❌ **不包含UI代码**：不依赖任何UI组件

---

### 步骤4：实现View（视图层）

**文件位置**：`pages/CreatePostPage.ets`

```typescript
import { CreatePostViewModel } from '../viewmodels/CreatePostViewModel';
import { picker } from '@kit.CoreFileKit';

@Component
struct CreatePostPage {
  // === ViewModel实例 ===
  @State viewModel: CreatePostViewModel = new CreatePostViewModel();
  
  // === UI状态（View独有） ===
  @State titleInput: string = '';
  @State descriptionInput: string = '';
  @State selectedImageUris: string[] = [];
  @State tagInput: string = '';
  @Consume('NavPathStack') navPathStack: NavPathStack;

  // === 生命周期 ===
  
  aboutToDisappear(): void {
    this.viewModel.reset();  // 页面销毁时重置数据
  }

  // === UI构建 ===
  
  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        this.buildContent()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
  }

  // === Header部分 ===
  
  @Builder
  buildHeader() {
    Row() {
      // 返回按钮
      Button() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
      }
      .onClick(() => {
        this.navPathStack.pop();
      })

      Text('发布帖子')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 发布按钮
      Button('发布')
        .fontSize(14)
        .fontColor(this.canSubmit() ? '#FFFFFF' : '#999999')
        .backgroundColor(this.canSubmit() ? '#ffdd0223' : '#E5E5E5')
        .enabled(this.canSubmit() && !this.viewModel.isSubmitting)
        .onClick(() => {
          this.handleSubmit();  // 调用ViewModel方法
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 16, top: 20 })
  }

  // === Content部分 ===
  
  @Builder
  buildContent() {
    Scroll() {
      Column({ space: 16 }) {
        // 标题输入框
        Column({ space: 8 }) {
          Text('标题')
            .fontSize(14)
            .fontColor('#666666')

          TextInput({ 
            placeholder: '请输入标题', 
            text: this.titleInput 
          })
            .onChange((value: string) => {
              this.titleInput = value;
              this.viewModel.setTitle(value);  // 同步到ViewModel
            })
        }

        // 描述输入框
        Column({ space: 8 }) {
          Text('描述(可选)')
            .fontSize(14)
            .fontColor('#666666')

          TextArea({ 
            placeholder: '请输入描述...', 
            text: this.descriptionInput 
          })
            .height(120)
            .onChange((value: string) => {
              this.descriptionInput = value;
              this.viewModel.setDescription(value);  // 同步到ViewModel
            })
        }

        // 图片选择区域
        Column({ space: 8 }) {
          Text('图片')
            .fontSize(14)
            .fontColor('#666666')

          Flex({ wrap: FlexWrap.Wrap }) {
            // 已选图片展示
            ForEach(this.selectedImageUris, (uri: string, index: number) => {
              Stack({ alignContent: Alignment.TopEnd }) {
                Image(uri)
                  .width(100)
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)

                // 删除按钮
                Button() {
                  Image($r('app.media.ic_close'))
                    .width(16)
                    .height(16)
                }
                .onClick(() => {
                  this.removeImage(index);  // 移除图片
                })
              }
            })

            // 添加图片按钮
            if (this.selectedImageUris.length < 9) {
              Button() {
                Column({ space: 4 }) {
                  Image($r('app.media.ic_add'))
                    .width(32)
                    .height(32)
                  Text('添加图片')
                    .fontSize(12)
                }
              }
              .width(100)
              .height(100)
              .onClick(() => {
                this.selectImages();  // 选择图片
              })
            }
          }
        }

        // 标签输入区域
        Column({ space: 8 }) {
          Text('标签(可选)')
            .fontSize(14)
            .fontColor('#666666')

          // 已添加的标签
          if (this.viewModel.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.viewModel.tags, (tag: string) => {
                Row({ space: 4 }) {
                  Text('#' + tag)
                    .fontSize(14)
                  
                  Image($r('app.media.ic_close'))
                    .width(14)
                    .height(14)
                    .onClick(() => {
                      this.viewModel.removeTag(tag);  // 移除标签
                    })
                }
                .padding(8)
                .backgroundColor('#FFF5F5')
                .borderRadius(16)
              })
            }
          }

          // 标签输入框
          Row({ space: 8 }) {
            TextInput({ 
              placeholder: '输入标签', 
              text: this.tagInput 
            })
              .layoutWeight(1)
              .onChange((value: string) => {
                this.tagInput = value;
              })

            Button('添加')
              .onClick(() => {
                if (this.tagInput.trim()) {
                  this.viewModel.addTag(this.tagInput);  // 添加标签到ViewModel
                  this.tagInput = '';
                }
              })
          }
        }
      }
      .padding(16)
    }
    .layoutWeight(1)
  }

  // === 业务方法 ===

  /**
   * 选择图片
   */
  async selectImages() {
    const photoSelectOptions = new picker.PhotoSelectOptions();
    photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 9 - this.selectedImageUris.length;

    const photoPicker = new picker.PhotoViewPicker();
    const result = await photoPicker.select(photoSelectOptions);

    if (result && result.photoUris && result.photoUris.length > 0) {
      // 更新UI状态
      this.selectedImageUris.push(...result.photoUris);
      // 同步到ViewModel
      this.viewModel.setImages([...this.viewModel.selectedImages, ...result.photoUris]);
    }
  }

  /**
   * 移除图片
   */
  removeImage(index: number) {
    this.selectedImageUris.splice(index, 1);
    this.viewModel.selectedImages.splice(index, 1);
    this.viewModel.setImages([...this.viewModel.selectedImages]);
  }

  /**
   * 检查是否可以提交
   */
  canSubmit(): boolean {
    return this.titleInput.trim().length > 0 && 
           this.selectedImageUris.length > 0;
  }

  /**
   * 提交表单
   */
  async handleSubmit() {
    if (!this.canSubmit()) return;
    await this.viewModel.submitPost();  // 调用ViewModel的提交方法
  }
}
```

**View层核心职责**：
1. ✅ **UI渲染**：构建界面元素
2. ✅ **用户交互**：响应用户操作（点击、输入等）
3. ✅ **状态同步**：将用户输入同步到ViewModel
4. ✅ **调用ViewModel**：通过ViewModel处理业务逻辑
5. ❌ **不包含业务逻辑**：只负责UI相关的操作

---

## 数据流转详解

### 完整数据流程图

```
用户操作 → View → ViewModel → Service → API
   ↑                                      ↓
   └──────── 结果展示 ←─────────────── 响应数据
```

### 详细流程说明

#### 1️⃣ **用户输入阶段**（View → ViewModel）

```typescript
// View层：监听用户输入
TextInput({ text: this.titleInput })
  .onChange((value: string) => {
    this.titleInput = value;           // 1. 更新View自己的状态
    this.viewModel.setTitle(value);    // 2. 同步到ViewModel
  })

// ViewModel层：接收并存储数据
setTitle(title: string): void {
  this.title = title;  // 存储在ViewModel中
}
```

**关键点**：
- View层维护UI状态（用于界面渲染）
- ViewModel维护业务数据（用于逻辑处理）
- 数据通过setter方法单向传递

---

#### 2️⃣ **提交数据阶段**（ViewModel → Service → API）

```typescript
// View层：触发提交
Button('发布')
  .onClick(() => {
    this.handleSubmit();  // 调用View的方法
  })

handleSubmit() {
  await this.viewModel.submitPost();  // 调用ViewModel的方法
}

// ViewModel层：处理业务逻辑
async submitPost(): Promise<void> {
  // 步骤1：数据验证
  if (!this.validate()) return;
  
  // 步骤2：数据转换（读取图片文件）
  const imageFiles: ArrayBuffer[] = [];
  for (let imageUri of this.selectedImages) {
    const buffer = await this.readImageFile(imageUri);
    imageFiles.push(buffer);
  }
  
  // 步骤3：构建请求参数
  const params: CreatePostParams = {
    title: this.title,
    description: this.description,
    imageFiles: imageFiles,
    tags: this.tags
  };
  
  // 步骤4：调用Service层API
  const response = await submitImage(params);
  
  // 步骤5：处理结果
  if (response.success) {
    this.showSuccess('发布成功');
    router.back();
  } else {
    this.showError(response.message);
  }
}

// Service层：调用API
export const submitImage = async (
  param: CreatePostParams
): Promise<ApiResponse<SubmitImageResponse>> => {
  return httpRequest.post<SubmitImageResponse, CreatePostParams>(
    'http://api.example.com/posts',
    param
  );
}

// HttpRequest层：发送HTTP请求
async post<T, D>(url: string, data?: D): Promise<ApiResponse<T>> {
  // 构建multipart/form-data
  const formData = this.buildMultipartFormData(data);
  
  // 发送请求
  const response = await this.httpRequest.request(url, {
    method: http.RequestMethod.POST,
    header: { 'Content-Type': 'multipart/form-data' },
    multiFormDataList: formData
  });
  
  // 返回解析后的结果
  return JSON.parse(response.result);
}
```

**数据传递链路**：
```
View.handleSubmit() 
  → ViewModel.submitPost() 
    → Service.submitImage() 
      → HttpRequest.post() 
        → API服务器
```

---

#### 3️⃣ **响应处理阶段**（API → Service → ViewModel → View）

```typescript
// API响应数据（JSON格式）
{
  "success": true,
  "message": "创建成功",
  "data": {
    "post": {
      "post_id": "123456",
      "title": "我的帖子",
      "user_id": 1,
      "create_time": "2024-01-01 12:00:00",
      "images": [...]
    }
  },
  "timestamp": 1704096000
}

// HttpRequest层：解析响应
return JSON.parse(response.result) as ApiResponse<T>;

// Service层：直接返回
return httpRequest.post<SubmitImageResponse>(...);

// ViewModel层：处理响应
const response = await submitImage(params);
if (response.success && response.data) {
  // 成功处理
  this.showSuccess('发布成功');
  router.back();  // 返回上一页
} else {
  // 失败处理
  this.showError(response.message || '发布失败');
}

// View层：界面自动更新
// 由于ViewModel的状态改变，绑定的UI会自动刷新
// 例如：isSubmitting变为false，按钮恢复可点击状态
```

**响应处理链路**：
```
API响应 
  → HttpRequest解析 
    → Service返回 
      → ViewModel处理 
        → View更新
```

---

## 最佳实践

### ✅ DO（推荐做法）

#### 1. **单一职责原则**

```typescript
// ✅ 正确：ViewModel只处理业务逻辑
export class CreatePostViewModel {
  async submitPost(): Promise<void> {
    const response = await submitImage(params);
    if (response.success) {
      this.showSuccess('发布成功');
    }
  }
}

// ✅ 正确：Service只负责API调用
export const submitImage = async (params: CreatePostParams) => {
  return httpRequest.post('/api/posts', params);
}

// ✅ 正确：View只负责UI渲染
Button('发布')
  .onClick(() => this.viewModel.submitPost())
```

#### 2. **数据验证在ViewModel**

```typescript
// ✅ 正确：在ViewModel中统一验证
private validate(): boolean {
  if (!this.title.trim()) {
    this.showError('标题不能为空');
    return false;
  }
  if (this.selectedImages.length === 0) {
    this.showError('请选择至少一张图片');
    return false;
  }
  return true;
}
```

#### 3. **使用TypeScript类型**

```typescript
// ✅ 正确：明确的类型定义
export interface CreatePostParams {
  title: string;
  description?: string;
  imageFiles: ArrayBuffer[];
  tags?: string[];
}

// ✅ 正确：函数签名带类型
async submitImage(
  param: CreatePostParams
): Promise<ApiResponse<SubmitImageResponse>> {
  // ...
}
```

#### 4. **异步操作错误处理**

```typescript
// ✅ 正确：使用try-catch捕获异常
async submitPost(): Promise<void> {
  try {
    const response = await submitImage(params);
    if (response.success) {
      this.showSuccess('发布成功');
    } else {
      this.showError(response.message);
    }
  } catch (error) {
    console.error('提交异常:', error);
    this.showError('网络异常，请稍后重试');
  } finally {
    this.isSubmitting = false;
  }
}
```

#### 5. **状态管理**

```typescript
// ✅ 正确：使用@State装饰器管理状态
@Component
struct CreatePostPage {
  @State viewModel: CreatePostViewModel = new CreatePostViewModel();
  @State titleInput: string = '';
  
  // 状态变化时UI自动更新
}
```

---

### ❌ DON'T（避免做法）

#### 1. **不要在View中写业务逻辑**

```typescript
// ❌ 错误：在View中直接调用API
@Component
struct CreatePostPage {
  async handleSubmit() {
    // ❌ 不要这样做！
    const response = await submitImage(params);
    if (response.success) {
      router.back();
    }
  }
}

// ✅ 正确：通过ViewModel处理
async handleSubmit() {
  await this.viewModel.submitPost();
}
```

#### 2. **不要在ViewModel中引用UI组件**

```typescript
// ❌ 错误：ViewModel依赖UI组件
export class CreatePostViewModel {
  async submitPost(): Promise<void> {
    // ❌ 不要这样做！
    Button('发布').enabled(false);
  }
}

// ✅ 正确：通过状态控制
export class CreatePostViewModel {
  isSubmitting: boolean = false;
  
  async submitPost(): Promise<void> {
    this.isSubmitting = true;  // View会根据状态禁用按钮
    // ...
  }
}
```

#### 3. **不要在Service中处理业务逻辑**

```typescript
// ❌ 错误：在Service中验证数据
export const submitImage = async (params: CreatePostParams) => {
  // ❌ 不要这样做！
  if (!params.title) {
    throw new Error('标题不能为空');
  }
  return httpRequest.post('/api/posts', params);
}

// ✅ 正确：Service只负责API调用，验证在ViewModel
export const submitImage = async (params: CreatePostParams) => {
  return httpRequest.post('/api/posts', params);
}
```

#### 4. **不要直接修改Model数据**

```typescript
// ❌ 错误：直接修改接口返回的数据
const response = await getPosts();
response.data.posts[0].title = '新标题';  // ❌ 不要这样做！

// ✅ 正确：创建新的对象
const post = { ...response.data.posts[0], title: '新标题' };
```

---

## 总结

### MVVM架构的核心要点

| 层级 | 文件位置 | 主要职责 | 不应该做 |
|------|---------|---------|----------|
| **Model** | `models/entities/` | 定义数据结构 | 包含业务逻辑 |
| **Service** | `services/api/` | API调用、数据存储 | 数据验证、UI交互 |
| **ViewModel** | `viewmodels/` | 业务逻辑、状态管理 | 引用UI组件 |
| **View** | `pages/`, `views/` | UI渲染、用户交互 | 直接调用API |

### 数据流转规则

1. **单向数据流**：View → ViewModel → Service → API
2. **响应回流**：API → Service → ViewModel → View
3. **状态驱动UI**：ViewModel的状态改变，View自动更新
4. **事件驱动逻辑**：用户操作触发事件，调用ViewModel方法

### 关键优势

- 🎯 **清晰的代码结构**：每层职责明确，易于理解和维护
- 🧪 **高可测试性**：ViewModel可独立测试，无需UI环境
- ♻️ **高复用性**：ViewModel和Service可在多个页面复用
- 🔧 **易于维护**：修改业务逻辑不影响UI，修改UI不影响逻辑
- 👥 **团队协作友好**：前端和后端可并行开发

---

## 附录：完整代码清单

### 文件清单

```
entry/src/main/ets/
├── models/entities/
│   └── (在PostApi.ets中定义)
├── services/api/
│   ├── HttpRequest.ets          # HTTP请求封装
│   ├── PostApi.ets              # 帖子API接口
│   └── ApiConstants.ets         # API常量
├── viewmodels/
│   └── CreatePostViewModel.ets  # 创建帖子ViewModel
└── pages/
    └── CreatePostPage.ets       # 创建帖子页面
```

### 代码行数统计

- **Model定义**：~60行
- **Service层**：~210行（HttpRequest）+ ~50行（PostApi）
- **ViewModel层**：~130行
- **View层**：~300行

**总计**：约750行代码实现完整的创建帖子功能

---

**编写日期**：2024年  
**适用于**：HarmonyOS Next（API 12+）  
**架构模式**：MVVM（Model-View-ViewModel）

