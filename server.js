require('dotenv').config();
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('.'));

// Stripe payment session endpoint
app.post('/create-payment-session', async (req, res) => {
    try {
        const { amount, currency, description, success_url, cancel_url } = req.body;

        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [
                {
                    price_data: {
                        currency: currency,
                        product_data: {
                            name: description,
                        },
                        unit_amount: amount,
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: success_url + '&session_id={CHECKOUT_SESSION_ID}',
            cancel_url: cancel_url,
        });

        res.json({ id: session.id });
    } catch (error) {
        console.error('Error creating payment session:', error);
        res.status(500).json({ error: 'Failed to create payment session' });
    }
});

// Payment verification endpoint
app.post('/verify-payment', async (req, res) => {
    try {
        const { session_id } = req.body;
        
        const session = await stripe.checkout.sessions.retrieve(session_id);
        
        if (session.payment_status === 'paid') {
            res.json({ verified: true, session: session });
        } else {
            res.json({ verified: false });
        }
    } catch (error) {
        console.error('Error verifying payment:', error);
        res.status(500).json({ verified: false, error: 'Payment verification failed' });
    }
});

// Website publishing endpoint
app.post('/publish-website', async (req, res) => {
    try {
        const { websiteData } = req.body;
        
        // Generate unique website ID
        const websiteId = Date.now().toString(36) + Math.random().toString(36).substr(2);
        
        // Create website HTML
        const websiteHTML = generateCompleteWebsite(websiteData);
        
        // Save website data (you can integrate with a database here)
        const publishedWebsite = {
            id: websiteId,
            data: websiteData,
            html: websiteHTML,
            publishedAt: new Date().toISOString(),
            url: `https://yourdomain.com/websites/${websiteId}`
        };
        
        // For now, we'll return the website data
        // In production, you'd save this to a database and host the files
        res.json({ 
            success: true, 
            websiteId: websiteId,
            url: publishedWebsite.url,
            message: 'Website published successfully!'
        });
    } catch (error) {
        console.error('Error publishing website:', error);
        res.status(500).json({ error: 'Failed to publish website' });
    }
});

// Function to generate complete website (copy from frontend)
function generateCompleteWebsite(data) {
    // This would be the same function as in your frontend
    // For now, returning a placeholder
    return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${data.brandName}</title>
    <style>
        /* Your website styles here */
    </style>
</head>
<body>
    <h1>${data.brandName}</h1>
    <p>Your website content here</p>
</body>
</html>`;
}

// Serve the main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Serve the builder
app.get('/builder', (req, res) => {
    res.sendFile(path.join(__dirname, 'builder-editor.html'));
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Visit: http://localhost:${PORT}`);
});
