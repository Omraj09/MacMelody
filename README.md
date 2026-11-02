<div align="center">

<img src="Packaging/AppIcon.iconset/icon_128x128@2x.png" width="108" height="108" alt="MacMelody Icon" style="border-radius: 24px; box-shadow: 0 8px 20px rgba(0,0,0,0.15);">

# MacMelody

**Native macOS menu bar companion for OnePlus, OPPO & realme earbuds.**

Control your earbuds directly from your Mac with fluid Apple Liquid Glass aesthetics.  
No phone apps, no accounts, no cloud—just direct Bluetooth.

<br/>

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-black?style=flat-square&logo=apple&logoColor=white)](https://apple.com/macos)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-FA7343?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Native-555555?style=flat-square)](https://apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-007AFF?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/github/v/release/Omraj09/MacMelody?color=34C759&style=flat-square)](https://github.com/Omraj09/MacMelody/releases/latest)

<br/>

<a href="https://github.com/Omraj09/MacMelody/releases/latest/download/MacMelody.dmg">
  <img src="https://img.shields.io/badge/Download-MacMelody.dmg-007AFF?style=for-the-badge&logo=apple&logoColor=white" height="40">
</a>

</div>

<br/>

---

## 🎛️ Menu Bar Control Panel

<table>
<tr>
<td width="56%" valign="middle">

Quick access from your menu bar with genuine macOS Liquid Glass vibrancy:

- **Apple Liquid Glass:** Borderless floating panel with continuous rounded corners and native translucency.
- **Spring Bloom Motion:** Smooth opening bloom directly from the menu bar icon.
- **Downward Expansion:** Selecting ANC depths expands the panel strictly downwards in smooth lockstep.
- **Noise Control:** Toggle between **Off**, **ANC**, and **Transparency** with depth selection (**Smart**, **Deep**, **Medium**, **Light**).
- **Game Mode:** One-click low-latency audio toggle.
- **Live Battery Rings:** Real-time percentage indicators for Left and Right earbuds.

</td>
<td width="44%" align="center" valign="middle">

<img src="Documentation/Screenshots/popover.png" width="310" alt="MacMelody Menu Bar Control Panel" style="border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.22);">

</td>
</tr>
</table>

---

## 🖥️ Main Device Dashboard

<table>
<tr>
<td width="48%" align="center" valign="middle">

<img src="Documentation/Screenshots/window-overview.png" width="480" alt="MacMelody Main Overview Window" style="border-radius: 12px; box-shadow: 0 10px 28px rgba(0,0,0,0.22);">

</td>
<td width="52%" valign="middle">

Detailed device management and configuration window:

- **Verified Hardware Info:** Live connection state, classic RFCOMM transport, and firmware version.
- **Advanced Features:** Manage In-ear detection, Equalizer profiles, and Touch Gestures.
- **Independent Lifecycle:** Closing the main window leaves the menu bar companion running seamlessly.
- **Local Diagnostics:** Read-only Bluetooth packet inspection with automatic identifier redaction.

</td>
</tr>
</table>

---

## 🎧 Supported Models

MacMelody communicates natively with OnePlus, OPPO, and realme TWS earbuds via the OPOv1 protocol over Bluetooth RFCOMM and BLE.

### OnePlus
| Model | Status | Tailored Features |
|---|:---:|---|
| **OnePlus Nord Buds 4 Pro** | 🟢 Verified | Battery, ANC Tree (Smart/Deep/Med/Light), EQ, Spatial Audio, BassWave, Gestures |
| **OnePlus Buds 3** | 🟢 Verified | Battery, ANC Tree (Smart/Deep/Med/Light), EQ Presets, Game Mode, In-Ear Detection |
| **OnePlus Buds Pro 3** | 🟡 Not Verified | Battery, Dynaudio EQ, 50dB Adaptive ANC, Spatial Audio, Dual Connection, Stem Gestures |
| **OnePlus Buds Pro 2 / 2R** | 🟡 Not Verified | Battery, Dynaudio EQ, ANC Tree, Spatial Audio, Dual Connection, Gestures |
| **OnePlus Buds 4** | 🟡 Not Verified | Battery, ANC Tree, Master EQ, Dual Connection, In-Ear Detection, Gestures |
| **OnePlus Nord Buds 4** | 🟡 Not Verified | Battery, 48dB ANC Tree, BassWave, Dual Connection, In-Ear Detection, Gestures |
| **OnePlus Nord Buds 3 Pro** | 🟡 Not Verified | Battery, 49dB ANC Tree, BassWave, Dual Connection, In-Ear Detection, Gestures |
| **OnePlus Nord Buds 3** | 🟡 Not Verified | Battery, 32dB ANC Tree, BassWave, Dual Connection, In-Ear Detection, Gestures |
| **OnePlus Nord Buds 3r** | 🟡 Not Verified | Battery, Master EQ, BassWave, Dual Connection, Gestures *(Non-ANC)* |
| **OnePlus Nord Buds 2** | 🟡 Not Verified | Battery, Core ANC, BassWave, In-Ear Detection, Master EQ, Gestures |
| **OnePlus Nord Buds 2r** | 🟡 Not Verified | Battery, Master EQ, BassWave, Game Mode, Gestures *(Non-ANC)* |
| **OnePlus Nord Buds** | 🟡 Not Verified | Battery, Sound Master EQ, Ultra-Low Latency, Gestures *(Non-ANC)* |
| **OnePlus Buds Z2** | 🟡 Not Verified | Battery, Core ANC, In-Ear Detection, Master EQ, Gestures |
| **OnePlus Buds Pro** | 🟡 Not Verified | Battery, ANC Tree, In-Ear Detection, Master EQ, Gestures |

### OPPO
| Model | Status | Tailored Features |
|---|:---:|---|
| **OPPO Enco X4** | 🟡 Not Verified | Battery, Dynaudio EQ, 55dB ANC Tree, Spatial Audio, Dual Connection, Stem Gestures |
| **OPPO Enco X2** | 🟡 Not Verified | Battery, Dynaudio EQ, ANC Tree, Spatial Audio, Dual Connection, Gestures |
| **OPPO Enco Air5 Pro** | 🟡 Not Verified | Battery, 55dB ANC Tree, Spatial Audio, Dual Connection, In-Ear Detection, Gestures |
| **OPPO Enco Air5** | 🟡 Not Verified | Battery, Master EQ, Dual Connection, Gestures *(Semi-in-ear / Non-ANC)* |
| **OPPO Enco Air4 Pro** | 🟡 Not Verified | Battery, 49dB ANC Tree, Master EQ, Dual Connection, In-Ear Detection, Gestures |
| **OPPO Enco Air3 Pro** | 🟡 Not Verified | Battery, Bamboo Driver ANC Tree, Alive Audio (Spatial), Dual Connection, Gestures |
| **OPPO Enco Air3** | 🟡 Not Verified | Battery, Master EQ, Dual Connection, Gestures *(Semi-in-ear / Non-ANC)* |
| **OPPO Enco Air2 Pro** | 🟡 Not Verified | Battery, 28dB Core ANC, In-Ear Detection, Master EQ, Gestures |
| **OPPO Enco Buds3 Pro+** | 🟡 Not Verified | Battery, 32dB Hybrid ANC, Dual Connection, Master EQ, Gestures |
| **OPPO Enco Buds3 Pro** | 🟡 Not Verified | Battery, 32dB Hybrid ANC, Dual Connection, Master EQ, Gestures |
| **OPPO Enco Buds3** | 🟡 Not Verified | Battery, Master EQ, Low Latency, Gestures *(Non-ANC)* |
| **OPPO Enco Buds 2** | 🟡 Not Verified | Battery, Enco Live Stereo EQ, Low Latency, Gestures *(Non-ANC)* |
| **OPPO Enco Free3** | 🟡 Not Verified | Battery, Bamboo Diaphragm ANC Tree, In-Ear Detection, Gestures |
| **OPPO Enco X** | 🟡 Not Verified | Battery, Dynaudio EQ, ANC Tree, In-Ear Detection, Gestures |

### Realme
| Model | Status | Tailored Features |
|---|:---:|---|
| **Realme Buds Air 8 Pro** | 🟡 Not Verified | Battery, 55dB ANC Tree, 360° Spatial Audio, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds Air 8** | 🟡 Not Verified | Battery, 55dB ANC Tree, Dynamic Bass EQ, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds Air 7 Pro** | 🟡 Not Verified | Battery, 53dB ANC Tree, Spatial Audio, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds Air 7** | 🟡 Not Verified | Battery, 52dB ANC Tree, Dynamic Bass EQ, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds Air 6 Pro** | 🟡 Not Verified | Battery, 50dB ANC Tree, 360° Spatial Audio, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds Air 6** | 🟡 Not Verified | Battery, 50dB ANC Tree, Dynamic Bass EQ, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds Air 5 Pro** | 🟡 Not Verified | Battery, 50dB ANC Tree, Spatial Audio, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds Air 5** | 🟡 Not Verified | Battery, Multi-level ANC, Dynamic Bass EQ, Dual Connection, In-Ear Detection, Gestures |
| **Realme Buds T310** | 🟡 Not Verified | Battery, 46dB Hybrid ANC, 360° Spatial Effect, Dual Connection, Gestures |
| **Realme Buds T300** | 🟡 Not Verified | Battery, 30dB Core ANC, 360° Spatial Effect, Dual Connection, Gestures |
| **Realme Buds T200** | 🟡 Not Verified | Battery, 32dB Core ANC, Dynamic Bass EQ, Low Latency, Gestures |
| **Realme Buds T200x** | 🟡 Not Verified | Battery, 25dB Core ANC, Dynamic Bass EQ, Low Latency, Gestures |
| **Realme Buds T200 Lite** | 🟡 Not Verified | Battery, AI ENC, Dual-Device Pairing, Dynamic Bass EQ, Gestures *(Non-ANC)* |
| **Realme Buds T110** | 🟡 Not Verified | Battery, AI ENC, Dynamic Bass EQ, Low Latency, Gestures *(Non-ANC)* |
| **Realme Buds N1** | 🟡 Not Verified | Battery, 46dB Hybrid ANC, 360° Spatial Audio, Dual Connection, Gestures |

---

## 📥 Quick Install

1. Download **[MacMelody.dmg](https://github.com/Omraj09/MacMelody/releases/latest/download/MacMelody.dmg)**.
2. Drag **MacMelody** into your **Applications** folder.
3. Open the app and allow Bluetooth access when prompted.
4. Connect your earbuds to your Mac via Bluetooth—MacMelody pairs automatically.

<details>
<summary><b>Building from source</b></summary>

<br/>

Requirements: macOS 14.0+, Command Line Tools (`xcode-select --install`), and Swift 6.

```bash
git clone https://github.com/Omraj09/MacMelody.git
cd MacMelody

# Build and install to /Applications
./scripts/build-app.sh --install

# Package DMG installer
./scripts/build-dmg.sh
```

</details>

---

## ⌨️ Shortcuts

| Key | Function |
|:---:|---|
| <kbd>⌘</kbd> + <kbd>1</kbd> | Noise Control: **Off** |
| <kbd>⌘</kbd> + <kbd>2</kbd> | Noise Control: **Active Noise Cancellation** |
| <kbd>⌘</kbd> + <kbd>3</kbd> | Noise Control: **Transparency** |
| <kbd>⌘</kbd> + <kbd>,</kbd> | Settings & Diagnostics |
| <kbd>⌘</kbd> + <kbd>Q</kbd> | Quit MacMelody |

---

## 🔒 Privacy

- **100% Local:** No analytics, no network requests, and zero telemetry.
- **Hardware-Verified:** Settings only display as changed once confirmed by your physical earbuds.

---

## 📄 License

Created by **[Omraj Sawant](https://github.com/Omraj09)** under the [MIT License](LICENSE).

<div align="center">

<sub>MacMelody is an independent open-source utility and is not affiliated with OnePlus, OPPO, realme, or Apple Inc.</sub>

</div>
