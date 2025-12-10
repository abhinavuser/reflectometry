import RPi.GPIO as GPIO
import time
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import hilbert
from matplotlib.animation import FuncAnimation
from datetime import datetime

# ---------------------------
# GPIO setup
# ---------------------------
PIN = 18  # single TX/RX pin
GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN, GPIO.OUT)

# ---------------------------
# Parameters
# ---------------------------
PWM_FREQ = 10000       # 10 kHz
PWM_DUTY = 3           # small duty to simulate ~100 mV
SAMPLES = 500          # number of samples per measurement
DT = 1e-5              # 10 us sampling interval
Z0 = 400               # characteristic impedance (Ohm)
REFLECTION_THRESH = 80 # reflection % threshold for open circuit
PULSE_WIDTH_SAMPLES = 5

# ---------------------------
# Initialize plot arrays
# ---------------------------
tx_signal = np.zeros(SAMPLES)
rx_signal = np.zeros(SAMPLES)

# ---------------------------
# Set up live plot
# ---------------------------
fig, ax = plt.subplots()
line_tx, = ax.plot(tx_signal, label="TX Pulse")
line_rx, = ax.plot(rx_signal, label="RX Signal")
ax.set_ylim(-0.5, 1.5)
ax.set_xlabel("Sample #")
ax.set_ylabel("Amplitude")
ax.set_title("Single-Port TDR (Real-Time)")
ax.legend()
ax.grid(True)

# ---------------------------
# Functions
# ---------------------------
def send_and_capture():
    """Send short PWM pulse and read reflection on same pin"""
    # Transmit pulse
    GPIO.setup(PIN, GPIO.OUT)
    pwm = GPIO.PWM(PIN, PWM_FREQ)
    pwm.start(PWM_DUTY)
    time.sleep(DT*PULSE_WIDTH_SAMPLES)
    pwm.stop()

    # Switch to input to read reflection
    GPIO.setup(PIN, GPIO.IN)
    rx = []
    for _ in range(SAMPLES):
        rx.append(GPIO.input(PIN))
        time.sleep(DT)
    return np.array(rx)

def update(frame):
    rx = send_and_capture()

    # TX pulse visualization
    tx = np.zeros(SAMPLES)
    tx[0:PULSE_WIDTH_SAMPLES] = 1

    # Update plot
    line_tx.set_ydata(tx)
    line_rx.set_ydata(rx)

    # --- Reflection coefficient ---
    V_tx_peak = 1  # normalized TX peak
    V_rx_peak = np.max(np.abs(hilbert(rx)))
    reflection_percent = (V_rx_peak / V_tx_peak) * 100

    # --- Impedance calculation ---
    if reflection_percent >= 100:
        ZL = float('inf')  # open circuit
    else:
        gamma = V_rx_peak / V_tx_peak
        ZL = Z0 * (1 + gamma) / (1 - gamma) if gamma < 1 else float('inf')

    # --- Fence status prediction ---
    if reflection_percent >= REFLECTION_THRESH:
        status = "? Open circuit / Illegal tap detected!"
    else:
        status = "Fence OK"

    # --- Update title in real-time ---
    ax.set_title(f"Reflection: {reflection_percent:.1f}%, ZL={ZL:.1f} O - {status}")

    # Optional: print log to console
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Reflection: {reflection_percent:.1f}%, ZL={ZL:.1f} O - {status}")

    return line_tx, line_rx

# ---------------------------
# Run animation
# ---------------------------
ani = FuncAnimation(fig, update, interval=200, blit=True)
plt.show()

# Cleanup GPIO when done
GPIO.cleanup()