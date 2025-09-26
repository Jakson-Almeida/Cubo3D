# Cubo3D - Interactive 3D Rubik's Cube

A beautiful and interactive 3D Rubik's Cube implementation built with Processing (Java). This project features a fully functional 3D Rubik's cube with smooth animations, camera controls, and keyboard interactions.

## 🎮 Features

- **3D Visualization**: Full 3D Rubik's cube with proper colors and lighting
- **Interactive Controls**: Complete keyboard controls for cube manipulation
- **Smooth Animations**: Fluid rotation animations for all cube faces
- **Camera System**: 3D camera controls using PeasyCam library
- **Floating Effect**: Optional floating animation for visual appeal
- **Auto-Rotation**: Automatic random moves at regular intervals
- **HUD Interface**: On-screen display with controls and move counter

## 🎯 Controls

### Cube Face Rotations
- **U** - Upper face (clockwise)
- **D** - Down face (clockwise)  
- **L** - Left face (clockwise)
- **R** - Right face (clockwise)
- **F** - Front face (clockwise)
- **B** - Back face (clockwise)

### Camera Controls
- **Arrow Keys** - Pan camera view
- **Mouse** - Drag to rotate camera around the cube

### Special Functions
- **R** - Reset cube to solved state
- **F** - Toggle floating animation
- **Space** - Perform random move
- **ESC** - Exit fullscreen

## 🛠️ Technical Details

### Dependencies
- **Processing 3.5+** or **Processing 4.x**
- **PeasyCam Library** - For 3D camera controls
- **Commons Math Library** - For mathematical operations

### Installation
1. Install [Processing IDE](https://processing.org/download/)
2. Install PeasyCam library:
   - Go to `Tools` → `Manage Tools...`
   - Search for "PeasyCam" and install it
3. Clone this repository
4. Open `Cubo3D.pde` in Processing IDE
5. Run the sketch

### Project Structure
```
Cubo3D/
├── Cubo3D.pde          # Main Processing sketch
└── README.md           # This documentation
```

## 🎨 Visual Features

- **Authentic Colors**: Standard Rubik's cube color scheme
  - Red, Orange, White, Yellow, Green, Blue faces
- **Dynamic Lighting**: Multiple light sources for realistic rendering
- **Smooth Edges**: Clean wireframe edges for better visibility
- **Gradient Background**: Dark blue gradient background
- **Floating Animation**: Optional sine wave floating motion

## 🔧 Code Architecture

### Main Classes
- **`RubiksCube`** - Main cube logic and rendering
- **`Cubie`** - Individual cube piece with position and colors
- **`Move`** - Animation system for face rotations

### Key Functions
- `setup()` - Initialize camera and cube
- `draw()` - Main rendering loop with lighting and effects
- `keyPressed()` - Handle keyboard input
- `drawHUD()` - Render on-screen interface

## 🚀 Getting Started

1. **Launch the Application**
   - Run the sketch in Processing IDE
   - The cube will appear in fullscreen mode

2. **Basic Interaction**
   - Use mouse to rotate camera view
   - Press face keys (U, D, L, R, F, B) to rotate cube faces
   - Watch the smooth animations

3. **Explore Features**
   - Press **R** to reset the cube
   - Press **F** to toggle floating effect
   - Press **Space** for random moves

## 📱 System Requirements

- **OS**: Windows, macOS, or Linux
- **Processing**: Version 3.5 or higher
- **Java**: JRE 8 or higher
- **Memory**: 512MB RAM minimum
- **Graphics**: OpenGL support recommended

## 🎯 Future Enhancements

- [ ] Solve algorithm implementation
- [ ] Different cube sizes (2x2, 4x4, 5x5)
- [ ] Sound effects for rotations
- [ ] Save/load cube states
- [ ] Multiplayer mode
- [ ] VR support

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

**Jakson Almeida**
- GitHub: [@Jakson-Almeida](https://github.com/Jakson-Almeida)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📞 Support

If you encounter any issues or have questions, please open an issue on GitHub.

---

**Enjoy solving your virtual Rubik's cube! 🧩**