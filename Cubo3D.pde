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
    // Aplica rotação aos cubies relevantes
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          Cubie cubie = cubies[i][j][k];
          
          // Verifica se este cubie está na face que está sendo rotacionada
          if (move.isInFace(i, j, k)) {
            // Aplica a rotação apropriada
            switch(move.face) {
              case "U": // Superior (Y máximo)
                rotateCubie(cubie, 0, move.angle, 0);
                break;
              case "D": // Inferior (Y mínimo)
                rotateCubie(cubie, 0, -move.angle, 0);
                break;
              case "L": // Esquerda (X mínimo)
                rotateCubie(cubie, move.angle, 0, 0);
                break;
              case "R": // Direita (X máximo)
                rotateCubie(cubie, -move.angle, 0, 0);
                break;
              case "F": // Frontal (Z máximo)
                rotateCubie(cubie, 0, 0, move.angle);
                break;
              case "B": // Traseira (Z mínimo)
                rotateCubie(cubie, 0, 0, -move.angle);
                break;
            }
          }
        }
      }
    }
  }
  
  void rotateCubie(Cubie cubie, float rx, float ry, float rz) {
    // Cria um vetor temporário
    PVector temp = cubie.pos.copy();
    
    // Aplica rotações
    if (rx != 0) {
      float y = temp.y;
      float z = temp.z;
      temp.y = y * cos(rx) - z * sin(rx);
      temp.z = y * sin(rx) + z * cos(rx);
    }
    if (ry != 0) {
      float x = temp.x;
      float z = temp.z;
      temp.x = x * cos(ry) + z * sin(ry);
      temp.z = -x * sin(ry) + z * cos(ry);
    }
    if (rz != 0) {
      float x = temp.x;
      float y = temp.y;
      temp.x = x * cos(rz) - y * sin(rz);
      temp.y = x * sin(rz) + y * cos(rz);
    }
    
    // Atualiza a posição
    cubie.pos = temp;
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
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    
    // Desenha as faces coloridas
    drawFaces();
    
    // Desenha arestas com destaque
    drawEdges();
    
    popMatrix();
  }
  
  void drawFaces() {
    beginShape(QUADS);
    
    // Face direita (X positivo)
    fill(colors[0]);
    vertex(size/2, -size/2, -size/2);
    vertex(size/2, -size/2, size/2);
    vertex(size/2, size/2, size/2);
    vertex(size/2, size/2, -size/2);
    
    // Face esquerda (X negativo)
    fill(colors[1]);
    vertex(-size/2, -size/2, -size/2);
    vertex(-size/2, -size/2, size/2);
    vertex(-size/2, size/2, size/2);
    vertex(-size/2, size/2, -size/2);
    
    // Face superior (Y positivo)
    fill(colors[2]);
    vertex(-size/2, size/2, -size/2);
    vertex(size/2, size/2, -size/2);
    vertex(size/2, size/2, size/2);
    vertex(-size/2, size/2, size/2);
    
    // Face inferior (Y negativo)
    fill(colors[3]);
    vertex(-size/2, -size/2, -size/2);
    vertex(size/2, -size/2, -size/2);
    vertex(size/2, -size/2, size/2);
    vertex(-size/2, -size/2, size/2);
    
    // Face frontal (Z positivo)
    fill(colors[4]);
    vertex(-size/2, -size/2, size/2);
    vertex(size/2, -size/2, size/2);
    vertex(size/2, size/2, size/2);
    vertex(-size/2, size/2, size/2);
    
    // Face traseira (Z negativo)
    fill(colors[5]);
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
