class Slider {
    final int w = 200;
    final int h = 10;
    int x;
    int y;
    int sliderX;
    int sliderY;
    float min;
    float max;
    float value;
    boolean dragging = false;
    
    Slider(int x, int y, float min, float max) {
        this.x = x;
        this.y = y;
        sliderX = x;
        sliderY = y;
        this.min = min;
        this.max = max;
        value = min;
    }
    
    float getValue() {
        return value;
    }
    
    boolean containsX(int x) {
        return x >= this.x && x <= (this.x + w);
    }
    
    boolean containsY(int y) {
        return y >= this.y && y <= (this.y + h);
    }
    
    boolean contains(int x, int y) {
        return containsX(x) && containsY(y);
    }
    
    void paint(String suffix) {
        stroke(128);
        fill(128);
        rect(x, y, w, h);
        
        if (mousePressed) {
            if (contains(mouseX, mouseY) && mouseButton == LEFT) {
                dragging = true;
            }
            if (dragging && containsX(mouseX)) {
                sliderX = mouseX;
                value = (((sliderX - x) / (float) w) * (max - min)) + min;
            }
        } else {
            dragging = false;
        }
        
        stroke(0);
        fill(0);
        textSize(14);
        text(String.format("%.2f", value) + suffix, x + w + 10, y + h);
        rect(sliderX, sliderY, h, h);
    }
}