## Why

现有2048菜单使用通用ActionButton，未消费本轮获批的新菜单设计及资源。用UI-2048-MENU/U001完成真实原生菜单接入，并验证同一固定包合同也适用于AI制作的手游界面。

## What Changes

- 固定批准A `db1d8d36482883a46f6624c02cde4241547f3d18`及内容D `c6f6cda8b823fa5a5fb9c2ec0f89e876c305bd60`，菜单采用获批背景、排版与Kenney按钮。
- 在原MenuView内使用局部菜单组件、tokens与两张@2x图片；保留原GameView回调和系统确认框。
- 补确定性菜单UI测试、素材构建检查及两尺寸实际截图，保留原引擎/状态/存储回归。
- 不改棋盘、合并/计分、撤销、GameOver、存储规则；不把HTML/SVG原型加入产品。

## Capabilities

### New Capabilities

- `menu-presentation`：本轮固定菜单呈现、资源和交互连续性合同。当前无主Spec，新增该限定呈现规格，不重写整个游戏规格。

### Modified Capabilities

无已有主Spec路径；原游戏行为按固定源码与独立expected回归。

## Impact

MenuView、菜单专用实现、Assets.xcassets、tokens资源及Xcode资源声明；已有XCTest/UI测试与仅DEBUG的确定性测试数据入口。其他ActionButton使用者保持原样。源码基线a89e5c7f8a3fce36bbebd250c116ffa26ede7e0d；无新依赖，原MIT及Kenney CC0许可保留。
