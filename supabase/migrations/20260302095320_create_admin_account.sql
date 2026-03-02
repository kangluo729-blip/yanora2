/*
  # 创建管理员账户
  
  1. 功能说明
    - 使用 Supabase Auth 扩展创建管理员账户
    - 邮箱: admin@yanora.com
    - 密码: Admin123456!
  
  2. 实现方式
    - 使用 auth 扩展的辅助函数创建用户
    - 自动添加到 admins 表
    - 设置为超级管理员角色
  
  3. 重要提示
    - 首次登录后请立即修改密码
    - 此账户拥有最高权限
*/

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 创建管理员用户的函数
CREATE OR REPLACE FUNCTION create_admin_user()
RETURNS void AS $$
DECLARE
  new_user_id uuid;
BEGIN
  -- 生成新的 UUID
  new_user_id := gen_random_uuid();
  
  -- 直接插入到 auth.users 表（简化版本）
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role
  ) 
  SELECT
    new_user_id,
    '00000000-0000-0000-0000-000000000000',
    'admin@yanora.com',
    crypt('Admin123456!', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    'authenticated',
    'authenticated'
  WHERE NOT EXISTS (
    SELECT 1 FROM auth.users WHERE email = 'admin@yanora.com'
  );
  
  -- 如果用户已存在，获取其 ID
  IF NOT FOUND THEN
    SELECT id INTO new_user_id FROM auth.users WHERE email = 'admin@yanora.com';
  END IF;
  
  -- 如果找到用户 ID，插入到 admins 表
  IF new_user_id IS NOT NULL THEN
    INSERT INTO admins (user_id, email, role, is_active)
    VALUES (new_user_id, 'admin@yanora.com', 'super_admin', true)
    ON CONFLICT (user_id) 
    DO UPDATE SET
      role = 'super_admin',
      is_active = true,
      updated_at = now();
  END IF;
  
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 执行函数创建管理员
SELECT create_admin_user();

-- 删除临时函数
DROP FUNCTION IF EXISTS create_admin_user();
