# Golpool Finance — Release acceptance and device QA

Status: Android CI builds are automated. Device validation and iOS distribution are **not** yet verified.

## Android physical-device acceptance
- [ ] Install signed release APK from GitHub Actions with no existing installation
- [ ] Create two accounts with opening balances and register income, expense and account transfer
- [ ] Edit/delete transactions and verify balances, monthly totals and category charts
- [ ] Split purchase across categories and verify category budgets
- [ ] Create a savings goal, deposit, withdraw, and verify goal history
- [ ] Lend and borrow; settle debt partially and fully; inspect remaining amount
- [ ] Attach image receipt; reboot app; verify receipt survives
- [ ] Opt in to reminders; verify delivery at approximately 21:00 and 22:30 with pending expense
- [ ] Verify due-date reminders for recurring expenses and cancel behavior
- [ ] Enable device lock; reboot and verify OS authentication unlock/failure
- [ ] Export password-encrypted backup; restore on same device after test transaction; compare balances
- [ ] Attempt corrupted backup and wrong password; existing records must remain unchanged
- [ ] Install next signed APK on top without uninstalling; verify records and receipts survive
- [ ] Check all five navigation tabs, small-screen layout, system font scale, accessibility and dark/light settings

## iOS physical-device acceptance
- [ ] Obtain Apple Developer signing team, provisioning profile and permitted distribution path
- [ ] Check Info.plist permission reasons (Face ID, photo picker, notifications)
- [ ] Build signed iOS archive and distribute through TestFlight or an authorized ad-hoc path
- [ ] Install on iPhone 13; test storage, local notifications, biometrics and restore
- [ ] Validate background/restart behavior and migration
- [ ] Verify screenshots and layout on target device

## Release gate
A successful GitHub Actions build is evidence of compilation/tests/signature, NOT of device behavior, App Store readiness, comprehensive security, or commercial release.
Never add signing keys, user financial data or password-protected backup contents to source control.
