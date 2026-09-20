# Sahakar : Instant Gig Support

> **Cooperative Gig Services & Statutory Social Security Platform**  
> Built for Smart India Hackathon (SIH) • Aligned with the **Code on Social Security 2020** (Enacted 21 Nov 2025)

---

## Overview

**Sahakar : Instant Gig Support** is a compliance-ready, democratic platform cooperative connecting certified gig workers (electricians, plumbers, appliance technicians, caregivers, cleaning staff, carpenters) directly with households.

Unlike private aggregators that charge 25–30% intermediary commissions, Sahakar operates on cooperative principles:
- **88% Direct Worker Wage Pass-through** (No predatory fee extraction)
- **7% Cooperative Operations & Platform Maintenance**
- **5% Statutory Social Security Fund (Sec 114)** (Accumulated for member pension, emergency aid, and accident cover)

---

## Key Features

### 1. Role-Based Unified Architecture
Single application supporting three distinct personas via a 3-tab login:
- **Customer / User**: Service booking, instant emergency dispatch (<5 min SLA), transparent co-op receipts, and live worker wayfinding.
- **Gig Worker (Sahakar Sathi)**: Real-time ticket dispatch alerts, job status lifecycle, **e-Shram Digital Pass**, and **₹5 Job Micro-Insurance Shield**.
- **Federation / Society Admin**: Statutory Social Security Fund monitoring (Sec 114 compliance), society member KYC verification queue, and district demand vs. worker allocation heatmaps.

### 2. Live Worker Wayfinding & Tracking
- Real-time animated route map with dynamic ETA countdown.
- Fraud-preventive **4-digit Service Start OTP** (shared with worker only upon physical arrival).
- Verified credentials display: e-Shram UAN badge, NSQF skill level, and primary cooperative society endorsement.

### 3. Statutory Compliance (Code on Social Security 2020)
- **Section 114**: Automated computation and tracking of the 1–2% turnover contribution towards the statutory Social Security Fund.
- **Section 113**: Compulsory Aadhaar-linked e-Shram registration and portable welfare benefits across India.
- **Micro-Insurance**: Automatic per-job accident cover up to ₹2,00,000.

---

## Tech Stack

- **Frontend**: Flutter 3.x (Multiplatform: Web, Android, iOS)
- **State Management**: Flutter Riverpod (`Notifier` & `NotifierProvider`)
- **Theme**: Complete Light & Dark mode support with high-contrast cooperative trust palettes
- **Localization**: Bhashini-ready multilingual engine (English, Hindi, Marathi, Bengali, Tamil, Telugu)
- **Assets**: Custom branding stored at `assets/img/logo.jpg` with vector fallback support

---

## Getting Started

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run application
flutter run

# Build release bundle for web
flutter build web --release
```

---

## Deploying to Vercel

The project is pre-configured for one-click deployment on Vercel:

### Method 1: Deploy via Vercel Git Integration (Recommended)
1. Push this repository to **GitHub**:
   ```bash
   git add .
   git commit -m "feat: complete sahakar cooperative platform"
   git remote add origin https://github.com/<your-username>/sahakar.git
   git branch -M main
   git push -u origin main
   ```
2. Go to [vercel.com](https://vercel.com) and click **"Add New Project"**.
3. Import your **`sahakar`** repository.
4. Vercel automatically detects `vercel.json`, executes `vercel-build.sh`, and serves the output from `build/web`.
5. Click **Deploy**!

### Method 2: Deploy via Vercel CLI
```bash
# Install / run Vercel CLI
npx vercel

# Deploy production build directly
npx vercel --prod
```

---

## Git Workflow

```bash
# Check status
git status

# Stage all files
git add .

# Commit changes
git commit -m "feat: ready for vercel deployment and live location"

# Push to remote repository
git push origin main
```
