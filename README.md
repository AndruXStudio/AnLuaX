# AnLuaX

Lua 开发与源码社区客户端（Material 3 Blue）。

基于开源 [LuaForge-Studio](https://github.com/wisyh/LuaForge-Studio) 的产品定位改造：
底栏「项目 / 代码 / 我的」，源码积分购买，登录注册邮箱验证码，角色头衔与封禁 BottomSheet。

## 路径

所有本地项目保存在应用文档目录下的 `AnLuaX/`。

## 运行

```bash
cd AnLuaX
flutter pub get
flutter run
```

## 演示账号

- 任意用户名/密码可登录（演示）
- 用户名 `banned`：触发封禁不可关闭 BottomSheet
- 用户名 `admin`：管理员头衔

## 功能清单

- 底栏：项目、代码、我的
- 代码帖列表/详情/积分购买
- 未登录拦截源码浏览
- 登录 / 注册（邮箱 + 6 位验证码弹窗）
- 用户主页与头衔
- 顶部菜单：导入源码、项目排序、软件设置
- 封禁 BottomSheet（审查时间/理由/违规/处罚/解封 + 申诉）
- 控件按压缩放与列表入场动画
