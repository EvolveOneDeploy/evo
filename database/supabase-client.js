// Supabase Client Configuration for EVO Website Builders
// Replace these values with your actual Supabase project credentials

const SUPABASE_URL = 'https://ivehwhjezrykvyydqxcz.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_vLyV0ELVx9cjmOVWavTdOw_VSVDCRWx';

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Database helper functions
class WebsiteBuilderDB {
    
    // Save website data to database
    static async saveWebsite(websiteData) {
        try {
            const { data, error } = await supabase
                .from('websites')
                .insert({
                    category: websiteData.category,
                    name: websiteData.name || 'My Website',
                    slug: this.generateSlug(websiteData.name || 'My Website'),
                    website_data: websiteData,
                    is_published: false
                })
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error saving website:', error);
            throw error;
        }
    }

    // Get website by slug
    static async getWebsiteBySlug(slug) {
        try {
            const { data, error } = await supabase
                .from('websites')
                .select('*')
                .eq('slug', slug)
                .eq('is_published', true)
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error fetching website:', error);
            throw error;
        }
    }

    // Update website data
    static async updateWebsite(websiteId, updates) {
        try {
            const { data, error } = await supabase
                .from('websites')
                .update(updates)
                .eq('id', websiteId)
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error updating website:', error);
            throw error;
        }
    }

    // Publish website
    static async publishWebsite(websiteId) {
        try {
            const { data, error } = await supabase
                .from('websites')
                .update({
                    is_published: true,
                    published_url: `${window.location.origin}/website/${data.slug}`
                })
                .eq('id', websiteId)
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error publishing website:', error);
            throw error;
        }
    }

    // Save contact form submission
    static async saveContactForm(websiteId, formData) {
        try {
            const { data, error } = await supabase
                .from('form_submissions')
                .insert({
                    website_id: websiteId,
                    name: formData.name,
                    email: formData.email,
                    phone: formData.phone,
                    message: formData.message
                })
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error saving contact form:', error);
            throw error;
        }
    }

    // Get templates by category
    static async getTemplatesByCategory(category) {
        try {
            const { data, error } = await supabase
                .from('templates')
                .select('*')
                .eq('category', category)
                .eq('is_active', true);

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error fetching templates:', error);
            throw error;
        }
    }

    // Track page view
    static async trackPageView(websiteId) {
        try {
            const today = new Date().toISOString().split('T')[0];
            
            // Check if analytics record exists for today
            const { data: existing } = await supabase
                .from('website_analytics')
                .select('id, page_views')
                .eq('website_id', websiteId)
                .eq('date', today)
                .single();

            if (existing) {
                // Update existing record
                await supabase
                    .from('website_analytics')
                    .update({ page_views: existing.page_views + 1 })
                    .eq('id', existing.id);
            } else {
                // Create new record
                await supabase
                    .from('website_analytics')
                    .insert({
                        website_id: websiteId,
                        page_views: 1,
                        date: today
                    });
            }
        } catch (error) {
            console.error('Error tracking page view:', error);
        }
    }

    // Generate unique slug
    static generateSlug(name) {
        return name
            .toLowerCase()
            .replace(/[^a-z0-9\s-]/g, '')
            .replace(/\s+/g, '-')
            .replace(/-+/g, '-')
            .trim('-');
    }

    // Get website statistics
    static async getWebsiteStats(websiteId) {
        try {
            const { data, error } = await supabase
                .from('website_stats')
                .select('*')
                .eq('id', websiteId)
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error fetching website stats:', error);
            throw error;
        }
    }
}

// Form validation helper
class FormValidator {
    static validateEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    static validatePhone(phone) {
        const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
        return phoneRegex.test(phone.replace(/\s/g, ''));
    }

    static validateRequired(value) {
        return value && value.trim().length > 0;
    }
}

// Export for use in other files
window.WebsiteBuilderDB = WebsiteBuilderDB;
window.FormValidator = FormValidator;
