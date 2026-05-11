import torch
import torch.nn as nn

# Clases
emociones = ["angry", "fear", "happy", "sad", "surprise", "neutral"]

class EmotionModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(1, 32, 3),
            nn.ReLU(),
            nn.MaxPool2d(2),

            nn.Conv2d(32, 64, 3),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )

        self.fc = nn.Sequential(
            nn.Flatten(),
            nn.Linear(64 * 10 * 10, 128),
            nn.ReLU(),
            nn.Linear(128, len(emociones))
        )

    def forward(self, x):
        x = self.conv(x)
        x = self.fc(x)
        return x

# Crear modelo
model = EmotionModel()

# Guardar modelo vacío (estructura correcta)
torch.save(model.state_dict(), "model.pth")

print("✅ Modelo creado como model.pth")