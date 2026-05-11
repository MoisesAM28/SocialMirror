import torch
import torch.nn as nn
from torchvision import transforms, models
from PIL import Image

emociones = ["happy", "neutral", "sad"]

# 🔥 Modelo PRO
model = models.resnet18(weights=None)
model.fc = nn.Linear(model.fc.in_features, len(emociones))

# Cargar modelo entrenado
model.load_state_dict(torch.load("model_resnet.pth", map_location="cpu"))
model.eval()

# Transformaciones
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor()
])

def generar_feedback(emocion, confianza):
    if confianza < 0.4:
        return "No estoy muy seguro 🤔 intenta una expresión más clara."

    if emocion == "happy":
        return f"Bien 😊 (confianza {confianza:.2f}), te ves feliz."
    elif emocion == "sad":
        return f"Parece que estás triste 😢 (confianza {confianza:.2f})."
    elif emocion == "neutral":
        return f"Estás neutral 😐 (confianza {confianza:.2f})."
    else:
        return "No se detectó claramente."

def predecir_emocion(imagen_path):
    try:
        img = Image.open(imagen_path).convert("RGB")
        img = transform(img)
        img = img.unsqueeze(0)

        with torch.no_grad():
            output = model(img)

            prob = torch.softmax(output, dim=1)
            confianza, pred = torch.max(prob, 1)

        emocion = emociones[pred.item()]
        confianza_valor = confianza.item()

        print("EMOCION:", emocion)
        print("CONFIANZA:", confianza_valor)

        feedback = generar_feedback(emocion, confianza_valor)

        return emocion, feedback

    except Exception as e:
        print("ERROR:", e)
        return "neutral", "Error al procesar imagen"