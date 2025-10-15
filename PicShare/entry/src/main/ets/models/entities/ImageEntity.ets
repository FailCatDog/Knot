/**
 * 图片实体
 */
export interface ImageEntity {
  id: number;
  image_id: string;
  user_id: number;
  title: string;
  description: string;
  file_url: string;
  thumbnail_url: string;
  file_size: number;
  width: number;
  height: number;
  mime_type: string;
  like_count: number;
  favorite_count: number;
  view_count: number;
  status: string;
  create_time: number;
  update_time: number;
}