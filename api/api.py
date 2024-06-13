from flask import Flask, request, jsonify
from PIL import Image
import io
import subprocess
import base64
import shutil
import os

app = Flask(__name__)


def delete_folder(folder_path):
    if os.path.exists(folder_path):
        shutil.rmtree(folder_path)
        print(f"Folder '{folder_path}' and its contents have been deleted.")
    else:
        print(f"Folder '{folder_path}' does not exist.")

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

    output_folder = "./runs/detect/output/"
    
    # Run YOLOv7 detection
    yolo_command = [
        'python', 'F:/ML project/model/blood profile/yolov7/detect.py',
        '--weights', 'F:/ML project/model/blood profile/runs/train/run/weights/best.pt',
        '--save-txt', '--conf', '0.5', '--img-size', '640', '--name', './output/', '--source', image_path
    ]
    try:
        subprocess.run(yolo_command, check=True)
    except subprocess.CalledProcessError as e:
        delete_folder(output_folder)
        return jsonify({'error': 'YOLOv7 detection failed', 'details': str(e)}), 500

    # Process output
    jpg_files = [f for f in os.listdir(output_folder) if f.endswith(".png")]
    if not jpg_files:
        delete_folder(output_folder)
        return jsonify({'error': 'No JPG file found in the folder.'}), 400

    jpg_file_path = os.path.join(output_folder, jpg_files[0])
    with open(jpg_file_path, "rb") as image_file:
        processed_image_base64 = base64.b64encode(image_file.read()).decode('utf-8')

    txt_folder_path = os.path.join(output_folder, "labels")
    txt_files = [f for f in os.listdir(txt_folder_path) if f.endswith(".txt")]
    if not txt_files:
        delete_folder(output_folder)
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

    delete_folder(output_folder)
    return jsonify(response_data)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
