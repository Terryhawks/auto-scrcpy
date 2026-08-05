# Auto-scrcpy
Personal Scripts I use to connect to my Phone and Tablet.
Who knows, maybe it'll be useful to others.

# Problem and Solution
- Dynamic Port version
My solution to Wireless Debugging's randomized Port.
According to Google, mDNS is a lot faster than Nmap, so, I made it attempt to detect via mDNS first, before port-scanning with Nmap.
- Fixed Port version
Not much, just an automation script to launch scrcpy easily.

# Use Requirements
Requires scrcpy (4.1) and Nmap (Dynamic Port).

# How to use
At the top of the Batch Files, set your device's IP. 
Afterwards, just run the Script.
- Suggestions:
Set your target device's IP to a fixed address. Example: 192.168.1.253
This would make it easier, as you don't need to change the address every time you run the script.

# Credits
Implemented with Gemini (what do you call the Google Search AI Mode?).