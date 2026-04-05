from agents.agent_manager import AgentManager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from schemas import MessageInput
from database import log_detection, get_history

app = FastAPI()

# Initialize Agents
infiltrator = AgentManager("Infiltrator")
forensic = AgentManager("Forensic")
mentor = AgentManager("Mentor")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Kavach AI Backend Running"}

@app.get("/health")
def health():
    return {"status": "ok"}


# 🔍 DETECT (uses Forensic Agent)
@app.post("/detect")
def detect(data: MessageInput):
    if not data.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    result = forensic.send_message(f"Classify this message as SCAM or SAFE and explain briefly:\n{data.text}")

    # simple fallback classification (since agent returns text)
    classification = "SCAM" if "scam" in result.lower() else "SAFE"
    confidence = 0.9  # placeholder

    log_detection(data.text, classification, confidence)

    return {
        "classification": classification,
        "confidence": confidence,
        "reason": result
    }


# 🧠 EXPLAIN (Forensic Agent)
@app.post("/explain")
def explain(data: MessageInput):
    result = forensic.send_message(f"Explain why this is a scam or safe:\n{data.text}")
    return {"indicators": result}


# 🛡️ ACTION (Mentor Agent)
@app.post("/action")
def action(data: MessageInput):
    result = mentor.send_message(f"What should a user do for this message?\n{data.text}")
    return {"actions": result}


# 🎭 SIMULATION (Infiltrator Agent)
@app.get("/simulate")
def simulate():
    result = infiltrator.send_message("Generate a realistic scam message (like UPI or OTP fraud)")
    return {"message": result}


# 📜 HISTORY
@app.get("/history")
def history():
    return {"history": get_history()}