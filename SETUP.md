# EVO Website Builder - Stripe Payment Setup

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Start the Server
```bash
npm start
```

### 3. Access the Builder
Visit: `http://localhost:3000`

## 💳 Payment Integration

The website builder now includes Stripe payment processing for £88.

### Features:
- ✅ **Preview Mode**: Users see hero section only
- ✅ **Payment Required**: Full website download after payment
- ✅ **Stripe Integration**: Secure payment processing
- ✅ **Automatic Download**: Website downloads after successful payment

### Payment Flow:
1. User builds website (9 steps)
2. Sees hero section preview
3. Clicks "Unlock Full Website - £88"
4. Redirected to Stripe Checkout
5. After payment, website automatically downloads

## 🔧 Configuration

### Environment Variables:
Create a `.env` file in the root directory with:
```
STRIPE_SECRET_KEY=your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
PORT=3000
```

### Stripe Keys:
- **Publishable Key**: Configured in the frontend
- **Secret Key**: Loaded from environment variables

### Price:
- **Amount**: £88.00 (8800 pence)
- **Currency**: GBP

## 📁 File Structure
```
├── server.js          # Express server with Stripe integration
├── package.json       # Node.js dependencies
├── builder/
│   └── central-builder.html  # Main builder with payment integration
├── index.html         # Landing page
└── builder-editor.html # Builder entry point
```

## 🚀 Deployment

### For Production:
1. Set environment variables:
   ```bash
   export PORT=3000
   ```

2. Start the server:
   ```bash
   npm start
   ```

### For Development:
```bash
npm run dev
```

## 🔒 Security Notes

- Stripe secret key is configured in server.js
- All payments are processed securely through Stripe
- No payment data is stored locally

## 📞 Support

For payment issues or questions, contact your Stripe dashboard or the development team.
