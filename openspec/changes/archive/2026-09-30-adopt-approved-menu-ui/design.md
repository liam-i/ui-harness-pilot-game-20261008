## Context

动机见proposal.md。现有MenuView使用ActionButton，GameView用sheet和闭包执行reset/eraseBestScore；现有GameEngine、GameStateTracker、Storage与XCTest不需要重构。原工程在SE3已通过40项单元测试，代码未改；这只是改造前基线。

## Goals / Non-Goals

**Goals:** 新视觉严格落在菜单，保留本局状态与确认/取消连续性；固定Kenney素材到实际原生资源，验证两尺寸。

**Non-Goals:** 不改变ActionButton的其他使用者、游戏规则、GameOver或保存语义；不新增品牌库、依赖、统一状态管理或引擎迁移。

## Decisions

### 菜单、资源与确定性验证

1. 只在MenuView中组织本轮菜单组件，保留原GameView的两个回调及原生Alert。新背景/标题/提示/按钮均来自获批tokens；固定16pt capInsets，imageset标为@2x，从两张384×128 PNG原字节导入Assets.xcassets。避免改公共ActionButton导致GameOver外溢。
2. tokens.json由Bundle解码，本轮所需值由小型类型承接。资源小于已批准预算；不放入SVG/HTML、不在运行时访问design目录。单元检查实际导入图片摘要、像素、tokens和bundle资源；UI运行观察真实渲染而非只查文件存在。
3. 扩充现有twofortyeightTests和twofortyeightUITests；增加独立的MenuUITests，不以现有随机滑动测试替代本轮分母。测试按启动参数在`#if DEBUG`入口准备score16/best64与固定棋盘，仅在明确测试参数存在时写入专用模拟器的本App数据。Release编译不含该入口；不修改LocalStorage或引擎规则。通过启动前置断言证明数据确实生效，避免静默误测。
4. 新增素材/加载逻辑按TDD；菜单布局/资源是静态任务，确认回调已有行为先补回归。测试标识保留原menuButton/newGameButton/resetBestScoreButton；必要时补静态新节点标识。原GameRobot的swipeDown实际调用swipeLeft，若复用必须定向纠正并验证，不能把错误动作计为向下覆盖。
5. 在两尺寸执行独立B01–B09并保存默认菜单、系统确认、取消返回、确认后和新局画面；棋盘截图只是上下文。原40项引擎/状态/存储单元回归仍运行；所选旧UI场景如随机输入不能满足本轮断言，记录其局限并保留确定性用例，不降低新预期。

### 消费绑定

```json
{
  "consumer": {
    "kind": "change",
    "subject": "adopt-approved-menu-ui",
    "proposal_path": "proposal.md"
  },
  "applicability": "required",
  "approved_release_ref": {
    "repository": "/private/tmp/ui-workflow-p0-20260930-u8jw1kyx/work/ui-authority",
    "commit": "db1d8d36482883a46f6624c02cde4241547f3d18",
    "path": "design/units/UI-2048-MENU/decisions/approve-U001.yaml",
    "sha256": "b634b272ddbd1712f605ec436835338a4a32b2c58b1779cc44c4bc54905fb171"
  },
  "package_ref": {
    "repository": "/private/tmp/ui-workflow-p0-20260930-u8jw1kyx/work/ui-authority",
    "commit": "c6f6cda8b823fa5a5fb9c2ec0f89e876c305bd60",
    "path": "design/units/UI-2048-MENU/releases/U001/manifest.yaml",
    "sha256": "062a4887d998100c3bcda978f3b6630087b35b51206a5777ef1ccabaad9a18b2"
  },
  "expected_ref": {
    "repository": "/private/tmp/ui-workflow-p0-20260930-u8jw1kyx/work/ui-authority",
    "commit": "99526d0a38689138bd81fcd8f09e9693502d7d41",
    "path": "inputs/game-expected.json",
    "sha256": "fb78734b0fba34e22c476e11340ba65a13458bc2c1a041c8bce4f48bc1a7e0c0"
  }
}
```

覆盖为menu/default、menu/confirm-reset、game/board和输入game-expected.json的B01–B09；适用性required，理由是本轮获批新菜单视觉与素材。只有OS-RENDERING允许差异；最高分下一次更新/重启从当前分数重建仍按原规则，不改成永久清零新义务。

### 固定消费与阶段检查

无需求层Standard：当前Change的Proposal/Design就是消费者上下文，唯一Tasks记实施，不另建需求库或任务台账。本Design固定A及D，包清单固定全部文件、来源和独立expected；规划Review以当前文件摘要固定整体，避免文件引用自身未来提交。

取包使用独立恢复的Git对象；当前权威为`/private/tmp/ui-workflow-p0-20260930-u8jw1kyx/work/ui-authority`的`refs/heads/main`，历史起点`a6bc9fb40ff11bdfe7190273b97ebb6901f9ad52`。policy为该仓库输入提交99526d0a38689138bd81fcd8f09e9693502d7d41的inputs/authority.md，完整摘要见固定闭包报告。每次Propose/开始或恢复Apply/归档交付前重读实际ref和可达决定历史，将观察留在消费方；缺件/未知/撤回停止，不改用latest或历史PASS。原无效历史查询已在开发证据保留，今后使用确切decisions目录，零匹配不算通过。

来源获取失败演练在单独导出副本中移除必需文件，记录缺件并停止，再从同一D恢复；不修改已批准原包。资源文件身份只归UI清单，运行副本由本Change引用导入，不登记为DAS。

### 原生验证与证据

独立expected在输入提交99526d0a38689138bd81fcd8f09e9693502d7d41形成，必须逐ID记录actual，不据实现改答案。新增加载逻辑先读项目TDD，用实际可调用接口做有效失败后实现；为既有行为补测、添加测试标识和静态布局验证不伪造RED。

两台专用设备为SE3 `4F72CD21-F071-4835-87B2-1456D125374B` 和17Pro `D14EBF55-3D41-419E-8F85-306D5D812CFD`，iOS27.0、竖屏、浅色、默认字号。每次测试记录实际设备、代码HEAD+差异、命令/环境、退出码、用例数、原始日志/xcresult与截图；不把旧结果算到新代码。

原构建命令见AGENTS；实际构建和单元运行上限各300秒，UI suite每设备600秒、关闭并行克隆，用`-parallel-testing-enabled NO`。测试支持使用现有Xcode/XCTest，不安装xcodegen或第三方测试框架。测试完成或失败都关闭本试点设备；保留原操作及清理的独立结果，不删除用户设备。

### 本地交付与回退

取得本规划Review及明确Apply授权后才改业务实现。工作仅限当前隔离功能分支，可在用户授权下保存规划/实现/归档的本地提交；不会推送上游、合并正式主线或发布产品。测试、人工界面核对齐备后按原Archive/Sync收尾；只归档当前Change。设计批准不等于运行验收；最终产品画面与行为证据仍交当前用户确认。

未完成时保留原Tasks和失败，不新建Change。代码回退按当前分支实际差异选择并复验，不能只回退设计指针；已批准D/A继续保留。运行资源不再需要时由相应工程返修处理，不删除决定历史。

## Risks / Trade-offs

- sheet/Alert随OS变化 → 图只作获批呈现意图，按handoff固定应用部分；实际系统交互必须运行。
- 整图拉伸损坏按钮边缘 → 使用明确倍率和九宫格，不让布局改变图片纹理或文字。
- 测试初始化影响其他数据 → 仅DEBUG+明确参数+两个专用设备，本App域，Release验证无入口；失败后不扩操作到已有设备。
- UI测试的系统确认文字/元素定位不稳定 → 使用实际AX/XCTest元素和条件等待，不用盲目sleep代替结果；不能更改产品文案来迎合测试。
