import { supabase } from './supabase';

class ApiClient {
  async register(email: string, password: string) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });

    if (error) throw error;
    return { user: data.user, session: data.session };
  }

  async login(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
    return { user: data.user, session: data.session };
  }

  async logout() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  }

  async getCurrentUser() {
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error) throw error;
    return { user };
  }

  async adminLogin(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;

    const { data: adminData, error: adminError } = await supabase
      .from('admins')
      .select('*')
      .eq('user_id', data.user.id)
      .eq('is_active', true)
      .maybeSingle();

    if (adminError) throw adminError;
    if (!adminData) throw new Error('Not authorized as admin');

    return { user: data.user, admin: adminData, session: data.session };
  }

  async getAdmins() {
    const { data, error } = await supabase
      .from('admins')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  async createAdmin(adminData: { email: string; password: string; role?: string }) {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: adminData.email,
      password: adminData.password,
    });

    if (authError) throw authError;
    if (!authData.user) throw new Error('Failed to create user');

    const { data, error } = await supabase
      .from('admins')
      .insert({
        user_id: authData.user.id,
        email: adminData.email,
        role: adminData.role || 'admin',
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateAdmin(userId: string, updates: { role?: string; is_active?: boolean }) {
    const { data, error } = await supabase
      .from('admins')
      .update(updates)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteAdmin(userId: string) {
    const { error } = await supabase
      .from('admins')
      .delete()
      .eq('user_id', userId);

    if (error) throw error;
  }

  async createBooking(bookingData: any) {
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .insert({
        user_id: bookingData.user_id || null,
        name: bookingData.name,
        email: bookingData.email,
        phone: bookingData.phone,
        service_type: bookingData.service_type,
        preferred_date: bookingData.preferred_date,
        preferred_time: bookingData.preferred_time,
        message: bookingData.message,
        payment_method: bookingData.payment_method,
        total_amount: bookingData.total_amount,
        consultation_fee: bookingData.consultation_fee,
      })
      .select()
      .single();

    if (bookingError) throw bookingError;

    if (bookingData.services && bookingData.services.length > 0) {
      const services = bookingData.services.map((service: any) => ({
        booking_id: booking.id,
        service_name: service.service_name,
        service_price: service.service_price,
      }));

      const { error: servicesError } = await supabase
        .from('booking_services')
        .insert(services);

      if (servicesError) throw servicesError;
    }

    return booking;
  }

  async getBookings() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const { data, error } = await supabase
      .from('bookings')
      .select('*, booking_services(*)')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  async getAllBookings() {
    const { data, error } = await supabase
      .from('bookings')
      .select('*, booking_services(*)')
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  async updateBooking(id: string, updates: any) {
    const { data, error } = await supabase
      .from('bookings')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteBooking(id: string) {
    const { error } = await supabase
      .from('bookings')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  async getSimpleCases() {
    const { data, error } = await supabase
      .from('simple_cases')
      .select('*')
      .eq('is_active', true)
      .order('display_order', { ascending: true });

    if (error) throw error;
    return data;
  }

  async getAllSimpleCases() {
    const { data, error } = await supabase
      .from('simple_cases')
      .select('*')
      .order('display_order', { ascending: true });

    if (error) throw error;
    return data;
  }

  async createSimpleCase(caseData: any) {
    const { data, error } = await supabase
      .from('simple_cases')
      .insert(caseData)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateSimpleCase(id: string, updates: any) {
    const { data, error } = await supabase
      .from('simple_cases')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteSimpleCase(id: string) {
    const { error } = await supabase
      .from('simple_cases')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  async getDetailedCases(category?: string) {
    let query = supabase
      .from('detailed_cases')
      .select('*')
      .eq('is_active', true);

    if (category) {
      query = query.eq('category', category);
    }

    const { data, error } = await query.order('display_order', { ascending: true });

    if (error) throw error;
    return data;
  }

  async getAllDetailedCases() {
    const { data, error } = await supabase
      .from('detailed_cases')
      .select('*')
      .order('display_order', { ascending: true });

    if (error) throw error;
    return data;
  }

  async createDetailedCase(caseData: any) {
    const { data, error } = await supabase
      .from('detailed_cases')
      .insert(caseData)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateDetailedCase(id: string, updates: any) {
    const { data, error } = await supabase
      .from('detailed_cases')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteDetailedCase(id: string) {
    const { error } = await supabase
      .from('detailed_cases')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  async uploadImage(file: File) {
    const { data: { session } } = await supabase.auth.getSession();

    const formData = new FormData();
    formData.append('file', file);

    const response = await fetch(
      `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/upload-image`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${session?.access_token || import.meta.env.VITE_SUPABASE_ANON_KEY}`,
        },
        body: formData,
      }
    );

    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: 'Upload failed' }));
      throw new Error(error.error || 'Upload failed');
    }

    return response.json();
  }

  async uploadImages(files: File[]) {
    const results = await Promise.all(files.map(file => this.uploadImage(file)));
    return { urls: results.map(r => r.url), filenames: results.map(r => r.filename) };
  }
}

export const api = new ApiClient();
