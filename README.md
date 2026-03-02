# Yanora 美容诊所管理系统

基于 Supabase + React 的现代化美容诊所预约和管理系统。

## 技术栈

### 后端
- Supabase (PostgreSQL + Auth + Edge Functions)
- Row Level Security (RLS)
- Edge Functions for file uploads

### 前端
- React + TypeScript
- Vite
- Tailwind CSS
- React Router
- Supabase Client

## 快速开始

### 前置要求

- Node.js 18+
- Supabase 账户
- npm 或 yarn

### 1. 克隆项目

```bash
git clone <repository-url>
cd project
```

### 2. 安装依赖

```bash
npm install
```

### 3. 配置 Supabase

创建 `.env` 文件:
```env
VITE_SUPABASE_URL=your-supabase-project-url
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
```

数据库迁移已经包含在 `supabase/migrations/` 目录中,所有表和 RLS 策略会自动应用。

### 4. 创建管理员账户

使用 Supabase Dashboard 或 SQL 编辑器:

```sql
-- 首先创建一个用户(通过 Supabase Auth 或 Dashboard)
-- 然后将其添加为管理员
INSERT INTO admins (user_id, email, role, is_active)
VALUES (
  'user-uuid-from-auth-users',
  'admin@example.com',
  'super_admin',
  true
);
```

### 5. 启动开发服务器

```bash
npm run dev
```

应用将运行在 http://localhost:5173

## 项目结构

```
project/
├── src/                        # 前端源码
│   ├── components/             # React 组件
│   ├── contexts/              # React Context
│   ├── lib/
│   │   ├── api.ts             # API 客户端 (Supabase)
│   │   └── supabase.ts        # Supabase 配置
│   └── ...
├── supabase/                   # Supabase 配置
│   ├── migrations/            # 数据库迁移
│   └── functions/             # Edge Functions
│       └── upload-image/      # 图片上传函数
├── public/                    # 静态文件
└── dist/                      # 构建输出
```

## 数据库架构

### 表结构

- **profiles** - 用户资料
- **admins** - 管理员
- **bookings** - 预约记录
- **booking_services** - 预约服务明细
- **simple_cases** - 简单案例(首页展示)
- **detailed_cases** - 详细案例(服务页面)
- **payments** - 支付记录

### Row Level Security (RLS)

所有表都启用了 RLS,确保:
- 管理员可以管理所有数据
- 用户只能访问自己的数据
- 公开案例对所有人可见
- 匿名用户可以创建预约

## 功能说明

### 认证系统
- 使用 Supabase Auth 进行身份验证
- 支持邮箱/密码登录
- 管理员权限系统

### 预约管理
- 支持匿名和已登录用户预约
- 多服务选择
- 预约状态追踪
- 支付状态管理

### 案例管理
- 简单案例:首页轮播展示
- 详细案例:按类别分类展示
- Before/After 图片对比
- 特征标注系统

### 文件上传
- 通过 Supabase Edge Function 处理
- 安全的文件存储

## 部署

### 1. 构建生产版本

```bash
npm run build
```

构建的文件在 `dist/` 目录。

### 2. Supabase 配置

确保以下内容已在 Supabase Dashboard 中配置:
- 所有数据库迁移已应用
- Edge Functions 已部署
- 认证设置已配置

### 3. 环境变量

生产环境 `.env`:
```env
VITE_SUPABASE_URL=your-production-supabase-url
VITE_SUPABASE_ANON_KEY=your-production-anon-key
```

### 4. 部署前端

可以部署到:
- Vercel
- Netlify
- Cloudflare Pages
- 任何静态托管服务

## 开发指南

### 添加新功能

1. 如需新表,在 `supabase/migrations/` 创建迁移文件
2. 在 `src/lib/api.ts` 添加 API 方法
3. 在组件中使用

### 数据库迁移

所有迁移文件在 `supabase/migrations/` 目录中。
Supabase 会自动按时间戳顺序应用迁移。

### Edge Functions

Edge Functions 位于 `supabase/functions/` 目录。
部署后可通过以下 URL 访问:
```
https://your-project.supabase.co/functions/v1/function-name
```

## 故障排除

### 认证失败
- 检查 Supabase URL 和 Anon Key
- 验证用户是否已注册
- 检查 RLS 策略

### 数据访问问题
- 确认 RLS 策略配置正确
- 验证用户权限
- 检查是否为管理员

### 文件上传失败
- 确认 Edge Function 已部署
- 检查认证状态
- 验证文件大小和格式

## 许可证

MIT
