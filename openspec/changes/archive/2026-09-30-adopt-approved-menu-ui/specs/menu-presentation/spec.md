## Purpose

为2048现有菜单提供与本轮已批准设计一致的视觉呈现和操作反馈，使用户能辨认重开本局与重置最高分，并在取消、确认和关闭菜单后回到正确的游戏状态。此规格限定当前菜单，不重新定义棋盘合并、计分或存储规则。

## ADDED Requirements

### Requirement: Approved menu appearance

菜单 SHALL 在本轮两种竖屏尺寸、默认字号和浅色环境中呈现获批的背景、标题、按钮、提示与安全区布局；资源与允许差异以固定UI-2048-MENU/U001包为准，不读取活动制作源。

#### Scenario: Open menu on each selected size

- **WHEN** 用户从当前棋盘打开菜单
- **THEN** MENU、NEW GAME、RESET BEST SCORE与关闭提示完整可见，按钮无文字重叠、缺图或触点错位，棋盘与分数保持原值

### Requirement: Confirmation and cancellation preserve the existing game

菜单 SHALL 在重置最高分前展示既有确认问题和两个选择；取消只返回菜单，确认才执行原重置动作并关闭菜单。

#### Scenario: Cancel reset

- **WHEN** 最高分64、本局分数16时打开重置确认并选择Cancel
- **THEN** 返回菜单且最高分、本局分数、棋盘均未改变

#### Scenario: Confirm reset

- **WHEN** 同一前态选择Yeah, whatever
- **THEN** 菜单关闭、当下最高分为0，本局分数16与棋盘保持原值；后续模型更新和重启沿原最高分规则

### Requirement: New game and dismiss maintain existing transitions

菜单 SHALL 保留原新局和滑动关闭行为，新增视觉不能改变游戏生命周期。

#### Scenario: Start new game

- **WHEN** 本局分数16、最高分64时选择NEW GAME
- **THEN** 菜单关闭，本局分数归0、棋盘出现原规则的一块2或4、撤销历史清空，最高分64保留

#### Scenario: Dismiss or foreground the menu

- **WHEN** 用户向下滑动关闭菜单，或在同一进程前后台切换
- **THEN** 关闭只恢复原棋盘；前后台切换保留当前菜单和数据，不自动重开或重置
