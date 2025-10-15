import { LoginPage } from './LoginPage'
import { RegisterPage } from './RegisterPage'

// import { NavPathStack } from '@kit.ArkUI'
export enum AuthPageType {
  LOGIN = 0,
  REGISTER = 1
}

@Entry
@Component
export struct AuthPage {
  @State currentPage: AuthPageType = AuthPageType.LOGIN
  @Provide('NavPathStack') navPathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.navPathStack) {
      Column() {
        if (this.currentPage === AuthPageType.LOGIN) {
          LoginPage({ currentPage: this.currentPage })
        } else {
          RegisterPage({ currentPage: this.currentPage })
        }
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }
}