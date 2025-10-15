// import { Column, Row, Image, Button, Text, Flex, Stack, Divider } from '@ohos.arkui';
// import { Column } from
import { ImageCard, ImageItem } from '../components/ImageCard'
import router from '@ohos.router'
import { getCurrentUserInfo,UserInfo } from '../../services/api/UserApi'
import { TokenManager } from '../../services/TokenManager'
import { httpRequest } from '../../services/api/HttpRequest'
import { common } from '@kit.AbilityKit'

// 定义事件数据接口
interface UserLoginStatusChangedData {
  isLoggedIn: boolean;
  userInfo: UserInfo;
}

interface UserLogoutStatusChangedData {
  isLoggedIn: boolean;
}

@Entry
@Component
export struct ProfilePage {

  // 添加登出回调函数
  // @Consume('onLogout') onLogout: () => void

  // 用户登录状态
  @State isUserLoggedIn: boolean = false;
  @State userInfo: UserInfo = {
    id: 0,
    user_id: '',
    username: '',
    email: '',
    phone: '',
    real_name: '',
    avatar_url: '',
    bio: '',
    location: '',
    gender: '',
    role: '',
    status: '',
    create_time: 0,
    update_time: 0,
    device_count: 0
  };
  @State isLoading: boolean = true;


  // 状态变量：0=作品，1=喜欢（与Tabs的index对应）
  @State currentIndex: number = 0;
  // 作品相关状态
  @State workLikedItems: Set<string> = new Set(['work_2', 'work_5'])
  @State workLikeCounts: Map<string, number> = new Map()
  @State workItems: ImageItem[] = [
    {
      id: 'work_1',
      imageUrl: 'https://picsum.photos/280/350',
      title: '夏日海滩',
      userAvatar: $r('app.media.head'),
      userId: '用户名',
      likeCount: 41,
      isLiked: false,
      description: "这是图片的描述内容",
      imageHeight: 350
    },
    {
      id: 'work_2',
      imageUrl: 'https://picsum.photos/280/160',
      title: '美食分享',
      userAvatar: $r('app.media.head').toString(),
      userId: '用户名',
      likeCount: 9,
      isLiked: true,
      imageHeight: 160,
      description: "这是图片的描述内容"
    },
    {
      id: 'work_3',
      imageUrl: 'https://picsum.photos/280/280',
      title: '城市风景',
      userAvatar: $r('app.media.head').toString(),
      userId: '用户名',
      likeCount: 89,
      description: "这是图片的描述内容",
      isLiked: false,
      imageHeight: 280
    },
    {
      id: 'work_4',
      imageUrl: 'https://picsum.photos/280/140',
      title: '旅行日记',
      userAvatar: $r('app.media.head').toString(),
      userId: '用户名',
      likeCount: 167,
      description: "这是图片的描述内容",
      isLiked: false,
      imageHeight: 140
    },
    {
      id: 'work_5',
      imageUrl: 'https://picsum.photos/280/320',
      title: '生活记录',
      userAvatar: $r('app.media.head').toString(),
      userId: '用户名',
      likeCount: 203,
      description: "这是图片的描述内容",
      isLiked: true,
      imageHeight: 320
    },
    {
      id: 'work_6',
      imageUrl: 'https://picsum.photos/280/240',
      title: '摄影作品',
      userAvatar: $r('app.media.head'),
      userId: '用户名',
      likeCount: 145,
      description: "这是图片的描述内容",
      isLiked: false,
      imageHeight: 240
    }
  ]

  // 喜欢相关状态
  @State likeLikedItems: Set<string> = new Set(['like_1', 'like_3', 'like_6'])
  @State likeLikeCounts: Map<string, number> = new Map()
  @State likeItems: ImageItem[] = [
    {
      id: 'like_1',
      imageUrl: 'https://picsum.photos/280/350',
      title: '自然风光',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '青青草原',
      likeCount: 41,
      description: "这是图片的描述内容",
      isLiked: true,
      imageHeight: 350
    },
    {
      id: 'like_2',
      imageUrl: 'https://picsum.photos/280/160',
      title: '同人图鉴',
      userAvatar: 'https://picsum.photos/40/40',
      userId: '青青草原',
      likeCount: 9,
      description: "这是图片的描述内容",
      isLiked: false,
      imageHeight: 160
    },
    {
      id: 'like_3',
      imageUrl: 'https://picsum.photos/280/280',
      title: '十几就行了',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'vivo影像',
      likeCount: 89,
      description: "这是图片的描述内容",
      isLiked: true,
      imageHeight: 280
    },
    {
      id: 'like_4',
      imageUrl: 'https://picsum.photos/280/140',
      title: 'City&City',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'vivo影像',
      likeCount: 167,
      isLiked: false,
      description: "这是图片的描述内容",
      imageHeight: 140
    },
    {
      id: 'like_5',
      imageUrl: 'https://picsum.photos/280/320',
      title: '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'vivo影像',
      likeCount: 203,
      description: "这是图片的描述内容",
      isLiked: false,
      imageHeight: 320
    },
    {
      id: 'like_6',
      imageUrl: 'https://picsum.photos/280/240',
      title: '',
      userAvatar: 'https://picsum.photos/40/40',
      userId: 'pet_lover',
      description: "这是图片的描述内容",
      likeCount: 145,
      isLiked: true,
      imageHeight: 240
    }
  ]

  aboutToAppear(): void {
    this.workItems.forEach(item => {
      this.workLikeCounts.set(item.id, item.likeCount)
    })

    this.likeItems.forEach(item => {
      this.likeLikeCounts.set(item.id, item.likeCount)
    })

    this.checkUserLoginStatus();

    try {
      let context = getContext(this) as common.UIAbilityContext;
      let eventHub = context.eventHub;
      eventHub.on('userLoginStatusChanged', (data: UserLoginStatusChangedData) => {
        this.isUserLoggedIn = data.isLoggedIn;
        if (data.userInfo) {
          this.userInfo = data.userInfo;
        }
      });
      
      eventHub.on('userLogoutStatusChanged', (data: UserLogoutStatusChangedData) => {
        this.isUserLoggedIn = false;
        this.userInfo = {
          id: 0,
          user_id: '',
          username: '',
          email: '',
          phone: '',
          real_name: '',
          avatar_url: '',
          bio: '',
          location: '',
          gender: '',
          role: '',
          status: '',
          create_time: 0,
          update_time: 0,
          device_count: 0
        };
      });
    } catch (error) {
      console.error('监听事件失败:', error);
    }
  }

  // 页面销毁时取消事件监听
  aboutToDisappear(): void {
    try {
      let context = getContext(this) as common.UIAbilityContext;
      let eventHub = context.eventHub;
      eventHub.off('userLoginStatusChanged');
      eventHub.off('userLogoutStatusChanged');
    } catch (error) {
      console.error('取消监听事件失败:', error);
    }
  }

  // 检查用户登录状态并获取用户信息
  private async checkUserLoginStatus() {
    this.isLoading = true;
    try {
      const tokenManager = TokenManager.getInstance();
      const token = await tokenManager.getToken();

      if (token) {
        httpRequest.setAuthToken(token);
        const response = await getCurrentUserInfo();
        if (response.success && response.data) {
          this.userInfo = response.data;
          this.isUserLoggedIn = true;
        } else {
          await tokenManager.clearToken();
          this.isUserLoggedIn = false;
        }
      } else {
        this.isUserLoggedIn = false;
      }
    } catch (error) {
      console.error('检查用户登录状态失败:', error);
      this.isUserLoggedIn = false;
    } finally {
      this.isLoading = false;
    }
  }

  // 跳转到登录页面
  private navigateToLogin() {
    router.pushUrl({
      url: 'views/pages/AuthPage'
    }).catch((err: Error) => {
      console.error('导航到登录页面失败:', err.message);
    });
  }


  // 作品相关方法
  isWorkItemLiked(id: string): boolean {
    return this.workLikedItems.has(id)
  }

  getWorkItemLikeCount(id: string): number {
    return this.workLikeCounts.get(id) || 0
  }

  // 喜欢相关方法
  isLikeItemLiked(id: string): boolean {
    return this.likeLikedItems.has(id)
  }

  getLikeItemLikeCount(id: string): number {
    return this.likeLikeCounts.get(id) || 0
  }

  build() {
    Column() {
      // 背景图
      Stack() {
        Image('https://design.gemcoder.com/staticResource/echoAiSystemImages/582f3c87050f39c69515349a5003c9f1.png')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .opacity(1)
          .backgroundColor('#000')

        // 顶部操作栏
        Row() {
          Row() {
            // Button() {//分享按钮
            //   Image($r('app.media.ic_profilePage_share'))
            //     .width(20)
            //     .height(20)
            //     .margin({left:16})
            //     .fillColor('#fff');
            // }
            // .backgroundColor(Color.Transparent);

            Button() {//设置按钮
              Image($r('app.media.ic_profilePage_setting'))
                .width(24)
                .height(24)
                .margin({left:16})
                .fillColor('#fff');
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/SettingPage'
              }).catch((err: Error) => {
                console.error('导航到设置页面失败:', err.message)
              })
            });
          }
          .justifyContent(FlexAlign.End) // 主轴（水平）右对齐
          .width('100%')
          .padding({ left: 16, right: 16 });
        }
        .position({ top: 1, left: 16, right: 16 })
        .width('100%')
        .height(48);
      }
      .width('100%')
      .height(160)
      .clip(true);

      // 用户信息区
      // Column() {
      //   // 头像
      //   Image($r('app.media.head'))
      //     .width(80)
      //     .height(80)
      //     .borderRadius(60)
      //     .border({ width: 4, color: '#fff' })
      //     .position({ top: -60, left: 10 });
      //   // 用户名和简介
      //   Column() {
      //     Text('用户名')
      //       .fontSize(20)
      //       .fontWeight(FontWeight.Bold)
      //       .fontColor('#1f2937')
      //       .margin({ bottom: 4 });
      //
      //     Text('这里是个性签名')
      //       .fontSize(14)
      //       .fontColor('#6b7280');
      //   }
      //   .alignItems(HorizontalAlign.Start)
      //   .width('100%')
      //   .margin({ left:30,top: 25 });
      //
      //   // 关注和粉丝
      //   Row() {
      //     Row() {
      //       Text('1')
      //         .fontWeight(FontWeight.Bold)
      //         .fontColor('#1f2937');
      //       Text(' 关注')
      //         .fontSize(14)
      //         .fontColor('#6b7280');
      //     }
      //
      //     .margin({ left: 12 });
      //
      //     Row() {
      //       Text('0')
      //         .fontWeight(FontWeight.Bold)
      //         .fontColor('#1f2937');
      //       Text(' 粉丝')
      //         .fontSize(14)
      //         .fontColor('#6b7280');
      //     }
      //     .margin({ left: 8 });
      //   }
      //   .justifyContent(FlexAlign.Start)
      //   .width('100%') // 确保容器占满宽度，否则可能看不出效果
      //   .margin({ top: 12 });
      //
      //   // IP属地和数据统计
      //   Column() {
      //     // Row() {
      //     //   Image($r('app.media.ic_profilePage_location'))
      //     //     .width(24)
      //     //     .height(24)
      //     //     .margin({ left: 5 });
      //     //   Text('IP属地: 某地')
      //     //     .fontSize(14)
      //     //     .fontColor('#6b7280');
      //     // }
      //     // .margin({ bottom: 4 });
      //     Row() {
      //       Image($r('app.media.ic_profilePage_stats'))
      //         .width(24)
      //         .height(24)
      //         .margin({ left: 5 });
      //       Text('0作品数 · 0被喜欢')
      //         .fontSize(14)
      //         .fontColor('#6b7280');
      //     }
      //   }
      //   .alignItems(HorizontalAlign.Start)
      //   .width('100%')
      //   .margin({ left:4,top: 8 });
      // }
      // .padding({ left: 16, right: 16, top: 32, bottom: 1 })
      // .backgroundColor('#fff')
      // .width('100%');


      // 使用Tabs实现带动画的页面切换，并自定义tab样式
      // Tabs({ index: this.currentIndex, controller: new TabsController() }) {
      //   TabContent() {
      //     this.WorkContent()
      //   }
      //   .tabBar(this.TabBuilder('作品', 0))
      //
      //   TabContent() {
      //     this.LikeContent()
      //   }
      //   .tabBar(this.TabBuilder('喜欢', 1))
      // }
      // .barPosition(BarPosition.Start)
      // .onChange((index: number) => {
      //   this.currentIndex = index;
      // })
      // // .flexGrow(1)
      // .width('100%')
      // .padding({ left: 1, right: 1, top: -5, bottom: 280 })
      // .margin({top:-5})
      // .backgroundColor('#fff');

      // // 添加跳转到登录注册页面的按钮
      // Button('测试登录注册')
      //   .width('80%')
      //   .height(40)
      //   .backgroundColor('#FFDD0223')
      //   .fontColor('#FFFFFF')
      //   .borderRadius(8)
      //   .margin({ top: 20, bottom: 20 })
      //   .onClick(() => {
      //     this.getUIContext().getRouter().pushUrl({
      //       url: 'pages/AuthPage'
      //     }).catch((err: Error) => {
      //       console.error('导航到登录注册页面失败:', err.message)
      //     })
      //   })

      // 用户信息区
      Column() {
        if (this.isLoading) {
          // 加载中状态
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999')
          }
          .width('100%')
          .height(120)
          .justifyContent(FlexAlign.Center)
        } else if (!this.isUserLoggedIn) {
          // 未登录状态
          this.renderUnloggedInView()
        } else {
          // 已登录状态
          this.renderLoggedInView()
        }
      }
      .padding({ left: 16, right: 16, top: 0, bottom: 12 })
      .margin({ top: -60 })
      .backgroundColor('#fff')
      .width('100%')
      .borderRadius({ topLeft: 16, topRight: 16 });

      // 显示作品/喜欢标签页（仅在用户已登录时显示）
      if (this.isUserLoggedIn) {
        // 使用Tabs实现带动画的页面切换，并自定义tab样式
        Tabs({ index: this.currentIndex, controller: new TabsController() }) {
          TabContent() {
            this.WorkContent()
          }
          .tabBar(this.TabBuilder('作品', 0))

          TabContent() {
            this.LikeContent()
          }
          .tabBar(this.TabBuilder('喜欢', 1))
        }
        .barPosition(BarPosition.Start)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .width('100%')
        .padding({ left: 0, right: 0, top: -15, bottom: 0 })
        .margin({ top: 0 })
        .backgroundColor('#fff')
        .layoutWeight(1);
      }

      // 添加跳转到登录注册页面的按钮（仅在未登录时显示）
      if (!this.isUserLoggedIn) {
        Button('测试登录注册')
          .width('80%')
          .height(40)
          .backgroundColor('#FFDD0223')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 20, bottom: 20 })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/AuthPage'
            }).catch((err: Error) => {
              console.error('导航到登录注册页面失败:', err.message)
            })
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f5f9');
  }

  @Builder
  renderUnloggedInView() {
    Column() {
      Image($r('app.media.head'))
        .width(80)
        .height(80)
        .borderRadius(40)
        .border({ width: 3, color: '#fff' })
        .margin({ bottom: 16 })

      Text('未登录')
        .fontSize(20)
        .fontColor('#333')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })

      Text('登录后查看个人主页')
        .fontSize(14)
        .fontColor('#999')
        .margin({ bottom: 24 })

      Button('立即登录')
        .type(ButtonType.Normal)
        .borderRadius(24)
        .backgroundColor('#ffdd0223')
        .width(160)
        .height(48)
        .fontSize(16)
        .fontColor('#ffffff')
        .onClick(() => {
          this.navigateToLogin();
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .margin({ top: -80 })
  }

  @Builder
  renderLoggedInView() {
    Row() {
      // 用户头像
      Image(this.userInfo.avatar_url && this.userInfo.avatar_url.trim() !== '' ? this.userInfo.avatar_url : $r('app.media.head'))
        .width(80)
        .height(80)
        .borderRadius(40)
        .border({ width: 3, color: '#fff' })
        .margin({ right: 12, top: -30 })
        .alt($r('app.media.head'))

      Column() {
        Text(this.userInfo.username)
          .fontSize(18)
          .fontColor('#333')
          .fontWeight(FontWeight.Bold)

        Text(this.userInfo.bio && this.userInfo.bio.trim() !== '' ? this.userInfo.bio : '暂无个人简介')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ top: 0 })
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  // >>>>>>>>>> 自定义TabBuilder实现红色指示器 <<<<<<<<<<
  @Builder TabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontColor(this.currentIndex === targetIndex ? '#ff0000' : '#6b7280') // 选中时红色，未选中时灰色

      // >>>>>>>>>> 自定义下划线指示器 <<<<<<<<<<
      if (this.currentIndex === targetIndex) {
        Divider()
          .width(120)
          .height(8)
          .color('#ff0000') // 红色下划线
          .margin({ top: 4 })
      }
    }

    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // >>>>>>>>>> 作品页面内容 <<<<<<<<<<
  @Builder
  WorkContent() {
    WaterFlow() {
      ForEach(this.workItems, (item: ImageItem, index: number) => {
        FlowItem() {
          ImageCard({
            item: {
              id: item.id,
              imageUrl: item.imageUrl,
              title: item.title,
              userAvatar: item.userAvatar,
              userId: item.userId,
              description: item.description,
              likeCount: this.getWorkItemLikeCount(item.id),
              isLiked: this.isWorkItemLiked(item.id),
              imageHeight: item.imageHeight
            },
            onLikeClick: (id: string) => this.handleWorkLikeClick(id),
          })
        }
        .width('100%')
        .constraintSize({
          maxWidth: '100%',
          minWidth: 0
        })
      })
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(8)
    .rowsGap(10)
    .padding({ left: 8, right: 8, top: 8, bottom: 16 })
    .width('100%')
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  // >>>>>>>>>> 喜欢页面内容 <<<<<<<<<<
  @Builder
  LikeContent() {
    WaterFlow() {
      ForEach(this.likeItems, (item: ImageItem, index: number) => {
        FlowItem() {
          ImageCard({
            item: {
              id: item.id,
              imageUrl: item.imageUrl,
              title: item.title,
              userAvatar: item.userAvatar,
              userId: item.userId,
              description: item.description,
              likeCount: this.getLikeItemLikeCount(item.id),
              isLiked: this.isLikeItemLiked(item.id),
              imageHeight: item.imageHeight
            },
            onLikeClick: (id: string) => this.handleLikeLikeClick(id),
          })
        }
        .width('100%')
        .constraintSize({
          maxWidth: '100%',
          minWidth: 0
        })
      })
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(8)
    .rowsGap(10)
    .padding({ left: 8, right: 8, top: 8, bottom: 16 })
    .width('100%')
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  // 处理作品点赞
  handleWorkLikeClick(id: string): void {
    const currentCount = this.getWorkItemLikeCount(id)
    const isCurrentlyLiked = this.isWorkItemLiked(id)

    if (isCurrentlyLiked) {
      this.workLikedItems.delete(id)
      this.workLikeCounts.set(id, currentCount - 1)
    } else {
      this.workLikedItems.add(id)
      this.workLikeCounts.set(id, currentCount + 1)
    }
  }

  // 处理喜欢点赞
  handleLikeLikeClick(id: string): void {
    const currentCount = this.getLikeItemLikeCount(id)
    const isCurrentlyLiked = this.isLikeItemLiked(id)

    if (isCurrentlyLiked) {
      this.likeLikedItems.delete(id)
      this.likeLikeCounts.set(id, currentCount - 1)
    } else {
      this.likeLikedItems.add(id)
      this.likeLikeCounts.set(id, currentCount + 1)
    }
  }
}