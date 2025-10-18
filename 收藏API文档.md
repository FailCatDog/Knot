# 收藏功能 API 文档

## API 路径

**基础 URL**: `http://43.142.157.145:8080/api/v1`

**收藏端点**: `/posts/{post_id}/favorite`

**完整路径**: `http://43.142.157.145:8080/api/v1/posts/{post_id}/favorite`

**请求方法**: POST

## 参数组装

### 路径参数
- `post_id`: string - 帖子ID

### 请求示例
```typescript
const postId = "123456";
const url = `/posts/${postId}/favorite`;
```

## 响应数据

### 成功响应
```typescript
interface FavoritePostData {
  post_id: string;
  favorite_count: number;
  has_favorited: boolean;
}
```

## 发送流程

### 1. 导入依赖
```typescript
import { favoritePost } from '../services/api/PostApi'
```

### 2. 调用方法
```typescript
const response = await favoritePost(postId)
```

### 3. 处理响应
```typescript
if (response.success) {
  // 收藏成功，更新UI状态
  this.postDetail.isFavorited = !this.postDetail.isFavorited
  this.postDetail.favoriteCount += this.postDetail.isFavorited ? 1 : -1
}
```

## 实现位置

- **API 定义**: `entry/src/main/ets/services/api/PostApi.ets`
- **API 常量**: `entry/src/main/ets/services/api/ApiConstants.ets`
- **调用位置**: `entry/src/main/ets/pages/PostDetailPage.ets`

## HTTP 请求实现

```typescript
export const favoritePost = async (postId: string): Promise<ApiResponse<FavoritePostData>> => {
  const url = ApiConstants.ENDPOINTS.FAVORITE_POST.replace('{post_id}', postId);
  return httpRequest.post<FavoritePostData>(url);
}
```

路径替换：`/posts/{post_id}/favorite` → `/posts/123456/favorite`

