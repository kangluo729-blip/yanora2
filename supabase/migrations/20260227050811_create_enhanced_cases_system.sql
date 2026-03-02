/*
  # 创建增强的案例管理系统

  ## 概述
  创建两种类型的案例系统:
  1. 简单案例 (simple_cases) - 仅包含图片,显示在首页
  2. 详细案例 (detailed_cases) - 包含图片和详细信息,显示在案例页面和服务页面

  ## 新建表

  ### `simple_cases` - 简单案例表
  - `id` (uuid, 主键) - 唯一标识
  - `before_image_url` (text) - 术前图片URL
  - `after_image_url` (text) - 术后图片URL
  - `is_active` (boolean) - 是否激活显示
  - `display_order` (integer) - 显示顺序
  - `created_at` (timestamptz) - 创建时间
  - `updated_at` (timestamptz) - 更新时间

  ### `detailed_cases` - 详细案例表
  - `id` (uuid, 主键) - 唯一标识
  - `surgery_name` (text) - 手术名称
  - `before_image_url` (text) - 术前图片URL
  - `after_image_url` (text) - 术后图片URL
  - `before_features` (jsonb) - 术前特征数组 [{feature: "特征描述"}]
  - `after_features` (jsonb) - 术后特征数组 [{feature: "特征描述"}]
  - `category` (text) - 分类 (facial_contour, body_sculpting, injection_lifting, dental, hair_transplant)
  - `is_featured` (boolean) - 是否精选(显示在服务页面)
  - `is_active` (boolean) - 是否激活显示
  - `display_order` (integer) - 显示顺序
  - `created_at` (timestamptz) - 创建时间
  - `updated_at` (timestamptz) - 更新时间

  ## 安全设置
  - 启用RLS
  - 公开访问激活的案例
  - 管理员可以管理所有案例

  ## 注意事项
  - simple_cases显示在首页"他们通过yanora找回自信"部分
  - detailed_cases显示在案例页面,精选案例显示在对应的服务页面
  - 使用jsonb存储特征数组,方便动态添加
*/

-- 创建简单案例表
CREATE TABLE IF NOT EXISTS simple_cases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  before_image_url text NOT NULL,
  after_image_url text NOT NULL,
  is_active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 创建详细案例表
CREATE TABLE IF NOT EXISTS detailed_cases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  surgery_name text NOT NULL,
  before_image_url text NOT NULL,
  after_image_url text NOT NULL,
  before_features jsonb DEFAULT '[]'::jsonb,
  after_features jsonb DEFAULT '[]'::jsonb,
  category text NOT NULL,
  is_featured boolean DEFAULT false,
  is_active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 启用RLS - simple_cases
ALTER TABLE simple_cases ENABLE ROW LEVEL SECURITY;

-- 允许所有人查看激活的简单案例
CREATE POLICY "Anyone can view active simple cases"
  ON simple_cases FOR SELECT
  USING (is_active = true);

-- 允许认证用户查看所有简单案例
CREATE POLICY "Authenticated users can view all simple cases"
  ON simple_cases FOR SELECT
  TO authenticated
  USING (true);

-- 允许管理员管理简单案例
CREATE POLICY "Admins can insert simple cases"
  ON simple_cases FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

CREATE POLICY "Admins can update simple cases"
  ON simple_cases FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

CREATE POLICY "Admins can delete simple cases"
  ON simple_cases FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- 启用RLS - detailed_cases
ALTER TABLE detailed_cases ENABLE ROW LEVEL SECURITY;

-- 允许所有人查看激活的详细案例
CREATE POLICY "Anyone can view active detailed cases"
  ON detailed_cases FOR SELECT
  USING (is_active = true);

-- 允许认证用户查看所有详细案例
CREATE POLICY "Authenticated users can view all detailed cases"
  ON detailed_cases FOR SELECT
  TO authenticated
  USING (true);

-- 允许管理员管理详细案例
CREATE POLICY "Admins can insert detailed cases"
  ON detailed_cases FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

CREATE POLICY "Admins can update detailed cases"
  ON detailed_cases FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

CREATE POLICY "Admins can delete detailed cases"
  ON detailed_cases FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_simple_cases_active_order 
  ON simple_cases(is_active, display_order);

CREATE INDEX IF NOT EXISTS idx_detailed_cases_active_order 
  ON detailed_cases(is_active, display_order);

CREATE INDEX IF NOT EXISTS idx_detailed_cases_category 
  ON detailed_cases(category, is_active);

CREATE INDEX IF NOT EXISTS idx_detailed_cases_featured 
  ON detailed_cases(is_featured, category, is_active);

-- 添加约束检查分类值
ALTER TABLE detailed_cases 
  ADD CONSTRAINT check_category 
  CHECK (category IN ('facial_contour', 'body_sculpting', 'injection_lifting', 'dental', 'hair_transplant'));