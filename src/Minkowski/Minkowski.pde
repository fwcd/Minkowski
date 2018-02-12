// Class declarations

class Point {
    float x;
    float ct;
    
    Point(float x, float ct) {
        this(x, ct, false);
    }
    
    Point(float x, float ct, boolean fromScreenCoords) {
        if (fromScreenCoords) {
            this.x = x - padding;
            this.ct = -(ct - height + padding);
        } else {
            this.x = x;
            this.ct = ct;
        }
    }
    
    float getX() {
        return x;
    }
    
    float getCT() {
        return ct;
    }
    
    Point transform(float v) {
        float beta = v / c;
        float gamma = 1 / sqrt(1 - (beta * beta));
        return new Point(
                gamma * (x - (beta * ct)),
                gamma * (ct - (beta * x))
        );
    }
    
    float toScreenX() {
        return x + padding;
    }
    
    float toScreenY() {
        return height - padding - ct;
    }
    
    void paint(int r, int g, int b, float pointSize) {
        stroke(r, g, b);
        fill(r, g, b);
        ellipse(toScreenX(), toScreenY(), pointSize, pointSize);
    }
    
    void paintLine(Point dest, int r, int g, int b, float thickness) {
        stroke(r, g, b);
        strokeWeight(thickness);
        line(toScreenX(), toScreenY(), dest.toScreenX(), dest.toScreenY());
    }
    
    void paintText(String str, float size) {
        textSize(size);
        text(str, toScreenX(), toScreenY());
    }
}

class CoordSystem {
    final float granularity = 0.3F;
    final boolean showGrid = true;
    final float gridSpacing = 50F;
    float v;
    int rColor;
    int gColor;
    int bColor;
    
    CoordSystem(float v, int r, int g, int b) {
        this.v = v;
        rColor = r;
        gColor = g;
        bColor = b;
    }
    
    void paint() {
        float maxX = width - (padding * 2);
        float maxY = height - (padding * 2);
        
        paintLine(0, 0, maxX, 0, 5); // x-axis
        paintLine(0, 0, 0, maxY, 5); // y-axis
        
        fill(rColor, gColor, bColor);
        new Point(maxX, 0).transform(v).paintText("x", 24);
        new Point(0, maxY).transform(v).paintText("ct", 24);
        
        if (showGrid) {
            for (int y=0; y<maxY; y+=gridSpacing) {
                paintLine(0, y, maxX, y, 1);
            }
            for (int x=0; x<maxX; x+=gridSpacing) {
                paintLine(x, 0, x, maxY, 1);
            }
        }
    }
    
    float relativeVelocity(CoordSystem other) {
        return v - other.v;
    }
    
    void trace(Point p, float dv) {
        Point pT = p.transform(dv);
        paintLine(0, pT.getCT(), pT.getX(), pT.getCT(), 3);
        paintLine(pT.getX(), 0, pT.getX(), pT.getCT(), 3);
    }
    
    void paintRange(float xA, float ctA, float xB, float ctB, float pointSize) {
        float step = 1F / granularity;
        for (float x=xA; x<=xB; x+=step) {
            for (float ct=ctA; ct<=ctB; ct+=step) {
                new Point(x, ct).transform(v).paint(rColor, gColor, bColor, pointSize);
            }
        }
    }
    
    void paintLine(float xA, float ctA, float xB, float ctB, float thickness) {
        Point a = new Point(xA, ctA).transform(v);
        Point b = new Point(xB, ctB).transform(v);
        a.paintLine(b, rColor, gColor, bColor, thickness);
    }
}

// Variable declarations

final float c = 299792458; // Speed of light
final int padding = 50;
final Slider slider = new Slider(10, 10, -c, c);
final CoordSystem observerSystem = new CoordSystem(0, 100, 100, 100);
Point point = null;
boolean showHint = true;

// Method declarations

void setup() {
    size(640, 480);
}

void draw() {
    clear();
    fill(255);
    stroke(255);
    rect(0, 0, width, height);
    
    CoordSystem movingSystem = new CoordSystem(slider.getValue(), 0, 0, 255);
    observerSystem.paint();
    movingSystem.paint();
    
    fill(255);
    stroke(255);
    rect(0, 0, width, 22);
    slider.paint(" m/s");
    
    if (point != null) {
        movingSystem.trace(point, observerSystem.relativeVelocity(movingSystem));
        point.paint(128, 0, 255, 15);
    }
    
    if (mousePressed && mouseButton == RIGHT) {
        point = new Point(mouseX, mouseY, true);
    }
    
    if (showHint) {
        fill(0);
        String hint = "Drag slider to change velocity - Right click to place point";
        text(hint, padding, height - (padding / 2));
        
        if (mousePressed) {
            showHint = false;
        }
    }
}