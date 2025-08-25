# Supabase Setup Guide for EVO Website Builders

## 🚀 Quick Setup Steps

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up/Login with your GitHub account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `evo-website-builders`
   - **Database Password**: Create a strong password
   - **Region**: Choose closest to your users
6. Click "Create new project"

### 2. Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy your **Project URL** and **anon public** key
3. Update the credentials in `database/supabase-client.js`:

```javascript
const SUPABASE_URL = 'https://your-project-id.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key-here';
```

### 3. Set Up the Database Schema

1. In Supabase dashboard, go to **SQL Editor**
2. Copy the entire contents of `database/schema.sql`
3. Paste and run the SQL script
4. This will create all necessary tables and functions

### 4. Add Supabase Client to Your HTML Files

Add this script tag to your HTML files before your other scripts:

```html
<script src="https://unpkg.com/@supabase/supabase-js@2"></script>
<script src="database/supabase-client.js"></script>
```

### 5. Test the Connection

Add this to any page to test the connection:

```javascript
// Test database connection
async function testConnection() {
    try {
        const { data, error } = await supabase
            .from('templates')
            .select('*')
            .limit(1);
        
        if (error) {
            console.error('Connection failed:', error);
        } else {
            console.log('Connection successful!', data);
        }
    } catch (error) {
        console.error('Connection error:', error);
    }
}

testConnection();
```

## 📊 Database Schema Overview

### Tables Created:

1. **users** - User management (optional)
2. **templates** - Website templates by category
3. **websites** - Generated website data
4. **form_submissions** - Contact form submissions
5. **website_analytics** - Page views and visitor tracking

### Key Features:

- **Automatic slug generation** for unique URLs
- **Row Level Security** for data protection
- **Analytics tracking** for website performance
- **Contact form storage** for lead management
- **Template system** for different website types

## 🔧 Integration with Website Builders

### Update the Generate Website Function

Replace the localStorage approach with database storage:

```javascript
async function generateWebsite() {
    try {
        // Collect form data
        const formData = new FormData(document.getElementById('professionalsForm'));
        const data = Object.fromEntries(formData);
        
        // Add selected services
        data.services = Array.from(document.querySelectorAll('input[name="services"]:checked')).map(cb => cb.value);
        data.category = 'professionals';
        
        // Save to database
        const savedWebsite = await WebsiteBuilderDB.saveWebsite(data);
        
        // Redirect to generated website
        window.location.href = `generated-professionals-website.html?id=${savedWebsite.id}`;
        
    } catch (error) {
        console.error('Error generating website:', error);
        alert('Error creating website. Please try again.');
    }
}
```

### Update Generated Websites to Load from Database

```javascript
async function loadWebsiteData() {
    try {
        // Get website ID from URL
        const urlParams = new URLSearchParams(window.location.search);
        const websiteId = urlParams.get('id');
        
        if (!websiteId) {
            console.error('No website ID provided');
            return;
        }
        
        // Load website data from database
        const website = await WebsiteBuilderDB.getWebsiteBySlug(websiteId);
        
        if (!website) {
            console.error('Website not found');
            return;
        }
        
        // Populate the website with data
        populateWebsite(website.website_data);
        
        // Track page view
        await WebsiteBuilderDB.trackPageView(websiteId);
        
    } catch (error) {
        console.error('Error loading website:', error);
    }
}
```

## 🔒 Security Considerations

### Row Level Security (RLS) Policies

The schema includes RLS policies that:
- Allow public access to published websites
- Allow anyone to create websites
- Allow contact form submissions
- Protect user data and unpublished websites

### API Key Security

- Use the **anon public** key for client-side operations
- Keep the **service_role** key secure (server-side only)
- The anon key has limited permissions defined by RLS policies

## 📈 Analytics and Monitoring

### Track Website Performance

```javascript
// Track page views automatically
await WebsiteBuilderDB.trackPageView(websiteId);

// Get website statistics
const stats = await WebsiteBuilderDB.getWebsiteStats(websiteId);
console.log('Page views:', stats.total_page_views);
console.log('Contact submissions:', stats.contact_submissions);
```

### Monitor Contact Form Submissions

All contact form submissions are stored in the database and can be:
- Viewed in the Supabase dashboard
- Exported for analysis
- Used for lead management
- Integrated with email marketing tools

## 🚀 Deployment Considerations

### Environment Variables

For production, use environment variables:

```javascript
const SUPABASE_URL = process.env.SUPABASE_URL || 'your-url';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'your-key';
```

### CORS Configuration

In Supabase dashboard:
1. Go to **Settings** → **API**
2. Add your domain to **Additional Allowed Origins**
3. Include both development and production URLs

### Backup Strategy

- Enable **Point-in-time recovery** in Supabase
- Set up automated backups
- Export data regularly for additional safety

## 🎯 Next Steps

1. **Test the setup** with a sample website
2. **Customize templates** for your specific needs
3. **Add user authentication** if needed
4. **Set up email notifications** for form submissions
5. **Configure analytics** and monitoring
6. **Deploy to production** with proper environment variables

## 🆘 Troubleshooting

### Common Issues:

1. **CORS errors**: Check allowed origins in Supabase settings
2. **RLS policy errors**: Verify policies are correctly set up
3. **Connection timeouts**: Check network and Supabase status
4. **Schema errors**: Ensure SQL script ran completely

### Support:

- Check [Supabase documentation](https://supabase.com/docs)
- Review [Supabase community](https://github.com/supabase/supabase/discussions)
- Contact Supabase support for account issues
