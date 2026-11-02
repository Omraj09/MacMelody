# Contributing to MacMelody

Thank you for your interest in contributing to **MacMelody**! 

Whether you are reporting bugs, improving documentation, submitting code, or testing new earbud models, your help is very welcome.

---

## 🛠️ Development Setup

Requirements:
- macOS 14.0+
- Xcode 15.0+ or Command Line Tools (`xcode-select --install`)
- Swift 6.0 toolchain

### 1. Clone & Build
```bash
git clone https://github.com/Omraj09/MacMelody.git
cd MacMelody

# Run the test suite
swift test

# Build and install locally to /Applications
./scripts/build-app.sh --install
```

### 2. Code Guidelines
- **Strict Concurrency**: MacMelody compiles with Swift 6 strict concurrency checks.
- **Privacy First**: MacMelody is 100% local. Do not add any analytics, network requests, or third-party trackers.
- **Hardware Verification**: Ensure UI states only show as confirmed when the hardware replies over the OPOv1 protocol.

---

## 🎧 Adding or Verifying New Earbud Models

If you own a model that is currently marked **Not Verified** or is unlisted:
1. Open MacMelody and navigate to **Diagnostics** in the sidebar.
2. Review the read-only packet logs (Bluetooth addresses are automatically redacted).
3. Open an issue using the [Device Support Request](https://github.com/Omraj09/MacMelody/issues/new?template=device_support.yml) template.

---

## 📄 License
By contributing to MacMelody, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
