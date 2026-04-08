# 🛡️ Learning War-Room

An interactive cybercrime survival simulator that trains users to recognize, analyze, and defend against modern digital threats. Instead of static safety tips, the War-Room builds real-time reflexes by simulating attacker tactics in a safe environment.

---

## 🚨 Problem

- ⚔️ **Tactical Ignorance**: People know the *name* of a scam (e.g., UPI Scam) but not the *trick* (e.g., “Request” vs. “Pay”).
- 🎭 **AI-Enhanced Fraud**: Deepfakes and AI voice cloning are emerging as 2026’s biggest threats, but current education hasn’t caught up.
- 📜 **Static Advice**: Reading lists of “Safety Tips” doesn’t build the reflex to spot scams in real-time.

---

## 💡 Solution: Multi-Agent Flow

The War-Room uses three specialized agents to simulate, dissect, and defend against attacks:

1. 🕵️ **The Infiltrator Agent**  
   - Acts as a simulated scammer.  
   - Sends fake SMS, phishing emails, or AI-generated voice calls.  
   - Demonstrates psychological pressure tactics (e.g., “Urgent Electricity Bill” or “Police Notice”).

2. 🔍 **The Forensic Agent**  
   - Breaks down the attack step-by-step.  
   - Highlights fake URLs, suspicious permissions, or deepfake voice patterns.  
   - Explains attacker psychology and technical red flags.

3. 🛡️ **The Defense Mentor**  
   - Guides users through safe responses.  
   - Reinforces best practices (e.g., reporting scams via the 1930 helpline).  
   - Helps configure device settings for maximum protection.

---

## 🔑 Key Features

- 🧪 **Crime Lab**  
  Interactive modules covering UPI Scams, Deepfake Fraud, and Social Engineering.

- 📅 **MCP Security Sync**  
  Automatically schedules “Security Health Checks” and password rotations in the user’s real calendar.

- 🕵️‍♂️ **Vulnerability Critic**  
  Scans the user’s phone/laptop for risky apps, weak permissions, or outdated software.

---

## 🎯 Goals

- 🏃 Build **reflexes**, not just awareness.  
- 👀 Teach users to **spot scams in real-time**.  
- 🤖 Prepare individuals and organizations for **AI-driven fraud tactics**.  
- 🧑‍🏫 Provide **hands-on defense training** in a safe, controlled environment.

---
## 🚀 Quick Start (Integrated Setup)

Both frontend and backend now run on the same port (8000) for simplified deployment.

### Prerequisites
- Python 3.11+
- Node.js 18+
- Google Gemini API Key

### Setup & Run
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Cyber_Safety_Simulator-main
   ```

2. **Configure API Key**
   - Edit `kavach_backend/.env`
   - Add: `GEMINI_API_KEY=your_actual_api_key_here`
   - Get key from: https://aistudio.google.com/apikey

3. **Run Integrated Application**
   ```bash
   # Windows
   run_integrated.bat

   # Or manually:
   cd kavach_frontend && npm install && npm run build
   cd ../kavach_backend
   xcopy ..\kavach_frontend\dist static /E /I /Y
   python main.py
   ```

4. **Access the Application**
   - Open browser: http://localhost:8000
   - Both frontend and API will be available on the same port

### API Endpoints
- `GET /health` - Server health check
- `POST /detect` - Analyze message for scams
- `POST /explain` - Get detailed scam explanation
- `POST /action` - Get recommended actions
- `POST /simulate` - Generate scam simulation
- `GET /history` - View detection history