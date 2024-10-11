from flask import Flask, request, jsonify
import torch
import torch.nn.functional as F
from efficientnet_pytorch import EfficientNet  # EfficientNet 모델 사용
from PIL import Image
from torchvision import transforms
from transformers import AutoModelForImageClassification, AutoImageProcessor
import io

app = Flask(__name__)

# 첫 번째 모델 (EfficientNet 기반 사칭 광고 감지 모델) 로드
model_name = 'efficientnet-b0'
num_classes = 2  # 클래스 수 정의 (사칭 광고와 실제 광고)

own_model = EfficientNet.from_name(model_name)
own_model._fc = torch.nn.Linear(own_model._fc.in_features, num_classes)  # 마지막 레이어 수정

# EfficientNet 모델의 가중치 로드 (경로 수정 필요)
own_model.load_state_dict(torch.load(r"C:\Users\gusdn\OneDrive\바탕 화면\promotion_model.pt", map_location=torch.device('cpu')))
own_model.eval()  # 평가 모드로 전환

# 두 번째 모델 (딥페이크 감지 모델)과 프로세서 로드
hug_model = AutoModelForImageClassification.from_pretrained("dima806/deepfake_vs_real_image_detection")
hug_processor = AutoImageProcessor.from_pretrained("dima806/deepfake_vs_real_image_detection")

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    # 이미지 파일 확인
    try:
        image = Image.open(io.BytesIO(file.read()))
        print(f"Image size: {image.size}, Image mode: {image.mode}")  # 이미지 크기 및 모드 출력
    except Exception as e:
        return jsonify({'error': f'Invalid image file: {str(e)}'}), 400

    # 이미지 모드 확인 및 변환
    if image.mode != 'RGB':
        image = image.convert('RGB')

    # 첫 번째 모델 (EfficientNet 사칭 광고 모델)로 예측
    own_inputs = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])(image).unsqueeze(0)  # 배치 차원 추가

    with torch.no_grad():
        own_outputs = own_model(own_inputs)
    own_probabilities = F.softmax(own_outputs, dim=1)
    _, own_predicted_class = torch.max(own_probabilities, 1)

    # 두 번째 모델 (딥페이크 감지 모델)로 예측
    hug_inputs = hug_processor(images=image, return_tensors="pt")
    with torch.no_grad():
        hug_outputs = hug_model(**hug_inputs)
    hug_probabilities = F.softmax(hug_outputs.logits, dim=1)
    _, hug_predicted_class = torch.max(hug_probabilities, 1)

    # 모델 중 하나라도 '사칭'으로 예측하면 '사칭 광고'로 분류
    if own_predicted_class.item() == 0 or hug_predicted_class.item() == 1:
        final_prediction = '사칭 광고'
    else:
        final_prediction = '실제 광고'
    print(final_prediction)
    return jsonify({
        'final_prediction': final_prediction,
        'promotion_model_prediction': '사칭 광고' if own_predicted_class.item() == 0 else '실제 광고',
        'promotion_model_probabilities': own_probabilities.tolist(),
        'deepfake_model_prediction': '딥페이크 이미지' if hug_predicted_class.item() == 0 else '실제 이미지',
        'deepfake_model_probabilities': hug_probabilities.tolist()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
