import { submitImage, type CreatePostParams, type SubmitImageResponse } from '../services/api/PostApi';
import promptAction from '@ohos.promptAction';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

export class CreatePostViewModel {
  title: string = '';
  description: string = '';
  selectedImages: string[] = [];
  tags: string[] = [];

  isSubmitting: boolean = false;

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

  async submitPost(): Promise<void> {
    if (!this.validate() || this.isSubmitting) return;

    console.log('[CreatePostViewModel] 开始提交帖子');
    this.isSubmitting = true;

    const imageFiles: ArrayBuffer[] = [];

    console.log('[CreatePostViewModel] 开始读取图片，总数:', this.selectedImages.length);

    for (let i = 0; i < this.selectedImages.length; i++) {
      const imageUri = this.selectedImages[i];
      console.log('[CreatePostViewModel] 读取第', i + 1, '张图片:', imageUri);

      console.log('[CreatePostViewModel] 开始打开文件');
      const file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY);
      console.log('[CreatePostViewModel] 文件打开成功，fd:', file.fd);

      console.log('[CreatePostViewModel] 开始获取文件信息');
      const stat: fileIo.Stat = fileIo.statSync(file.fd);
      console.log('[CreatePostViewModel] 文件大小:', stat.size, 'bytes');

      console.log('[CreatePostViewModel] 开始创建buffer');
      const buffer = new ArrayBuffer(stat.size);
      console.log('[CreatePostViewModel] buffer创建成功');

      console.log('[CreatePostViewModel] 开始读取文件内容');
      fileIo.readSync(file.fd, buffer);
      console.log('[CreatePostViewModel] 文件内容读取成功');

      console.log('[CreatePostViewModel] 开始关闭文件');
      fileIo.closeSync(file);
      console.log('[CreatePostViewModel] 文件关闭成功');

      imageFiles.push(buffer);
      console.log('[CreatePostViewModel] 第', i + 1, '张图片处理完成');
    }

    console.log('[CreatePostViewModel] 所有图片读取完成，共', imageFiles.length, '张');

    const params: CreatePostParams = {
      title: this.title,
      description: this.description || undefined,
      imageFiles: imageFiles,
      tags: this.tags.length > 0 ? this.tags : undefined
    };

    console.log('[CreatePostViewModel] 请求参数:', {
      title: params.title,
      description: params.description,
      imageFilesCount: imageFiles.length,
      tags: params.tags
    });

    console.log('[CreatePostViewModel] 开始调用submitImage接口');
    const response = await submitImage(params);
    console.log('[CreatePostViewModel] submitImage接口调用完成');

    console.log('[CreatePostViewModel] 响应结果:', JSON.stringify(response));

    if (response.success && response.data) {
      console.log('[CreatePostViewModel] 发布成功');
      this.showSuccess('发布成功');
      router.back();
    } else {
      console.log('[CreatePostViewModel] 发布失败:', response.message);
      this.showError(response.message || '发布失败');
    }

    this.isSubmitting = false;
  }

  // 重置表单
  reset(): void {
    this.title = '';
    this.description = '';
    this.selectedImages = [];
    this.tags = [];
    this.isSubmitting = false;
  }

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
