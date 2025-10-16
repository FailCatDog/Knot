import { CreatePostViewModel } from '../viewmodels/CreatePostViewModel';
import { picker } from '@kit.CoreFileKit';

@Builder
export function CreatePostPageBuilder() {
  CreatePostPage()
}

@Component
struct CreatePostPage {
  @State viewModel: CreatePostViewModel = new CreatePostViewModel();
  @State titleInput: string = '';
  @State descriptionInput: string = '';
  @State selectedImageUris: string[] = [];
  @State tagInput: string = '';
  @Consume('NavPathStack') navPathStack: NavPathStack;

  aboutToDisappear(): void {
    this.viewModel.reset();
  }

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

  @Builder
  buildHeader() {
    Row() {
      Button() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#1A1A1A')
      }
      .width(40)
      .height(40)
      .backgroundColor('transparent')
      .onClick(() => {
        this.navPathStack.pop();
      })

      Text('发布帖子')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('发布')
        .fontSize(14)
        .fontColor(this.canSubmit() ? '#FFFFFF' : '#999999')
        .backgroundColor(this.canSubmit() ? '#ffdd0223' : '#E5E5E5')
        .borderRadius(16)
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .margin({ bottom: 6 })
        .enabled(this.canSubmit() && !this.viewModel.isSubmitting)
        .onClick(() => {
          this.handleSubmit();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 16, top: 20 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildContent() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('标题')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')

          TextInput({ placeholder: '请输入标题', text: this.titleInput })
            .fontSize(16)
            .fontColor('#1A1A1A')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => {
              this.titleInput = value;
              this.viewModel.setTitle(value);
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .border({ width: 1, color: '#E0E0E0', radius: 8 })
        .backgroundColor('#FFFFFF')

        Column({ space: 8 }) {
          Text('描述(可选)')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')

          TextArea({ placeholder: '请输入描述...', text: this.descriptionInput })
            .fontSize(16)
            .fontColor('#1A1A1A')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .padding(12)
            .height(120)
            .onChange((value: string) => {
              this.descriptionInput = value;
              this.viewModel.setDescription(value);
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .border({ width: 1, color: '#E0E0E0', radius: 8 })
        .backgroundColor('#FFFFFF')

        // 图片选择
        Column({ space: 8 }) {
          Text('图片')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')

          // 图片网格
          Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
            // 已选图片
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
                    .fillColor('#FFFFFF')
                }
                .width(24)
                .height(24)
                .backgroundColor('#FF0000')
                .borderRadius(12)
                .margin({ top: 4, right: 4 })
                .onClick(() => {
                  this.removeImage(index);
                })
              }
              .width(100)
              .height(100)
              .margin({ right: 8, bottom: 8 })
            })

            // 添加图片按钮
            if (this.selectedImageUris.length < 9) {
              Button() {
                Column({ space: 4 }) {
                  Image($r('app.media.ic_add'))
                    .width(32)
                    .height(32)
                    .fillColor('#999999')

                  Text('添加图片')
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .width(100)
              .height(100)
              .backgroundColor('#F0F0F0')
              .borderRadius(8)
              .onClick(() => {
                this.selectImages();
              })
            }
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .border({ width: 1, color: '#E0E0E0', radius: 8 })
        .backgroundColor('#FFFFFF')

        // 标签输入
        Column({ space: 8 }) {
          Text('标签(可选)')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')

          // 已添加的标签
          if (this.viewModel.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.viewModel.tags, (tag: string) => {
                Row({ space: 4 }) {
                  Text('#' + tag)
                    .fontSize(14)
                    .fontColor('#ffdd0223')

                  Image($r('app.media.ic_close'))
                    .width(14)
                    .height(14)
                    .fillColor('#ffdd0223')
                    .onClick(() => {
                      this.viewModel.removeTag(tag);
                    })
                }
                .padding({ left: 12, right: 8, top: 6, bottom: 6 })
                .backgroundColor('#FFF5F5')
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
              })
            }
            .width('100%')
          }

          // 标签输入框
          Row({ space: 8 }) {
            TextInput({ placeholder: '输入标签', text: this.tagInput })
              .fontSize(14)
              .fontColor('#1A1A1A')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding(12)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.tagInput = value;
              })

            Button('添加')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#ffdd0223')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                if (this.tagInput.trim()) {
                  this.viewModel.addTag(this.tagInput);
                  this.tagInput = '';
                }
              })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .border({ width: 1, color: '#E0E0E0', radius: 8 })
        .backgroundColor('#FFFFFF')
      }
      .width('100%')
      .margin({top: -100})
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  // 选择图片
  async selectImages() {
    const photoSelectOptions = new picker.PhotoSelectOptions();
    photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 9 - this.selectedImageUris.length;

    const photoPicker = new picker.PhotoViewPicker();
    const result = await photoPicker.select(photoSelectOptions);

    if (result && result.photoUris && result.photoUris.length > 0) {
      this.selectedImageUris.push(...result.photoUris);
      this.viewModel.setImages([...this.viewModel.selectedImages, ...result.photoUris]);
    }
  }

  // 移除图片
  removeImage(index: number) {
    this.selectedImageUris.splice(index, 1);
    this.viewModel.selectedImages.splice(index, 1);
    this.viewModel.setImages([...this.viewModel.selectedImages]);
  }

  canSubmit(): boolean {
    return this.titleInput.trim().length > 0 && this.selectedImageUris.length > 0;
  }

  async handleSubmit() {
    if (!this.canSubmit()) return;
    const success = await this.viewModel.submitPost();
    if (success) {
      this.navPathStack.pop();
    }
  }
}
