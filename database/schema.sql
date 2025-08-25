-- Supabase Database Schema for EVO Website Builders
-- Run this in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types for website categories
CREATE TYPE website_category AS ENUM (
    'event-essentials',
    'professionals', 
    'sports',
    'personal',
    'ai-agents',
    'lms-apps',
    'website-design',
    'marketing-campaigns'
);

CREATE TYPE profession_type AS ENUM (
    'doctor',
    'therapist',
    'counsellor',
    'trainer',
    'coach',
    'psychologist',
    'nutritionist',
    'chiropractor',
    'dentist',
    'other'
);

-- Users table (optional - for future user management)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Website templates table
CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    category website_category NOT NULL,
    description TEXT,
    template_data JSONB NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Generated websites table
CREATE TABLE websites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    template_id UUID REFERENCES templates(id) ON DELETE SET NULL,
    category website_category NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    website_data JSONB NOT NULL,
    is_published BOOLEAN DEFAULT false,
    published_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Form submissions table (for contact forms)
CREATE TABLE form_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    website_id UUID REFERENCES websites(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Website analytics table (for future tracking)
CREATE TABLE website_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    website_id UUID REFERENCES websites(id) ON DELETE CASCADE,
    page_views INTEGER DEFAULT 0,
    unique_visitors INTEGER DEFAULT 0,
    contact_form_submissions INTEGER DEFAULT 0,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_websites_category ON websites(category);
CREATE INDEX idx_websites_user_id ON websites(user_id);
CREATE INDEX idx_websites_slug ON websites(slug);
CREATE INDEX idx_websites_published ON websites(is_published);
CREATE INDEX idx_form_submissions_website_id ON form_submissions(website_id);
CREATE INDEX idx_form_submissions_created_at ON form_submissions(created_at);
CREATE INDEX idx_analytics_website_date ON website_analytics(website_id, date);

-- Create a function to generate unique slugs
CREATE OR REPLACE FUNCTION generate_unique_slug(base_name TEXT)
RETURNS TEXT AS $$
DECLARE
    slug TEXT;
    counter INTEGER := 0;
    final_slug TEXT;
BEGIN
    -- Convert to lowercase and replace spaces with hyphens
    slug := LOWER(REGEXP_REPLACE(base_name, '[^a-zA-Z0-9\s]', '', 'g'));
    slug := REGEXP_REPLACE(slug, '\s+', '-', 'g');
    slug := TRIM(BOTH '-' FROM slug);
    
    final_slug := slug;
    
    -- Check if slug exists and append number if needed
    WHILE EXISTS(SELECT 1 FROM websites WHERE slug = final_slug) LOOP
        counter := counter + 1;
        final_slug := slug || '-' || counter;
    END LOOP;
    
    RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Create a function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_templates_updated_at BEFORE UPDATE ON templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_websites_updated_at BEFORE UPDATE ON websites
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some default templates
INSERT INTO templates (name, category, description, template_data) VALUES
('Professional Medical', 'professionals', 'Clean and trustworthy design for medical professionals', '{"colors": {"primary": "#00bcd4", "secondary": "#4caf50"}, "layout": "medical"}'),
('Event Essentials', 'event-essentials', 'Perfect for events and special occasions', '{"colors": {"primary": "#ff6b6b", "secondary": "#ffd700"}, "layout": "event"}'),
('Personal Trainer', 'professionals', 'Energetic design for fitness professionals', '{"colors": {"primary": "#ffc107", "secondary": "#ff5722"}, "layout": "fitness"}'),
('Therapist', 'professionals', 'Calming and professional design for mental health professionals', '{"colors": {"primary": "#9c27b0", "secondary": "#673ab7"}, "layout": "therapy"}');

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE websites ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE website_analytics ENABLE ROW LEVEL SECURITY;

-- Create policies for public access to published websites
CREATE POLICY "Public websites are viewable by everyone" ON websites
    FOR SELECT USING (is_published = true);

CREATE POLICY "Anyone can create a website" ON websites
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update their own website" ON websites
    FOR UPDATE USING (true);

CREATE POLICY "Anyone can submit contact forms" ON form_submissions
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can read contact forms" ON form_submissions
    FOR SELECT USING (true);

-- Create policies for template access
CREATE POLICY "Templates are viewable by everyone" ON templates
    FOR SELECT USING (is_active = true);

-- Create policies for analytics
CREATE POLICY "Anyone can insert analytics" ON website_analytics
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update analytics" ON website_analytics
    FOR UPDATE USING (true);

-- Create a view for website statistics
CREATE VIEW website_stats AS
SELECT 
    w.id,
    w.name,
    w.category,
    w.is_published,
    w.created_at,
    COUNT(fs.id) as contact_submissions,
    COALESCE(SUM(wa.page_views), 0) as total_page_views,
    COALESCE(SUM(wa.unique_visitors), 0) as total_unique_visitors
FROM websites w
LEFT JOIN form_submissions fs ON w.id = fs.website_id
LEFT JOIN website_analytics wa ON w.id = wa.website_id
GROUP BY w.id, w.name, w.category, w.is_published, w.created_at;
