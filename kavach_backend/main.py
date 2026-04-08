import os
import traceback
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from agents.agent_manager import AgentManager
from schemas import MessageInput
from database import log_detection, get_history

app = FastAPI(
    title="Kavach AI – Cyber Safety Simulator",
    description="Backend API for the Kavach AI Cyber-Safety Ecosystem",
    version="1.0.0",
)

# ──────────────────────────────────────────────
# CORS – allow frontend requests from any origin
# ──────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ──────────────────────────────────────────────
# Initialize AI Agents
# ──────────────────────────────────────────────
infiltrator = AgentManager("Infiltrator")
forensic = AgentManager("Forensic")
mentor = AgentManager("Mentor")


# ──────────────────────────────────────────────
# Helper – standardised API envelope
# ──────────────────────────────────────────────
def api_response(success: bool, data: dict, message: str = ""):
    return {"success": success, "data": data, "message": message}


# ──────────────────────────────────────────────
# Routes
# ──────────────────────────────────────────────


@app.get("/health")
def health():
    return api_response(True, {"status": "ok"}, "Server healthy")


# 🔍 DETECT – Forensic Agent classifies a message
@app.post("/detect")
def detect(data: MessageInput):
    if not data.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    try:
        prompt = (
            "Classify the following message as SCAM or SAFE.\n"
            "Reply STRICTLY in this format (no extra text):\n"
            "CLASSIFICATION: SCAM or SAFE\n"
            "CONFIDENCE: a number between 0 and 100\n"
            "REASON: a short explanation\n\n"
            f"Message:\n{data.text}"
        )
        result = forensic.send_message(prompt)

        # Parse agent response
        classification = "SCAM" if "scam" in result.lower() else "SAFE"

        # Try to extract confidence from response
        confidence = 0.85  # default
        for line in result.split("\n"):
            line_lower = line.lower().strip()
            if "confidence" in line_lower:
                import re
                nums = re.findall(r"(\d+)", line)
                if nums:
                    confidence = min(int(nums[0]), 100) / 100.0
                break

        log_detection(data.text, classification, confidence)

        return api_response(True, {
            "classification": classification,
            "confidence": confidence,
            "reason": result,
        })

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Detection failed: {str(e)}")


# 🧠 EXPLAIN – Forensic Agent explains indicators
@app.post("/explain")
def explain(data: MessageInput):
    if not data.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    try:
        result = forensic.send_message(
            f"Explain in detail why the following message is a scam or safe. "
            f"Highlight every red flag and psychological trick used:\n{data.text}"
        )
        return api_response(True, {"indicators": result})

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Explain failed: {str(e)}")


# 🛡️ ACTION – Mentor Agent recommends steps
@app.post("/action")
def action(data: MessageInput):
    if not data.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    try:
        result = mentor.send_message(
            f"What should the user do about this message? Provide a numbered "
            f"list of recommended actions:\n{data.text}"
        )
        return api_response(True, {"actions": result})

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Action failed: {str(e)}")


# 🎭 SIMULATE – Infiltrator Agent generates a scam message
@app.post("/simulate")
def simulate():
    try:
        result = infiltrator.send_message(
            "Generate a realistic Indian scam message such as a UPI fraud, "
            "OTP phishing, digital arrest, or fake lottery. Make it convincing "
            "but use only placeholder links like safesim.link/example."
        )
        return api_response(True, {"message": result})

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Simulation failed: {str(e)}")


# 📜 HISTORY – past detections
@app.get("/history")
def history():
    try:
        rows = get_history()
        entries = [
            {
                "id": r[0],
                "message": r[1],
                "classification": r[2],
                "confidence": r[3],
                "timestamp": r[4],
            }
            for r in rows
        ]
        return api_response(True, {"history": entries})

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"History failed: {str(e)}")


# ──────────────────────────────────────────────
# Serve built frontend in production (Cloud Run)
# ──────────────────────────────────────────────
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.isdir(static_dir):
    app.mount("/", StaticFiles(directory=static_dir, html=True), name="static")


# ──────────────────────────────────────────────
# Run with:  uvicorn main:app --host 0.0.0.0 --port 8000
# Or:        python main.py
# ──────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)