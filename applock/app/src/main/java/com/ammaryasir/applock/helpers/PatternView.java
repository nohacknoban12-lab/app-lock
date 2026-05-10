package com.ammaryasir.applock.helpers;
import android.content.Context;
import android.graphics.*;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import java.util.ArrayList;
import java.util.List;
public class PatternView extends View {
    public interface OnPatternListener { void onPatternComplete(String pattern); }
    private final float[] dotX = new float[9];
    private final float[] dotY = new float[9];
    private final boolean[] selected = new boolean[9];
    private final List<Integer> selectedDots = new ArrayList<>();
    private float touchX, touchY;
    private boolean drawing = false;
    private Paint dotPaint, linePaint, selectedDotPaint;
    private OnPatternListener listener;
    public PatternView(Context context) { super(context); init(); }
    public PatternView(Context context, AttributeSet attrs) { super(context, attrs); init(); }
    private void init() {
        dotPaint = new Paint(Paint.ANTI_ALIAS_FLAG); dotPaint.setColor(0xFFAAAAAA); dotPaint.setStyle(Paint.Style.FILL);
        selectedDotPaint = new Paint(Paint.ANTI_ALIAS_FLAG); selectedDotPaint.setColor(0xFF7C6AF7); selectedDotPaint.setStyle(Paint.Style.FILL);
        linePaint = new Paint(Paint.ANTI_ALIAS_FLAG); linePaint.setColor(0xFF7C6AF7); linePaint.setStrokeWidth(6f); linePaint.setStyle(Paint.Style.STROKE);
    }
    @Override
    protected void onSizeChanged(int w, int h, int oldW, int oldH) {
        float cellW = w / 3f, cellH = h / 3f; int i = 0;
        for (int r = 0; r < 3; r++) for (int c = 0; c < 3; c++) { dotX[i] = cellW*c+cellW/2; dotY[i] = cellH*r+cellH/2; i++; }
    }
    @Override
    protected void onDraw(Canvas canvas) {
        float dotRadius = Math.min(getWidth(), getHeight()) / 12f;
        for (int i = 0; i < selectedDots.size()-1; i++) { int a=selectedDots.get(i),b=selectedDots.get(i+1); canvas.drawLine(dotX[a],dotY[a],dotX[b],dotY[b],linePaint); }
        if (drawing && !selectedDots.isEmpty()) { int last=selectedDots.get(selectedDots.size()-1); canvas.drawLine(dotX[last],dotY[last],touchX,touchY,linePaint); }
        for (int i = 0; i < 9; i++) canvas.drawCircle(dotX[i],dotY[i],dotRadius,selected[i]?selectedDotPaint:dotPaint);
    }
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        touchX=event.getX(); touchY=event.getY();
        switch(event.getAction()) {
            case MotionEvent.ACTION_DOWN: clearPattern(); drawing=true; checkDot(); break;
            case MotionEvent.ACTION_MOVE: checkDot(); break;
            case MotionEvent.ACTION_UP: drawing=false; if(listener!=null&&selectedDots.size()>=4) listener.onPatternComplete(getPatternString()); break;
        }
        invalidate(); return true;
    }
    private void checkDot() {
        float r = Math.min(getWidth(),getHeight())/12f;
        for (int i=0;i<9;i++) if(!selected[i]) { float dx=touchX-dotX[i],dy=touchY-dotY[i]; if(Math.sqrt(dx*dx+dy*dy)<r*1.5f){selected[i]=true;selectedDots.add(i);break;} }
    }
    private String getPatternString() { StringBuilder sb=new StringBuilder(); for(int d:selectedDots)sb.append(d); return sb.toString(); }
    public void clearPattern() { for(int i=0;i<9;i++)selected[i]=false; selectedDots.clear(); invalidate(); }
    public void setOnPatternListener(OnPatternListener l) { this.listener=l; }
}
