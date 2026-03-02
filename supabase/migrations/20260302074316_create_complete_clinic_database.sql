/*
  # Complete Clinic Database Schema

  ## Overview
  Creates the complete database schema for the Yanora Clinic application including admin system, bookings, cases, and payments.

  ## New Tables

  ### 1. `admins` - Admin user management
  - `user_id` (uuid, primary key) - References auth.users
  - `email` (text, unique) - Admin email
  - `role` (text) - Admin role: admin or super_admin
  - `is_active` (boolean) - Whether admin is active
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 2. `bookings` - Customer appointment bookings
  - `id` (uuid, primary key)
  - `user_id` (uuid, nullable) - References auth.users for logged-in users
  - `name` (text) - Customer name
  - `email` (text) - Customer email
  - `phone` (text) - Customer phone
  - `service_type` (text) - Service requested
  - `preferred_date` (date) - Preferred date
  - `preferred_time` (text) - Preferred time
  - `message` (text, nullable) - Additional message
  - `status` (text) - pending, confirmed, cancelled, completed
  - `payment_method` (text, nullable) - Payment method
  - `payment_status` (text) - pending, paid, failed, refunded
  - `total_amount` (numeric) - Total amount
  - `consultation_fee` (numeric) - Consultation fee
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 3. `booking_services` - Services for each booking
  - `id` (uuid, primary key)
  - `booking_id` (uuid) - References bookings
  - `service_name` (text) - Service name
  - `service_price` (numeric) - Service price
  - `created_at` (timestamptz)

  ### 4. `simple_cases` - Simple before/after cases
  - `id` (uuid, primary key)
  - `before_image_url` (text) - Before image
  - `after_image_url` (text) - After image
  - `is_active` (boolean) - Active status
  - `display_order` (integer) - Display order
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 5. `detailed_cases` - Detailed cases with features
  - `id` (uuid, primary key)
  - `surgery_name` (text) - Surgery name
  - `before_image_url` (text) - Before image
  - `after_image_url` (text) - After image
  - `before_features` (jsonb) - Before features
  - `after_features` (jsonb) - After features
  - `category` (text) - Service category
  - `is_featured` (boolean) - Featured status
  - `is_active` (boolean) - Active status
  - `display_order` (integer) - Display order
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 6. `payments` - Payment records
  - `id` (uuid, primary key)
  - `booking_id` (uuid) - References bookings
  - `amount` (numeric) - Payment amount
  - `payment_method` (text) - Payment method
  - `payment_status` (text) - pending, completed, failed, refunded
  - `transaction_id` (text) - Transaction ID
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ## Security
  - Enable RLS on all tables
  - Admins have full access to all data
  - Users can access their own data
  - Public can view active cases and create bookings

  ## Performance
  - Indexes on foreign keys and frequently queried columns
  - Composite indexes for filtered queries
  - Automatic timestamp updates
*/

-- Create admins table
CREATE TABLE IF NOT EXISTS admins (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  role text NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  service_type text NOT NULL,
  preferred_date date NOT NULL,
  preferred_time text NOT NULL,
  message text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
  payment_method text CHECK (payment_method IN ('PayPal', '银行卡', '微信支付', '支付宝')),
  payment_status text NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  total_amount numeric(10,2) DEFAULT 0,
  consultation_fee numeric(10,2) DEFAULT 100,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create booking_services table
CREATE TABLE IF NOT EXISTS booking_services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  service_name text NOT NULL,
  service_price numeric(10,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create simple_cases table
CREATE TABLE IF NOT EXISTS simple_cases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  before_image_url text NOT NULL,
  after_image_url text NOT NULL,
  is_active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create detailed_cases table
CREATE TABLE IF NOT EXISTS detailed_cases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  surgery_name text NOT NULL,
  before_image_url text NOT NULL,
  after_image_url text NOT NULL,
  before_features jsonb DEFAULT '[]'::jsonb,
  after_features jsonb DEFAULT '[]'::jsonb,
  category text NOT NULL CHECK (category IN ('facial_contour', 'body_sculpting', 'injection_lifting', 'dental', 'hair_transplant')),
  is_featured boolean DEFAULT false,
  is_active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid REFERENCES bookings(id) ON DELETE CASCADE,
  amount numeric(10,2) NOT NULL,
  payment_method text NOT NULL,
  payment_status text NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
  transaction_id text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_active ON admins(is_active);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_booking_services_booking_id ON booking_services(booking_id);
CREATE INDEX IF NOT EXISTS idx_simple_cases_active_order ON simple_cases(is_active, display_order);
CREATE INDEX IF NOT EXISTS idx_detailed_cases_active_order ON detailed_cases(is_active, display_order);
CREATE INDEX IF NOT EXISTS idx_detailed_cases_category ON detailed_cases(category, is_active);
CREATE INDEX IF NOT EXISTS idx_detailed_cases_featured ON detailed_cases(is_featured, category, is_active);
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);

-- Create or replace function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
DROP TRIGGER IF EXISTS update_admins_updated_at ON admins;
CREATE TRIGGER update_admins_updated_at
  BEFORE UPDATE ON admins
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_bookings_updated_at ON bookings;
CREATE TRIGGER update_bookings_updated_at
  BEFORE UPDATE ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_simple_cases_updated_at ON simple_cases;
CREATE TRIGGER update_simple_cases_updated_at
  BEFORE UPDATE ON simple_cases
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_detailed_cases_updated_at ON detailed_cases;
CREATE TRIGGER update_detailed_cases_updated_at
  BEFORE UPDATE ON detailed_cases
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
CREATE TRIGGER update_payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security on all tables
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE simple_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE detailed_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- ========================================
-- RLS Policies for admins table
-- ========================================

-- Admins can view all admins
CREATE POLICY "Admins can view all admins"
  ON admins FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins AS a
      WHERE a.user_id = auth.uid()
      AND a.is_active = true
    )
  );

-- Super admins can insert new admins
CREATE POLICY "Super admins can create admins"
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

-- Super admins can update admins
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

-- Super admins can delete admins
CREATE POLICY "Super admins can delete admins"
  ON admins FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.role = 'super_admin'
      AND admins.is_active = true
    )
  );

-- ========================================
-- RLS Policies for bookings table
-- ========================================

-- Anyone can create bookings
CREATE POLICY "Anyone can create bookings"
  ON bookings FOR INSERT
  WITH CHECK (true);

-- Anyone can view bookings (for anonymous bookings by email)
CREATE POLICY "Anyone can view own bookings"
  ON bookings FOR SELECT
  USING (
    auth.uid() = user_id
    OR
    (auth.uid() IS NOT NULL AND email = (SELECT email FROM auth.users WHERE id = auth.uid()))
  );

-- Admins can view all bookings
CREATE POLICY "Admins can view all bookings"
  ON bookings FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- Users can update their own bookings
CREATE POLICY "Users can update own bookings"
  ON bookings FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = user_id
    OR
    email = (SELECT email FROM auth.users WHERE id = auth.uid())
  )
  WITH CHECK (
    auth.uid() = user_id
    OR
    email = (SELECT email FROM auth.users WHERE id = auth.uid())
  );

-- Admins can update all bookings
CREATE POLICY "Admins can update all bookings"
  ON bookings FOR UPDATE
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

-- Admins can delete bookings
CREATE POLICY "Admins can delete bookings"
  ON bookings FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- ========================================
-- RLS Policies for booking_services table
-- ========================================

-- Anyone can add services to bookings
CREATE POLICY "Anyone can add booking services"
  ON booking_services FOR INSERT
  WITH CHECK (true);

-- Users can view services for their bookings
CREATE POLICY "Users can view own booking services"
  ON booking_services FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings
      WHERE bookings.id = booking_services.booking_id
      AND (
        bookings.user_id = auth.uid()
        OR
        (auth.uid() IS NOT NULL AND bookings.email = (SELECT email FROM auth.users WHERE id = auth.uid()))
      )
    )
  );

-- Admins can view all booking services
CREATE POLICY "Admins can view all booking services"
  ON booking_services FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- Admins can update booking services
CREATE POLICY "Admins can update booking services"
  ON booking_services FOR UPDATE
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

-- Admins can delete booking services
CREATE POLICY "Admins can delete booking services"
  ON booking_services FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- ========================================
-- RLS Policies for simple_cases table
-- ========================================

-- Anyone can view active simple cases
CREATE POLICY "Anyone can view active simple cases"
  ON simple_cases FOR SELECT
  USING (is_active = true);

-- Admins can view all simple cases
CREATE POLICY "Admins can view all simple cases"
  ON simple_cases FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- Admins can insert simple cases
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

-- Admins can update simple cases
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

-- Admins can delete simple cases
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

-- ========================================
-- RLS Policies for detailed_cases table
-- ========================================

-- Anyone can view active detailed cases
CREATE POLICY "Anyone can view active detailed cases"
  ON detailed_cases FOR SELECT
  USING (is_active = true);

-- Admins can view all detailed cases
CREATE POLICY "Admins can view all detailed cases"
  ON detailed_cases FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- Admins can insert detailed cases
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

-- Admins can update detailed cases
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

-- Admins can delete detailed cases
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

-- ========================================
-- RLS Policies for payments table
-- ========================================

-- Admins can view all payments
CREATE POLICY "Admins can view all payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- Users can view payments for their bookings
CREATE POLICY "Users can view own payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bookings
      WHERE bookings.id = payments.booking_id
      AND bookings.user_id = auth.uid()
    )
  );

-- Admins can insert payments
CREATE POLICY "Admins can insert payments"
  ON payments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );

-- Admins can update payments
CREATE POLICY "Admins can update payments"
  ON payments FOR UPDATE
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

-- Admins can delete payments
CREATE POLICY "Admins can delete payments"
  ON payments FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.user_id = auth.uid()
      AND admins.is_active = true
    )
  );