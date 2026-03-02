/*
  # 创建管理员系统

  ## 概述
  创建管理员表用于管理后台系统

  ## 新建表

  ### `admins` - 管理员表
  - `user_id` (uuid, 主键) - 关联auth.users
  - `email` (text) - 邮箱
  - `role` (text) - 角色 (admin/super_admin)
  - `is_active` (boolean) - 是否激活
  - `created_at` (timestamptz) - 创建时间
  - `updated_at` (timestamptz) - 更新时间

  ## 安全设置
  - 启用RLS
  - 仅管理员可以查看管理员表
  - 仅超级管理员可以管理其他管理员

  ## 注意事项
  - 管理员需要先在auth.users中注册
  - 然后在admins表中添加记录赋予管理员权限
*/

-- 创建管理员表
CREATE TABLE IF NOT EXISTS admins (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  role text NOT NULL DEFAULT 'admin',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 启用RLS
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- 管理员可以查看所有管理员
CREATE POLICY "Admins can view all admins"
  ON admins FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- 超级管理员可以添加管理员
CREATE POLICY "Super admins can insert admins"
  ON admins FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.role = 'super_admin'
      AND admins.is_active = true
    )
  );

-- 超级管理员可以更新管理员
CREATE POLICY "Super admins can update admins"
  ON admins FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.role = 'super_admin'
      AND admins.is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.role = 'super_admin'
      AND admins.is_active = true
    )
  );

-- 添加角色约束
ALTER TABLE admins 
  ADD CONSTRAINT check_role 
  CHECK (role IN ('admin', 'super_admin'));