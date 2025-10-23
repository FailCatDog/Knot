import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { TokenManager } from '../services/TokenManager';
import { ReadStatusManager } from '../services/ReadStatusManager';
import { ToastUtil } from '../common/utils/ToastUtil';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate START');

    try {
      hilog.info(DOMAIN, 'testTag', 'Initializing TokenManager...');
      const tokenManager = TokenManager.getInstance();
      await tokenManager.init(this.context);
      hilog.info(DOMAIN, 'testTag', 'TokenManager initialized successfully');
      
      hilog.info(DOMAIN, 'testTag', 'Initializing ReadStatusManager...');
      const readStatusManager = ReadStatusManager.getInstance();
      await readStatusManager.init(this.context);
      hilog.info(DOMAIN, 'testTag', 'ReadStatusManager initialized successfully');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to initialize managers: %{public}s', JSON.stringify(error));
      return;
    }

    hilog.info(DOMAIN, 'testTag', 'Loading content: pages/SplashPage');
    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      
      try {
        hilog.info(DOMAIN, 'testTag', 'Initializing ToastUtil...');
        const mainWindow = windowStage.getMainWindowSync();
        const uiContext = mainWindow.getUIContext();
        const toastUtil = ToastUtil.getInstance();
        toastUtil.init(uiContext);
        hilog.info(DOMAIN, 'testTag', 'ToastUtil initialized successfully');
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', 'Failed to initialize ToastUtil: %{public}s', JSON.stringify(error));
      }
    });
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate END');
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}