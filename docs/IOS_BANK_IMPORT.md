# Importing Iranian bank SMS on iOS

iOS does **not** grant ordinary apps unrestricted access to received SMS.
A separate opt-in Apple Shortcuts personal automation for the Message trigger
can be configured by the iPhone owner after on-device testing.

A future import interface must:
- accept only a user-authorized transaction payload;
- verify bank sender patterns without trusting SMS alone;
- store only masked last four card digits, type, value and date;
- de-duplicate with an explicit fingerprint;
- never request OTPs, passwords, full card numbers or SMS forwarding to a server;
- request confirmation for ambiguous transactions.

No SMS ingestion, Shortcuts integration, or background automation is implemented in this prototype.
