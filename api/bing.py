PS F:\ML project\api> python api.py
 * Serving Flask app 'api'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://192.168.141.91:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 755-452-320
python: can't open file 'F:\\ML': [Errno 2] No such file or directory
127.0.0.1 - - [12/Jun/2024 08:07:06] "POST /upload HTTP/1.1" 500 -
Traceback (most recent call last):
  File "C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\site-packages\flask\app.py", line 1498, in __call__   
    return self.wsgi_app(environ, start_response)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\site-packages\flask\app.py", line 1476, in wsgi_app   
    response = self.handle_exception(e)
               ^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\site-packages\flask\app.py", line 1473, in wsgi_app   
    response = self.full_dispatch_request()
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\site-packages\flask\app.py", line 882, in full_dispatch_request
    rv = self.handle_user_exception(e)
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\site-packages\flask\app.py", line 880, in full_dispatch_request
    rv = self.dispatch_request()
         ^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\site-packages\flask\app.py", line 865, in dispatch_request
    return self.ensure_sync(self.view_functions[rule.endpoint])(**view_args)  # type: ignore[no-any-return]
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "F:\ML project\api\api.py", line 27, in upload_file  
    subprocess.run(yolo_command, shell=True, check=True)    
  File "C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\subprocess.py", line 571, in run
    raise CalledProcessError(retcode, process.args,
subprocess.CalledProcessError: Command 'python F:/ML project/model/blood profile/yolov7/detect.py --weights F:/ML project/model/blood profile/runs/train/run/weights/best.pt --save-txt --conf 0.5 --img-size 640 --name ./output/ --source image.png' returned non-zero exit status 2.












from flask import Flask, request, jsonify, send_file
from PIL import Image
import io
import os
import subprocess
import base64

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    # Save the image file
    image_path = 'image.png'
    file.save(image_path)

    # Run YOLOv7 detection
    #F:\ML project\model\Blood-Cell-Counter-YoLo-v7-main\runs\train\run\weights\best.pt
    #F:\ML project\model\Blood-Cell-Counter-YoLo-v7-main\yolov7\detect.py
    yolo_command = f"python F:/ML project/model/blood profile/yolov7/detect.py --weights F:/ML project/model/blood profile/runs/train/run/weights/best.pt --save-txt --conf 0.5 --img-size 640 --name ./output/ --source {image_path}"
    subprocess.run(yolo_command, shell=True, check=True)

    # Process output
    output_folder = "./output/"
    jpg_files = [f for f in os.listdir(output_folder) if f.endswith(".jpg")]
    if not jpg_files:
        return jsonify({'error': 'No JPG file found in the folder.'}), 400

    jpg_file_path = os.path.join(output_folder, jpg_files[0])
    with open(jpg_file_path, "rb") as image_file:
        processed_image_base64 = base64.b64encode(image_file.read()).decode('utf-8')

    txt_folder_path = os.path.join(output_folder, "labels")
    txt_files = [f for f in os.listdir(txt_folder_path) if f.endswith(".txt")]
    if not txt_files:
        return jsonify({'error': 'No TXT file found in the labels folder.'}), 400

    txt_file_path = os.path.join(txt_folder_path, txt_files[0])
    with open(txt_file_path, "r") as txt_file:
        lines = txt_file.readlines()
        wbc_count = 0
        rbc_count = 0
        platelets_count = 0
        for line in lines:
            items = line.strip().split(' ')
            class_val = int(items[0])
            if class_val == 2:
                wbc_count += 1
            elif class_val == 1:
                rbc_count += 1
            elif class_val == 0:
                platelets_count += 1

    response_data = {
        'processed_image': processed_image_base64,
        'wbc_count': wbc_count,
        'rbc_count': rbc_count,
        'platelets_count': platelets_count
    }

    return jsonify(response_data)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
