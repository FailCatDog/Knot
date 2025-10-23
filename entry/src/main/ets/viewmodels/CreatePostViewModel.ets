import { submitImage, type CreatePostParams, type SubmitImageData } from '../services/api/PostApi';
import { fileIo } from '@kit.CoreFileKit';
import { ToastUtil } from '../common/utils/ToastUtil';

/**
 * 数据模型
 */
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

  /**
   * 提交帖子API方法
   * @returns
   *
   * 为什么要读取文件？？？？？？
   * 因为相册选择器返回的是文件的URL路径，然后上传文件需要的是ArrayBuffer，也就是二进制数据
   */
  async submitPost(): Promise<boolean> {
    if (!this.validate() || this.isSubmitting) return false;

    this.isSubmitting = true;

    const imageFiles: ArrayBuffer[] = [];

    for (let i = 0; i < this.selectedImages.length; i++) {
      const imageUri = this.selectedImages[i];

      // 打开文件并获取文件大小
      const file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY);
      const stat: fileIo.Stat = fileIo.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      // 读取文件到ArrayBuffer
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);

      imageFiles.push(buffer);
    }

    const params: CreatePostParams = {
      title: this.title,
      description: this.description || undefined,
      imageFiles: imageFiles,
      tags: this.tags.length > 0 ? this.tags : undefined
    };

    const response = await submitImage(params);

    if (response.success && response.data) {
      this.showSuccess('发布成功');
      this.isSubmitting = false;
      return true;
    } else {
      this.showError(response.message || '发布失败');
      this.isSubmitting = false;
      return false;
    }
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
    ToastUtil.getInstance().showWithBottom(message, 2000, 100);
  }

  private showSuccess(message: string): void {
    ToastUtil.getInstance().showWithBottom(message, 2000, 100);
  }
}
