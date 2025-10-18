/**
 * 图片实体
 */
export interface ImageEntity {
  image_id: string;
  post_id: number;
  display_order: number;
  file_url: string;
  thumbnail_url: string;
  file_size: number;
  width: number;
  height: number;
  mime_type: string;
  create_time: number;
}