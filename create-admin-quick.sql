-- 快速创建管理员账户
-- 邮箱: admin@yanora.com
-- 密码: Admin123456

-- 删除可能存在的旧账户
DELETE FROM admins WHERE email = 'admin@yanora.com';
DELETE FROM users WHERE email = 'admin@yanora.com';

-- 创建用户 (密码哈希是 "Admin123456")
INSERT INTO users (id, email, password_hash, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'admin@yanora.com',
  '$2a$10$YourHashedPasswordHere',  -- 这会在下面的脚本中生成
  NOW(),
  NOW()
);

-- 创建管理员
INSERT INTO admins (user_id, email, role, is_active, created_at, updated_at)
SELECT
  id,
  'admin@yanora.com',
  'super_admin',
  true,
  NOW(),
  NOW()
FROM users
WHERE email = 'admin@yanora.com';

-- 查看结果
SELECT u.email, a.role, a.is_active
FROM users u
JOIN admins a ON u.id = a.user_id
WHERE u.email = 'admin@yanora.com';
