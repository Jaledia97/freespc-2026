import os

directory = 'lib'
for root, _, files in os.walk(directory):
    for filename in files:
        if filename.endswith(".dart"):
            filepath = os.path.join(root, filename)
            with open(filepath, 'r') as f:
                content = f.read()
            
            if 'HapticFeedback.vibrate()' in content or 'Vibration.vibrate' in content:
                # Replace the calls
                content = content.replace('HapticFeedback.vibrate()', 'Vibration.vibrate(duration: 40)')
                content = content.replace('Vibration.vibrate(duration: 30)', 'Vibration.vibrate(duration: 40)')
                
                # Add import if not present
                if "import 'package:vibration/vibration.dart';" not in content:
                    # insert after last import
                    import_idx = content.rfind("import '")
                    if import_idx != -1:
                        newline_idx = content.find('\n', import_idx)
                        if newline_idx != -1:
                            content = content[:newline_idx+1] + "import 'package:vibration/vibration.dart';\n" + content[newline_idx+1:]
                
                with open(filepath, 'w') as f:
                    f.write(content)
                print(f"Updated {filepath}")
