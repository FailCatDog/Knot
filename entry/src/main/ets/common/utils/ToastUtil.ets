import { UIContext } from '@kit.ArkUI'

export class ToastUtil {
  private static instance: ToastUtil
  private uiContext: UIContext | null = null

  private constructor() {}

  static getInstance(): ToastUtil {
    if (!ToastUtil.instance) {
      ToastUtil.instance = new ToastUtil()
    }
    return ToastUtil.instance
  }

  init(uiContext: UIContext): void {
    this.uiContext = uiContext
  }

  show(message: string, duration: number = 2000): void {
    if (this.uiContext) {
      this.uiContext.getPromptAction().showToast({
        message: message,
        duration: duration
      })
    }
  }

  showWithBottom(message: string, duration: number = 2000, bottom: number = 100): void {
    if (this.uiContext) {
      this.uiContext.getPromptAction().showToast({
        message: message,
        duration: duration,
        bottom: bottom
      })
    }
  }
}

