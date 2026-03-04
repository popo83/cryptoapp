#!/usr/bin/env python3
"""
Check for TestFlight approval email - optimized version
"""

import subprocess
from datetime import datetime

def check_emails():
    """Check for recent TestFlight emails"""
    
    # Only check last 50 messages for speed
    script = '''tell application "Mail"
        set msgList to {}
        set msgCount to 0
        repeat with msg in (messages of inbox)
            set msgCount to msgCount + 1
            if msgCount > 50 then exit repeat
            set msgSender to sender of msg as string
            if msgSender contains "apple.com" or msgSender contains "App Store" then
                set msgSubject to subject of msg as string
                if msgSubject contains "TestFlight" or msgSubject contains "iOSCryptoApp" then
                    set end of msgList to msgSubject
                end if
            end if
        end repeat
        return msgList
    end tell'''
    
    try:
        result = subprocess.run(
            ["osascript", "-e", script],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        emails = result.stdout.strip()
        
        if emails and emails != "{}":
            print(f"📧 Email Apple TestFlight:")
            for email in emails.split(","):
                print(f"  - {email.strip()}")
            
            keywords = ["approved", "ready for testflight", "available in testflight", "released to testers", "ready for sale"]
            for keyword in keywords:
                if keyword.lower() in emails.lower():
                    print(f"\n🎉 TROVATA! Email di approvazione!")
                    return True
        else:
            print(f"⏰ [{datetime.now().strftime('%H:%M')}] Nessuna email TestFlight recente...")
                
    except subprocess.TimeoutExpired:
        print(f"⚠️ Timeout controllo email")
    except Exception as e:
        print(f"❌ Errore: {e}")
    
    return False

if __name__ == "__main__":
    print("🔍 Check email TestFlight...")
    check_emails()
