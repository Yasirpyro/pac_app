# Payment Assurance Copilot (PAC) - Demo Script

**Target Duration:** 2-4 Minutes
**Setup:** App pre-loaded with synthetic data (5 bills, balance $2,800, payday Feb 19, today is Feb 12). `DEMO_MODE` enabled.

---

## Scenario 1: Normal Bill with AI Recommendation (90 seconds)

**00:00 - Intro**
"Hi, I'm [Name]. Meet Jordan, a busy professional who manages 10 bills a month. Jordan just opened Payment Assurance Copilot."

**00:10 - Home Screen**
"Jordan sees 1 bill needs attention: their electricity bill, $180, due in 5 days."
*Action: Point to 'Bills Needing Attention' card.*

**00:15 - Bill Detail**
"Jordan taps the bill. PAC's AI has analyzed Jordan's cashflow. It knows the current balance is $2,800 and the next payday is Feb 19. Crucially, it knows rent—$1,200—is due Feb 16."
*Action: Tap 'ComEd Electric' bill.*

**00:25 - AI Recommendation**
"PAC suggests: 'Schedule for Feb 19 (payday).' Why? Paying now would leave only $2,620, which is risky with rent coming. Waiting until payday keeps a healthy $1,420 buffer."
*Action: Highlight Recommendation Panel.*

**00:40 - User Selection**
"Jordan agrees and taps 'Schedule for Feb 19.' PAC shows the confirmation: payee, amount, date."
*Action: Tap 'Schedule for Feb 19' button.*

**00:50 - Authentication**
"Jordan authenticates with Touch ID."
*Action: Tap 'Authenticate' button (mock biometric).*

**00:55 - Success**
"Payment scheduled! Reference PAC-20260212-001. Jordan's stress is zero. Late fee risk is zero."
*Action: Show Success screen.*

**01:05 - Transparency**
"Every action is logged transparently: AI recommendation, user choice, timestamp."
*Action: Briefly show Audit Log in Settings.*

---

## Scenario 2: Anomaly Detection + Maintenance Mode (90 seconds)

**01:15 - Anomaly Detection**
"Now, a curveball. Jordan's internet bill just arrived: $145. Wait—that's 63% higher than usual ($89)."
*Action: Open 'Comcast Internet' bill (pre-configured with high amount).*

**01:25 - Warning**
"PAC detects this and warns: '⚠️ Unusual Amount: This bill is 63% higher than usual. Please verify.'"
*Action: Point to Warning Banner.*

**01:35 - Verification**
"Jordan checks—it's a one-time modem upgrade charge. Legit. They proceed."

**01:45 - Maintenance Mode**
"But now, imagine Jordan tries to pay during the bank's maintenance window."
*Action: Go to Settings -> Enable Maintenance Mode -> Return Home.*

**01:50 - Maintenance UI**
"PAC doesn't just say 'system down.' It shows: balance snapshot (as of 11 PM), queued payments, and estimated return time."
*Action: Show Maintenance Home banner and snapshot.*

**02:00 - Queue Payment**
"Jordan can queue the internet bill to process automatically at 6 AM when maintenance ends."
*Action: Tap 'Pay Now' on Internet bill -> Show Queue Modal -> Confirm.*

**02:10 - Emergency Options**
"Need immediate help? PAC provides 24/7 phone, ATM locator, branch hours. No dead ends."
*Action: Tap 'Emergency Options' tab.*

**02:20 - Conclusion**
"Payment Assurance Copilot: AI that recommends, users decide. Continuity when systems are down. Zero late fees, zero panic."

**02:30 - Call to Action**
"This is how banking should feel in 2026. Thank you!"
