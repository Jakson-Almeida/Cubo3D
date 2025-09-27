import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

PeasyCam cam;
RubiksCube cube;
long lastMoveTime = 0;
int moveInterval = 500; // 0.5 segundos
boolean isFloating = true;
float floatOffset = 0;
float rotationSpeed = 0.03;

void settings() {
  fullScreen(P3D);
  smooth(8);
}

void setup() {
  cam = new PeasyCam(this, 400);
  cam.setMinimumDistance(200);
  cam.setMaximumDistance(600);
  cube = new RubiksCube();
  lastMoveTime = millis();
}

void draw() {
  // Fundo gradiente
  background(20, 30, 50);
  lights();
  directionalLight(255, 255, 255, 0.5, -1, -0.5);
  ambientLight(50, 50, 50);
  pointLight(200, 200, 200, 0, 0, 0);
  
  // Efeito flutuante
  floatOffset += rotationSpeed;
  float floatHeight = isFloating ? sin(floatOffset) * 10 : 0;
  translate(0, floatHeight, 0);
  
  // Atualiza e desenha o cubo
  cube.update();
  cube.display();
  
  // Movimento aleatório periódico
  if (millis() - lastMoveTime > moveInterval && !cube.isRotating()) {
    cube.randomMove();
    lastMoveTime = millis();
  }
  
  // Desenha informações na tela
  drawHUD();
}

void drawHUD() {
  cam.beginHUD();
  fill(255, 220);
  textSize(28);
  textAlign(CENTER, TOP);
  text("CUBO MÁGICO 3D", width/2, 20);
  
  textSize(16);
  textAlign(LEFT, TOP);
  text("Controles:", 20, 60);
  text("R: Resetar cubo", 20, 90);
  text("F: Alternar flutuação", 20, 120);
  text("Espaço: Movimento aleatório", 20, 150);
  text("Setas: Rotacionar visualização", 20, 180);
  
  textAlign(RIGHT, TOP);
  text("Movimentos:", width-20, 60);
  text("U: Face Superior", width-20, 90);
  text("D: Face Inferior", width-20, 120);
  text("L: Face Esquerda", width-20, 150);
  text("R: Face Direita", width-20, 180);
  text("F: Face Frontal", width-20, 210);
  text("B: Face Traseira", width-20, 240);
  
  // Contador de movimentos
  fill(255, 180);
  textSize(18);
  textAlign(CENTER, BOTTOM);
  text("Movimentos: " + cube.moveCount, width/2, height-30);
  
  // Status de rotação
  if (cube.isRotating()) {
    fill(100, 255, 150, 200);
    text("Rotacionando...", width/2, height-60);
  }
  
  cam.endHUD();
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    cube.reset();
  } else if (key == 'f' || key == 'F') {
    isFloating = !isFloating;
  } else if (key == ' ') {
    cube.randomMove();
    lastMoveTime = millis();
  } else if (key == CODED) {
    if (keyCode == UP) cam.pan(0, -10);
    if (keyCode == DOWN) cam.pan(0, 10);
    if (keyCode == LEFT) cam.pan(10, 0);
    if (keyCode == RIGHT) cam.pan(-10, 0);
  } else {
    // Movimentos do cubo
    String moves = "UDLRFB";
    int idx = moves.indexOf(key);
    if (idx >= 0) {
      cube.addMove(String.valueOf(moves.charAt(idx)), true);
    }
  }
}

class RubiksCube {
  Cubie[][][] cubies;
  float size = 50;
  float gap = 2;
  ArrayList<Move> moves;
  Move currentMove;
  int moveCount = 0;
  
  RubiksCube() {
    cubies = new Cubie[3][3][3];
    moves = new ArrayList<Move>();
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          float x = (i - 1) * (size + gap);
          float y = (j - 1) * (size + gap);
          float z = (k - 1) * (size + gap);
          cubies[i][j][k] = new Cubie(x, y, z, size);
        }
      }
    }
  }
  
  void display() {
    pushMatrix();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          cubies[i][j][k].display();
        }
      }
    }
    popMatrix();
  }
  
  void update() {
    if (currentMove != null) {
      currentMove.update();
      applyMove(currentMove);
      if (currentMove.finished()) {
        // When rotation is complete, swap the pieces to their final positions
        finalizeMove(currentMove);
        currentMove = null;
      }
    } else if (!moves.isEmpty()) {
      currentMove = moves.remove(0);
      currentMove.start();
      moveCount++;
    }
  }
  
  boolean isRotating() {
    return currentMove != null;
  }
  
  void applyMove(Move move) {
    // Aplica rotação visual à face inteira (sem modificar posições)
    switch(move.face) {
      case "U": // Face Superior (Y máximo)
        setFaceVisualRotation(1, 0, 0, move.angle); // Rotate around Y axis
        break;
      case "D": // Face Inferior (Y mínimo)
        setFaceVisualRotation(-1, 0, 0, move.angle); // Rotate around Y axis
        break;
      case "L": // Face Esquerda (X mínimo)
        setFaceVisualRotation(0, -1, 0, move.angle); // Rotate around X axis
        break;
      case "R": // Face Direita (X máximo)
        setFaceVisualRotation(0, 1, 0, move.angle); // Rotate around X axis
        break;
      case "F": // Face Frontal (Z máximo)
        setFaceVisualRotation(0, 0, 1, move.angle); // Rotate around Z axis
        break;
      case "B": // Face Traseira (Z mínimo)
        setFaceVisualRotation(0, 0, -1, move.angle); // Rotate around Z axis
        break;
    }
  }
  
  void setFaceVisualRotation(int faceX, int faceY, int faceZ, float angle) {
    // Encontra o centro da face
    float centerX = faceX * (size + gap);
    float centerY = faceY * (size + gap);
    float centerZ = faceZ * (size + gap);
    PVector faceCenter = new PVector(centerX, centerY, centerZ);
    
    // Aplica rotação visual a todos os cubies da face (sem modificar posições)
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          // Verifica se este cubie está na face que está sendo rotacionada
          if (isInFace(i, j, k, faceX, faceY, faceZ)) {
            Cubie cubie = cubies[i][j][k];
            
            // Set visual rotation based on face axis
            if (faceX != 0) {
              cubie.setVisualRotation(angle, 0, 0, faceCenter);
            } else if (faceY != 0) {
              cubie.setVisualRotation(0, angle, 0, faceCenter);
            } else if (faceZ != 0) {
              cubie.setVisualRotation(0, 0, angle, faceCenter);
            }
          }
        }
      }
    }
  }
  
  boolean isInFace(int i, int j, int k, int faceX, int faceY, int faceZ) {
    if (faceX != 0) return i == (faceX > 0 ? 2 : 0);
    if (faceY != 0) return j == (faceY > 0 ? 2 : 0);
    if (faceZ != 0) return k == (faceZ > 0 ? 2 : 0);
    return false;
  }
  
  
  void finalizeMove(Move move) {
    // When rotation is complete, swap pieces in the 3x3x3 matrix
    // and reset visual rotations
    switch(move.face) {
      case "U": // Face Superior
        swapFacePiecesInMatrix(1, 0, 0, move.clockwise);
        break;
      case "D": // Face Inferior
        swapFacePiecesInMatrix(-1, 0, 0, move.clockwise);
        break;
      case "L": // Face Esquerda
        swapFacePiecesInMatrix(0, -1, 0, move.clockwise);
        break;
      case "R": // Face Direita
        swapFacePiecesInMatrix(0, 1, 0, move.clockwise);
        break;
      case "F": // Face Frontal
        swapFacePiecesInMatrix(0, 0, 1, move.clockwise);
        break;
      case "B": // Face Traseira
        swapFacePiecesInMatrix(0, 0, -1, move.clockwise);
        break;
    }
  }
  
  void swapFacePiecesInMatrix(int faceX, int faceY, int faceZ, boolean clockwise) {
    // Create a temporary 3x3 matrix to hold the face pieces
    Cubie[][] tempFace = new Cubie[3][3];
    
    // Debug: Count pieces in face
    int pieceCount = 0;
    
    // Extract face pieces from the 3x3x3 matrix
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          if (isInFace(i, j, k, faceX, faceY, faceZ)) {
            // Map 3D coordinates to 2D face coordinates
            int faceI, faceJ;
            if (faceX != 0) {
              faceI = j; faceJ = k;
            } else if (faceY != 0) {
              faceI = i; faceJ = k;
            } else {
              faceI = i; faceJ = j;
            }
            tempFace[faceI][faceJ] = cubies[i][j][k];
            pieceCount++;
          }
        }
      }
    }
    
    // Debug: Verify we have exactly 9 pieces (3x3 face)
    if (pieceCount != 9) {
      println("ERROR: Expected 9 pieces in face, got " + pieceCount);
      println("Face: " + faceX + "," + faceY + "," + faceZ);
    }
    
    // Debug: Verify tempFace is properly filled
    int tempFaceCount = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (tempFace[i][j] != null) tempFaceCount++;
      }
    }
    if (tempFaceCount != 9) {
      println("ERROR: tempFace should have 9 pieces, got " + tempFaceCount);
    }
    
    // Rotate the 2D face matrix
    Cubie[][] rotatedFace = new Cubie[3][3];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (tempFace[i][j] != null) {
          if (clockwise) {
            rotatedFace[j][2-i] = tempFace[i][j];
          } else {
            rotatedFace[2-j][i] = tempFace[i][j];
          }
        }
      }
    }
    
    // Debug: Count rotated pieces
    int rotatedCount = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (rotatedFace[i][j] != null) rotatedCount++;
      }
    }
    if (rotatedCount != 9) {
      println("ERROR: rotatedFace should have 9 pieces, got " + rotatedCount);
    }
    
    // Create a mapping from 2D face coordinates back to 3D matrix coordinates
    // This is the key fix - we need to map rotated 2D coordinates back to 3D
    int placedCount = 0;
    for (int faceI = 0; faceI < 3; faceI++) {
      for (int faceJ = 0; faceJ < 3; faceJ++) {
        if (rotatedFace[faceI][faceJ] != null) {
          // Find the 3D coordinates for this face position
          int targetI = -1, targetJ = -1, targetK = -1;
          
          if (faceX != 0) {
            // Face is perpendicular to X axis
            targetI = (faceX > 0) ? 2 : 0;
            targetJ = faceI;
            targetK = faceJ;
          } else if (faceY != 0) {
            // Face is perpendicular to Y axis
            targetI = faceI;
            targetJ = (faceY > 0) ? 2 : 0;
            targetK = faceJ;
          } else if (faceZ != 0) {
            // Face is perpendicular to Z axis
            targetI = faceI;
            targetJ = faceJ;
            targetK = (faceZ > 0) ? 2 : 0;
          }
          
          // Place the rotated piece in the correct 3D position
          if (targetI >= 0 && targetJ >= 0 && targetK >= 0) {
            cubies[targetI][targetJ][targetK] = rotatedFace[faceI][faceJ];
            
            // CRITICAL: Update the piece's 3D position to match its new matrix position
            float newX = (targetI - 1) * (size + gap);
            float newY = (targetJ - 1) * (size + gap);
            float newZ = (targetK - 1) * (size + gap);
            cubies[targetI][targetJ][targetK].pos.set(newX, newY, newZ);
            
            
            placedCount++;
          }
        }
      }
    }
    
    // Debug: Verify all pieces were placed
    if (placedCount != 9) {
      println("ERROR: Should have placed 9 pieces, placed " + placedCount);
    }
    
    // Reset visual rotations for all pieces
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          cubies[i][j][k].resetVisualRotation();
        }
      }
    }
    
    // Colors are now handled dynamically in the display method
    // No need to update colors globally - they're determined at render time
  }
  
  void addMove(String face, boolean clockwise) {
    moves.add(new Move(face, clockwise));
  }
  
  void randomMove() {
    String[] faces = {"U", "D", "L", "R", "F", "B"};
    String face = faces[(int)random(faces.length)];
    boolean clockwise = random(1) > 0.5;
    moves.add(new Move(face, clockwise));
  }
  
  void reset() {
    moves.clear();
    currentMove = null;
    moveCount = 0;
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          float x = (i - 1) * (size + gap);
          float y = (j - 1) * (size + gap);
          float z = (k - 1) * (size + gap);
          cubies[i][j][k].reset(x, y, z);
        }
      }
    }
  }
}

class Cubie {
  PVector pos;
  PVector originalPos;
  float size;
  color[] colors;
  
  // Visual rotation properties for animation
  float visualRotationX = 0;
  float visualRotationY = 0;
  float visualRotationZ = 0;
  PVector visualCenter = new PVector(0, 0, 0);
  
  Cubie(float x, float y, float z, float size) {
    pos = new PVector(x, y, z);
    originalPos = new PVector(x, y, z);
    this.size = size;
    colors = new color[6];
    
    // Define cores padrão do cubo mágico
    for (int i = 0; i < 6; i++) {
      colors[i] = color(30); // Cor padrão (cinza escuro)
    }
    
    // Direita (X positivo)
    if (x > 0) colors[0] = color(255, 0, 0);    // Vermelho
    // Esquerda (X negativo)
    if (x < 0) colors[1] = color(255, 165, 0);  // Laranja
    // Superior (Y positivo)
    if (y > 0) colors[2] = color(255, 255, 255);// Branco
    // Inferior (Y negativo)
    if (y < 0) colors[3] = color(255, 255, 0);  // Amarelo
    // Frontal (Z positivo)
    if (z > 0) colors[4] = color(0, 255, 0);    // Verde
    // Traseiro (Z negativo)
    if (z < 0) colors[5] = color(0, 0, 255);    // Azul
  }
  
  void reset(float x, float y, float z) {
    pos.set(x, y, z);
    // Reset visual rotations
    visualRotationX = 0;
    visualRotationY = 0;
    visualRotationZ = 0;
    visualCenter.set(0, 0, 0);
  }
  
  void setVisualRotation(float rx, float ry, float rz, PVector center) {
    visualRotationX = rx;
    visualRotationY = ry;
    visualRotationZ = rz;
    visualCenter = center.copy();
  }
  
  void resetVisualRotation() {
    visualRotationX = 0;
    visualRotationY = 0;
    visualRotationZ = 0;
    visualCenter.set(0, 0, 0);
  }
  
  void updateColorsBasedOnPosition() {
    // This method is now deprecated - we'll use a different approach
    // Keep the original colors and let the display method handle external faces
  }
  
  boolean isFaceExternal(int faceIndex) {
    // Check if a specific face of this piece is on the external surface of the cube
    switch(faceIndex) {
      case 0: // Right face (X positive)
        return pos.x > 0;
      case 1: // Left face (X negative)
        return pos.x < 0;
      case 2: // Top face (Y positive)
        return pos.y > 0;
      case 3: // Bottom face (Y negative)
        return pos.y < 0;
      case 4: // Front face (Z positive)
        return pos.z > 0;
      case 5: // Back face (Z negative)
        return pos.z < 0;
      default:
        return false;
    }
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    
    // Apply visual rotation if any
    if (visualRotationX != 0 || visualRotationY != 0 || visualRotationZ != 0) {
      // Translate to visual center, rotate, translate back
      translate(-visualCenter.x, -visualCenter.y, -visualCenter.z);
      rotateX(visualRotationX);
      rotateY(visualRotationY);
      rotateZ(visualRotationZ);
      translate(visualCenter.x, visualCenter.y, visualCenter.z);
    }
    
    // Desenha as faces coloridas
    drawFaces();
    
    // Desenha arestas com destaque
    drawEdges();
    
    popMatrix();
  }
  
  void drawFaces() {
    beginShape(QUADS);
    
    // Face direita (X positivo) - Red
    if (isFaceExternal(0)) {
      fill(colors[0]); // Red
    } else {
      fill(30); // Gray for internal faces
    }
    vertex(size/2, -size/2, -size/2);
    vertex(size/2, -size/2, size/2);
    vertex(size/2, size/2, size/2);
    vertex(size/2, size/2, -size/2);
    
    // Face esquerda (X negativo) - Orange
    if (isFaceExternal(1)) {
      fill(colors[1]); // Orange
    } else {
      fill(30); // Gray for internal faces
    }
    vertex(-size/2, -size/2, -size/2);
    vertex(-size/2, -size/2, size/2);
    vertex(-size/2, size/2, size/2);
    vertex(-size/2, size/2, -size/2);
    
    // Face superior (Y positivo) - White
    if (isFaceExternal(2)) {
      fill(colors[2]); // White
    } else {
      fill(30); // Gray for internal faces
    }
    vertex(-size/2, size/2, -size/2);
    vertex(size/2, size/2, -size/2);
    vertex(size/2, size/2, size/2);
    vertex(-size/2, size/2, size/2);
    
    // Face inferior (Y negativo) - Yellow
    if (isFaceExternal(3)) {
      fill(colors[3]); // Yellow
    } else {
      fill(30); // Gray for internal faces
    }
    vertex(-size/2, -size/2, -size/2);
    vertex(size/2, -size/2, -size/2);
    vertex(size/2, -size/2, size/2);
    vertex(-size/2, -size/2, size/2);
    
    // Face frontal (Z positivo) - Green
    if (isFaceExternal(4)) {
      fill(colors[4]); // Green
    } else {
      fill(30); // Gray for internal faces
    }
    vertex(-size/2, -size/2, size/2);
    vertex(size/2, -size/2, size/2);
    vertex(size/2, size/2, size/2);
    vertex(-size/2, size/2, size/2);
    
    // Face traseira (Z negativo) - Blue
    if (isFaceExternal(5)) {
      fill(colors[5]); // Blue
    } else {
      fill(30); // Gray for internal faces
    }
    vertex(-size/2, -size/2, -size/2);
    vertex(size/2, -size/2, -size/2);
    vertex(size/2, size/2, -size/2);
    vertex(-size/2, size/2, -size/2);
    
    endShape();
  }
  
  void drawEdges() {
    stroke(40);
    strokeWeight(1.5);
    noFill();
    
    // Arestas horizontais
    line(-size/2, -size/2, -size/2, size/2, -size/2, -size/2);
    line(-size/2, -size/2, size/2, size/2, -size/2, size/2);
    line(-size/2, size/2, -size/2, size/2, size/2, -size/2);
    line(-size/2, size/2, size/2, size/2, size/2, size/2);
    
    // Arestas verticais
    line(-size/2, -size/2, -size/2, -size/2, size/2, -size/2);
    line(size/2, -size/2, -size/2, size/2, size/2, -size/2);
    line(-size/2, -size/2, size/2, -size/2, size/2, size/2);
    line(size/2, -size/2, size/2, size/2, size/2, size/2);
    
    // Arestas de profundidade
    line(-size/2, -size/2, -size/2, -size/2, -size/2, size/2);
    line(size/2, -size/2, -size/2, size/2, -size/2, size/2);
    line(-size/2, size/2, -size/2, -size/2, size/2, size/2);
    line(size/2, size/2, -size/2, size/2, size/2, size/2);
    
    noStroke();
  }
}

class Move {
  String face;
  boolean clockwise;
  float angle = 0;
  float targetAngle;
  float speed = 0.1;
  
  Move(String face, boolean clockwise) {
    this.face = face;
    this.clockwise = clockwise;
    targetAngle = clockwise ? HALF_PI : -HALF_PI;
  }
  
  void start() {
    angle = 0;
  }
  
  void update() {
    // Atualiza o ângulo da animação
    float step = speed * (clockwise ? 1 : -1);
    angle += step;
    
    // Limita o ângulo ao valor alvo
    if ((clockwise && angle >= targetAngle) || (!clockwise && angle <= targetAngle)) {
      angle = targetAngle;
    }
    
    // Aplica a rotação aos cubies relevantes
    applyRotation();
  }
  
  void applyRotation() {
    // This method will be handled by the RubiksCube class
    // The actual rotation logic is implemented in the RubiksCube class
  }
  
  boolean isInFace(int i, int j, int k) {
    switch(face) {
      case "U": return j == 2; // Face superior
      case "D": return j == 0; // Face inferior
      case "L": return i == 0; // Face esquerda
      case "R": return i == 2; // Face direita
      case "F": return k == 2; // Face frontal
      case "B": return k == 0; // Face traseira
      default: return false;
    }
  }
  
  boolean finished() {
    return angle == targetAngle;
  }
}
