## 1. 固定输入

- [x] 1.1 在获批规划和Apply授权下重读UI权威与决定历史，核对Design中的A/D、独立expected及完整闭包；保存命令、实际ref、摘要和结论，未知或撤回时停止消费。
- [x] 1.2 在独立导出副本移除一张必需PNG，确认缺件阻止继续，再从同一D恢复；以失败记录、恢复后摘要一致及原批准包未改为完成证据。

证据：[实际权威与固定闭包](../../../harness/evidence/ui-before-apply-game.json)、[PNG缺件与同D恢复](../../../harness/evidence/ui-missing-image-recovery.json)。43项闭包/批准引用及policy重新逐字节核对，决定历史仍为4份批准新增，无撤回。

## 2. 确定性测试

- [x] 2.1 增加独立MenuUITests和DEBUG专用启动数据入口，只在明确测试参数下写本App测试数据；通过启动前置断言核score16/best64/固定棋盘，并以Release构建与产物核对证明不包含该测试入口。保留原引擎和LocalStorage实现。
- [x] 2.2 补既有菜单回调的确定性回归；若复用GameRobot，定向修正其swipeDown错误调用并验证动作。确认测试实际执行，既有行为补测不制造RED，随机滑动结果不替代B01–B09。

2.1数据入口TDD：`game-seed-RED`退出65，3项实际运行中2失败/1通过，5条失败断言来自尚无种入行为；`game-seed-GREEN`退出0（23.956秒），新增3项与原40项共43项全通过。非测试启动不改存储、测试参数只写三个既有键，其他偏好保留。尚待真实UI前置和Release产物验证，暂不勾选。

2.2新增独立MenuUITests，直接执行向下手势，不复用GameRobot；其原swipeDown错误保留为旧随机测试局限，不计本轮覆盖。

2.2实际基线暴露B06：确认后屏幕best仍64，独立读取App存储为best0/score16/原棋盘，原bestScore没有发布界面更新。B01–B05与43项单元已运行通过，B07–B08未执行。Xcode在失败suite后未正常收尾，本轮保存原日志后SIGINT无效，再SIGTERM退出-15（299.028秒），设备Shutdown；不能算完整通过或用进程错误冒充RED。现为已批准“立即显示0”要求补通知回归，再只修UI通知，不改计算、存储规则、GameView回调或原Alert；不改Spec/Design/expected。

2.1 Release构建退出0（7.398秒），实际Mach-O字符串及符号无测试标记/入口，Debug正对照存在；证据位于game-release-seed-exclusion。真实UI初态已证实16/64及全部16格。

2.2通知回归`game-score-refresh-RED`实际执行1项、退出65（34.729秒），唯一失败为reset后objectWillChange通知数0；model的best0/score16/原棋盘断言均通过。仅在bestScore增加@Published以满足既定即时显示要求，计算、持久化、GameView两个回调、Alert及独立expected不变。正重跑原失败UI检查和44项单元；尚未宣称恢复。

2.2 GREEN：`game-menu-baseline-GREEN`退出0（77.204秒），44项单元与真实B01–B08全通过，B09原40项回归包含其中；设备Shutdown。原B06失败和受影响回归全部恢复，Xcode本轮正常退出，允许继续菜单资源。只增加bestScore的@Published通知，没有改变原值更新与持久化规则。

## 3. 菜单与资源

- [x] 3.1 对tokens及菜单资源加载建立可调用接口和测试，按项目TDD保存有效行为RED与最小实现GREEN；将两张原字节PNG按@2x和16pt capInsets导入独立imageset、tokens导入Bundle，检查摘要、尺寸、资源发现与解码结果。
- [x] 3.2 在MenuView接入获批背景、字体、按钮和提示，采用按钮宽min(312,可用宽-48)pt、高64pt、间隔16pt；保留GameView回调、原生Alert及其他ActionButton使用者。以原生构建、局部差异和实际菜单截图核对完成。

3.1资源已原字节导入：两PNG共1570字节、RGBA393216字节、tokens538字节，Bundle原字节、384×128/@2x预检先通过。`game-resources-RED`退出65（34.760秒），10项中9项因尚未加载/解析/分类错误失败；可调用接口和静态资源有效，不是缺包或编译错误。最小实现后`game-resources-GREEN`退出0（24.280秒），10项新检查＋此前44项共54项通过。缺图反例产生的CoreUI诊断保留，不冒充实际产品缺图。菜单现已接入，3.2等待原生结果和截图。

3.2已原生接入并核对：`game-final-SE`退出0（95.481秒），54项单元＋2项UI、B01–B08及312×64pt/16pt间距/边角触点全通过。回看默认菜单、原生Alert、取消、确认后及新局截图；实际资源与固定D一致，无缺图或切边。原GameView/ActionButton/GameOver/引擎/存储/StateTracker逐字节未改，ViewModel只多一条发布注解。最终Release也退出0（5.787秒），无测试入口、无SVG/HTML、tokens字节相同；17 Pro仍待验。

## 4. 两尺寸验收

- [x] 4.1 在SE3、17 Pro逐条运行固定B01–B09，记录菜单开关、确认/取消、重开及同进程前后台的actual；对当前实现重跑原40项单元回归，保存用例映射、日志/xcresult、退出码与设备清理结果，不能用旧通过代替新结果。
- [x] 4.2 核对两尺寸默认菜单、确认框、取消返回、确认后及新局画面，无切边、文字重叠、缺图或触点错位；保存截图及预算核对（PNG合计≤64KiB、RGBA≤1MiB、tokens≤16KiB），确认应用运行脱离design目录。

4.1/4.2：[两尺寸actual及工程视觉自查](../../../harness/evidence/final-runtime-review.json)。SE 95.481秒、17 Pro 91.534秒均退出0，各54项单元＋2项UI通过、0跳过；B01–B08实际点击/手势/前后台逐项通过，B09逐ID核对原40项回归。18张原生截图和两个完整xcresult受控保存；Codex回看两尺寸默认菜单、系统确认、取消、确认后及新局，尺寸/点击断言和预算通过。最终均Shutdown，运行只读Bundle。真人运行验收仍待5.1，不以自查代签。

## 5. 交付证据

- [x] 5.1 对照Proposal/Spec/Design、固定包和原始结果完成工程自审，整理可恢复的实现差异、唯一Tasks证据、失败与未验范围；将实际界面及行为验收提交当前用户，取得真实结论后保存原文。后续Archive/Sync仍按实际授权及原流程执行，本任务不授权正式合并或发布。

5.1：[真实运行验收及本地收尾授权](../../../harness/evidence/runtime-acceptance.json)。当前用户已对固定运行E `271b94809334b28d28a3b82fe2780b0648ed83187f49ed636d3a913ffdce5bc5`答复“运行验收通过，允许本地提交和归档”；产品字节与两尺寸受测版本一致。归档前已[重读UI实际权威及决定历史](../../../harness/evidence/ui-before-archive.json)，A/D及全部固定引用未变，无撤回。原始自审／运行记录保留当时的待审状态；本条记录后续真人结论。接续本地提交与Archive，主线合并、外部推送和发布未授权。
