import { ImageCard, ImageItem } from '../components/ImageCard'
import { getCurrentUserInfo,UserInfo } from '../../services/api/UserApi'
import { TokenManager } from '../../services/TokenManager'
import { common } from '@kit.AbilityKit'
import { LoginPage } from './LoginPage'
import { RegisterPage } from './RegisterPage'

export enum AuthPageType {
  LOGIN = 0,
  REGISTER = 1
}

interface UserLoginStatusChangedData {
  isLoggedIn: boolean;
  userInfo: UserInfo;
}

interface UserLogoutStatusChangedData {
  isLoggedIn: boolean;
}

@Component
export struct ProfilePage {
  @State isUserLoggedIn: boolean = false;
  @State currentAuthPage: AuthPageType = AuthPageType.LOGIN;
  @State showAuthView: boolean = false;
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

  @State currentIndex: number = 0;
  @State workLikedItems: Set<string> = new Set()
  @State workLikeCounts: Map<string, number> = new Map()
  @State workItems: ImageItem[] = []

  @State likeLikedItems: Set<string> = new Set()
  @State likeLikeCounts: Map<string, number> = new Map()
  @State likeItems: ImageItem[] = []

  aboutToAppear(): void {
    this.checkUserLoginStatus();

    try {
      let context = getContext(this) as common.UIAbilityContext;
      let eventHub = context.eventHub;
      eventHub.on('userLoginStatusChanged', (data: UserLoginStatusChangedData) => {
        this.isUserLoggedIn = data.isLoggedIn;
        if (data.userInfo) {
          this.userInfo = data.userInfo;
        }
        this.showAuthView = false;
      });
      
      eventHub.on('userLogoutStatusChanged', (data: UserLogoutStatusChangedData) => {
        this.isUserLoggedIn = false;
        this.showAuthView = false;
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

  private async checkUserLoginStatus() {
    this.isLoading = true;
    try {
      const tokenManager = TokenManager.getInstance();
      const token = await tokenManager.getToken();

      if (token) {
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

  @Consume('NavPathStack') pathStack: NavPathStack

  @Builder
  buildWelcomeView() {
    Column() {
      Column() {
        Image($r('app.media.ic_profile'))
          .width(120)
          .height(120)
          .margin({ top: 120, bottom: 40 })
          .fillColor('#ffdd0223')

        Text('发现精彩，分享生活')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ bottom: 12 })

        Text('登录后查看个人主页和专属内容')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 60 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 16 }) {
        Button('登录 / 注册')
          .width('80%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#ffdd0223')
          .borderRadius(25)
          .onClick(() => {
            this.showAuthView = true
            this.currentAuthPage = AuthPageType.LOGIN
          })

        Row({ space: 8 }) {
          Text('继续使用即代表同意')
            .fontSize(12)
            .fontColor('#999999')
          Text('用户协议')
            .fontSize(12)
            .fontColor('#ffdd0223')
          Text('和')
            .fontSize(12)
            .fontColor('#999999')
          Text('隐私政策')
            .fontSize(12)
            .fontColor('#ffdd0223')
        }
        .margin({ top: 20 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  isWorkItemLiked(id: string): boolean {
    return this.workLikedItems.has(id)
  }

  getWorkItemLikeCount(id: string): number {
    return this.workLikeCounts.get(id) || 0
  }

  isLikeItemLiked(id: string): boolean {
    return this.likeLikedItems.has(id)
  }

  getLikeItemLikeCount(id: string): number {
    return this.likeLikeCounts.get(id) || 0
  }

  build() {
    if (!this.isUserLoggedIn && !this.isLoading) {
      if (this.showAuthView) {
        Column() {
          Row() {
            Image($r('app.media.ic_back'))
              .width(24)
              .height(24)
              .margin({ left: 16 })
              .onClick(() => {
                this.showAuthView = false
              })

            Text(this.currentAuthPage === AuthPageType.LOGIN ? '登录' : '注册')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Blank()
              .width(40)
          }
          .width('100%')
          .height(56)
          .backgroundColor('#FFFFFF')

          if (this.currentAuthPage === AuthPageType.LOGIN) {
            LoginPage({ currentPage: this.currentAuthPage })
          } else {
            RegisterPage({ currentPage: this.currentAuthPage })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
      } else {
        this.buildWelcomeView()
      }
    } else {
      Column() {
        Stack() {
          Image('https://design.gemcoder.com/staticResource/echoAiSystemImages/582f3c87050f39c69515349a5003c9f1.png')
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .opacity(1)
            .backgroundColor('#000')

          Row() {
            Row() {
              Button() {
                Image($r('app.media.ic_profilePage_setting'))
                  .width(24)
                  .height(24)
                  .margin({left:16})
                  .fillColor('#fff');
              }
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                console.log('[ProfilePage] 点击设置图标')
                console.log('[ProfilePage] pathStack exists:', !!this.pathStack)
                this.pathStack.pushPathByName('SettingPage', null, false)
                console.log('[ProfilePage] pushPathByName executed')
              });
            }
            .justifyContent(FlexAlign.End)
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

        Column() {
          if (this.isLoading) {
            Column() {
              Text('加载中...')
                .fontSize(16)
                .fontColor('#999')
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
          } else {
            this.renderLoggedInView()
          }
        }
        .padding({ left: 16, right: 16, top: 0, bottom: 12 })
        .margin({ top: -60 })
        .backgroundColor('#fff')
        .width('100%')
        .borderRadius({ topLeft: 16, topRight: 16 });

        if (this.isUserLoggedIn) {
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9');
    }
  }


  @Builder
  renderLoggedInView() {
    Row() {
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

  @Builder TabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontColor(this.currentIndex === targetIndex ? '#ff0000' : '#6b7280')

      if (this.currentIndex === targetIndex) {
        Divider()
          .width(120)
          .height(8)
          .color('#ff0000')
          .margin({ top: 4 })
      }
    }

    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

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
