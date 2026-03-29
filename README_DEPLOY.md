# 🚀 BetterBarter: Hackathon Deployment Guide

This guide ensures your neighbor-to-neighbor trading demo is flawless. The app is fully integrated with **Firebase** and supports real-time synchronization between multiple physical iPhones and simulators.

## 📱 Device Setup (2-Device Demo)

### 1. Connecting the Hardware
- Connect both iPhones to your Mac using USB-C or Lightning cables.
- In Xcode, select the **active scheme** (BetterBarter) and then select your **first physical iPhone** from the device list.

### 2. Signing & Capabilities
> [!IMPORTANT]
> If you are using your own Apple ID, you must update the **Bundle Identifier** to be unique.
- In the project list, click the blue **BetterBarter** icon at the top.
- Go to **Targets > BetterBarter > Signing & Capabilities**.
- Select your **Team** (e.g., your Personal Team).
- Change the **Bundle Identifier** to something like `abc.BetterBarter.demo.[your-name]`.
- Click **Automatically manage signing**.

### 3. Trusting the Developer
- Once the app builds and installs, you must "trust" it on the iPhone:
- Go to **Settings > General > VPN & Device Management**.
- Click your Apple ID and tap **Trust "Apple Development: [your-id]"**.

### 4. Repeat for Device 2
- Unplug the first phone, plug in the second, and repeat **Steps 1-3**.

---

## 🎭 The Perfect Demo Script

### Step 1: Sequential Signup
- **Device 1**: Sign up neighbor `a@b.com` (use password `123456`). Add "Home Cooking" as a skill.
- **Device 2**: Sign up neighbor `b@c.com` (use password `123456`). Add "Gardening" as a skill.

### Step 2: Instant Listing Sync
- **Device 1**: Create a new listing (Offer) for "Home Cooked Meal".
- **Device 2**: Switch to the **Explore** tab. The listing should appear **instantly** without a refresh.
fir
### Step 3: Real-Time Chat Coordination
- **Device 2**: Tap the "Home Cooked Meal" listing and select **Start Trade**.
- Both devices should now open the **Messages** tab.
- Send a message from Device 1—it will appear on Device 2 in less than a second. 

### Step 4: Reputation & Trust Score
- **Device 2**: Tap the trade status banner and mark the service as **Received**.
- **Device 2**: Leave a **5-star review** and write: "The meal was incredible, thank you!"
- **Device 1**: Go to your **Profile**. Watch as your **Trust Score** increases and the testimonial appears instantly.

---

## 🛠️ Troubleshooting (Hackathon Tips)
- **Firebase Sync**: If messages aren't appearing, ensure both devices have an active internet connection (WiFi or Data).
- **Mock Emails**: You don't need real emails! Use `test1@test.com`, `test2@test.com`, etc.
- **Simulator Sync**: If you only have one iPhone, run the second "neighbor" on the **Xcode Simulator** (iPhone 15 Pro). The sync works exactly the same!

**Good luck, Neighbors!**
